// supabase/functions/ai-chat/index.ts
//
// LeafGuard's AI-assistant backend. Keeps the LLM API key server-side --
// the Flutter app never sees it, it only calls this function via
// `Supabase.instance.client.functions.invoke('ai-chat', ...)`.
//
// Uses Groq's OpenAI-compatible chat-completions API for fast, cheap
// inference -- a good fit for a chat feature that needs to feel instant
// on a farmer's phone.
//
// Deploy:
//   supabase functions deploy ai-chat
//   supabase secrets set GROQ_API_KEY=gsk_...
//
// If your app lets people use the assistant WITHOUT signing in (LeafGuard's
// "continue without account" flow), Supabase's default JWT check will
// reject anonymous calls. Either:
//   (a) deploy with:  supabase functions deploy ai-chat --no-verify-jwt
//   (b) or enable Anonymous sign-ins (Authentication > Providers) so every
//       app session has a valid (anonymous) JWT.
// Option (a) is simplest for a portfolio/demo build.

// Supabase loads local values with `supabase functions serve --env-file` and
// deployed values from Supabase secrets.

declare const Deno: {
  env: {
    get(name: string): string | undefined;
  };
  serve(handler: (req: Request) => Response | Promise<Response>): void;
};

const GROQ_API_KEY = Deno.env.get('GROQ_API_KEY') ?? '';
// The deployed default is OpenAI's open-weight model served by Groq. Override
// it with the AI_CHAT_MODEL secret/env var when needed.
const MODEL = Deno.env.get('AI_CHAT_MODEL') ?? 'openai/gpt-oss-120b';
const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const jsonHeaders = { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' };

interface ChatTurn {
  role: 'user' | 'assistant';
  content: string;
}

interface ScanContext {
  cropName?: string;
  diseaseName?: string;
  isHealthy?: boolean;
  description?: string;
  confidencePercent?: number;
  severity?: string;
}

interface RequestBody {
  message: string;
  history?: ChatTurn[];
  language?: { code: string; name: string };
  location?: string;
  preferredCrops?: string[];
  scanContext?: ScanContext;
}

function buildSystemPrompt(body: RequestBody): string {
  const languageName = body.language?.name ?? 'English';
  const lines: string[] = [
    `You are LeafGuard's AI plant-health assistant, built for smallholder farmers using a mobile app that diagnoses crop diseases from leaf photos.`,
    `Always reply in ${languageName}, in simple, direct, everyday language a farmer with no technical background can act on immediately. Keep replies short (a few sentences to a short paragraph, plus a small list only when it genuinely helps) -- this is a chat window on a phone, not a report.`,
    `Prefer low-cost and organic options first, then mention chemical options only as a fallback with a clear safety note (protective equipment, re-entry interval, don't mix with other chemicals without checking the label).`,
    `If a question is outside plant health/agriculture, answer briefly and steer back to what you're here for.`,
  ];

  if (body.location) {
    lines.push(`The farmer is located in: ${body.location}. Tailor climate/seasonal advice to this region where relevant, but don't assume specifics you're not sure of.`);
  }
  if (body.preferredCrops && body.preferredCrops.length > 0) {
    lines.push(`Crops they usually grow: ${body.preferredCrops.join(', ')}.`);
  }
  if (body.scanContext) {
    const sc = body.scanContext;
    if (sc.isHealthy) {
      lines.push(
        `Context: they just scanned a ${sc.cropName ?? 'plant'} leaf with LeafGuard and it came back healthy (${sc.confidencePercent ?? '?'}% confidence). They may ask how to keep it that way.`,
      );
    } else {
      lines.push(
        `Context: they just scanned a ${sc.cropName ?? 'plant'} leaf with LeafGuard and it was diagnosed with "${sc.diseaseName ?? 'an issue'}" (${sc.confidencePercent ?? '?'}% confidence, severity: ${sc.severity ?? 'unknown'}). Reference description: ${sc.description ?? 'n/a'}. Answer their follow-up questions specifically about THIS diagnosis unless they clearly change the subject.`,
      );
    }
  }

  return lines.join('\n');
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    if (!GROQ_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'GROQ_API_KEY is not configured on the server.' }),
        { status: 500, headers: jsonHeaders },
      );
    }

    let body: RequestBody;
    try {
      const parsed: unknown = await req.json();
      if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
        throw new Error('request body must be an object');
      }
      body = parsed as RequestBody;
    } catch {
      return new Response(JSON.stringify({ error: 'valid JSON body is required' }), {
        status: 400,
        headers: jsonHeaders,
      });
    }

    if (!body.message || typeof body.message !== 'string' || body.message.trim().length === 0) {
      return new Response(JSON.stringify({ error: 'message is required' }), {
        status: 400,
        headers: jsonHeaders,
      });
    }

    const history = Array.isArray(body.history)
      ? body.history.filter(
          (turn): turn is ChatTurn =>
            (turn?.role === 'user' || turn?.role === 'assistant') &&
            typeof turn.content === 'string' &&
            turn.content.trim().length > 0,
        )
      : [];

    // Groq's API is OpenAI-compatible: the system prompt is just the first
    // message in the array (unlike Anthropic, which takes it as a separate
    // top-level field).
    const messages = [
      { role: 'system', content: buildSystemPrompt(body) },
      ...history,
      { role: 'user', content: body.message },
    ];

    const groqRes = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${GROQ_API_KEY}`,
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 700,
        temperature: 0.4,
        messages,
      }),
    });

    if (!groqRes.ok) {
      const errText = await groqRes.text();
      console.error('Groq API error:', groqRes.status, errText);
      return new Response(JSON.stringify({ error: 'AI provider error' }), {
        status: 502,
        headers: jsonHeaders,
      });
    }

    const data = await groqRes.json();
    const reply = typeof data.choices?.[0]?.message?.content === 'string'
      ? data.choices[0].message.content.trim()
      : '';

    if (!reply) {
      console.error('Groq API returned no assistant content:', JSON.stringify(data));
      return new Response(JSON.stringify({ error: 'AI provider returned an empty reply' }), {
        status: 502,
        headers: jsonHeaders,
      });
    }

    return new Response(JSON.stringify({ reply }), {
      status: 200,
      headers: jsonHeaders,
    });
  } catch (err) {
    console.error('ai-chat function error:', err);
    return new Response(JSON.stringify({ error: 'Internal error' }), {
      status: 500,
      headers: jsonHeaders,
    });
  }
});
