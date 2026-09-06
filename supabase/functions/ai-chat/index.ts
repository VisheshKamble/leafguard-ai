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
// This function requires a real Supabase Auth user. Deploy without
// `--no-verify-jwt`; the application-level check below is defense in depth.

// Supabase loads local values with `supabase functions serve --env-file` and
// deployed values from Supabase secrets.

declare const Deno: {
  env: {
    get(name: string): string | undefined;
  };
  serve(handler: (req: Request) => Response | Promise<Response>): void;
};

const GROQ_API_KEY = Deno.env.get('GROQ_API_KEY') ?? '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
// The deployed default is OpenAI's open-weight model served by Groq. Override
// it with the AI_CHAT_MODEL secret/env var when needed.
const MODEL = Deno.env.get('AI_CHAT_MODEL') ?? 'openai/gpt-oss-120b';
const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const jsonHeaders = { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' };

const MAX_BODY_BYTES = 32 * 1024;
const MAX_MESSAGE_LENGTH = 2_000;
const MAX_HISTORY_TURNS = 12;
const MAX_TURN_LENGTH = 2_000;
const MAX_LOCATION_LENGTH = 200;
const MAX_PREFERRED_CROPS = 10;
const MAX_CROP_LENGTH = 80;
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_REQUESTS = 20;

interface RateLimitEntry {
  startedAt: number;
  count: number;
}

const rateLimits = new Map<string, RateLimitEntry>();

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

async function getAuthenticatedUserId(req: Request): Promise<string | null> {
  const authorization = req.headers.get('authorization');
  if (!authorization?.startsWith('Bearer ') || !SUPABASE_URL || !SUPABASE_ANON_KEY) {
    return null;
  }

  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      authorization,
    },
  });
  if (!response.ok) return null;

  const user = await response.json() as { id?: unknown };
  return typeof user.id === 'string' && user.id.length > 0 ? user.id : null;
}

function isRateLimited(userId: string): boolean {
  const now = Date.now();
  const current = rateLimits.get(userId);

  if (!current || now - current.startedAt >= RATE_LIMIT_WINDOW_MS) {
    rateLimits.set(userId, { startedAt: now, count: 1 });
  } else {
    current.count += 1;
    if (current.count > RATE_LIMIT_REQUESTS) return true;
  }

  if (rateLimits.size > 10_000) {
    for (const [key, entry] of rateLimits) {
      if (now - entry.startedAt >= RATE_LIMIT_WINDOW_MS) rateLimits.delete(key);
    }
  }
  return false;
}

function errorResponse(error: string, status: number, headers = jsonHeaders): Response {
  return new Response(JSON.stringify({ error }), { status, headers });
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

  if (req.method !== 'POST') return errorResponse('method not allowed', 405);

  try {
    const userId = await getAuthenticatedUserId(req);
    if (!userId) return errorResponse('authentication required', 401);
    if (isRateLimited(userId)) {
      return new Response(JSON.stringify({ error: 'rate limit exceeded' }), {
        status: 429,
        headers: { ...jsonHeaders, 'Retry-After': '60' },
      });
    }

    if (!GROQ_API_KEY) {
      return errorResponse('AI service is not configured', 500);
    }

    let body: RequestBody;
    try {
      const contentLength = Number(req.headers.get('content-length') ?? 0);
      if (contentLength > MAX_BODY_BYTES) throw new Error('request body too large');
      const rawBody = await req.text();
      if (new TextEncoder().encode(rawBody).length > MAX_BODY_BYTES) {
        throw new Error('request body too large');
      }
      const parsed: unknown = JSON.parse(rawBody);
      if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
        throw new Error('request body must be an object');
      }
      body = parsed as RequestBody;
    } catch {
      return errorResponse('valid JSON body is required', 400);
    }

    if (!body.message || typeof body.message !== 'string' || body.message.trim().length === 0) {
      return errorResponse('message is required', 400);
    }
    if (body.message.length > MAX_MESSAGE_LENGTH) {
      return errorResponse('message is too long', 413);
    }

    const history = Array.isArray(body.history)
      ? body.history.filter(
          (turn): turn is ChatTurn =>
            (turn?.role === 'user' || turn?.role === 'assistant') &&
            typeof turn.content === 'string' &&
            turn.content.trim().length > 0 &&
            turn.content.length <= MAX_TURN_LENGTH,
        )
      : [];
    if (Array.isArray(body.history) && body.history.length > MAX_HISTORY_TURNS) {
      return errorResponse('too many history turns', 413);
    }
    if (Array.isArray(body.history) && history.length !== body.history.length) {
      return errorResponse('invalid history turn', 400);
    }
    if (body.location !== undefined &&
        (typeof body.location !== 'string' || body.location.length > MAX_LOCATION_LENGTH)) {
      return errorResponse('location is invalid or too long', 400);
    }
    if (body.preferredCrops !== undefined &&
        (!Array.isArray(body.preferredCrops) ||
            body.preferredCrops.length > MAX_PREFERRED_CROPS ||
            body.preferredCrops.some(
                (crop) => typeof crop !== 'string' || crop.length > MAX_CROP_LENGTH))) {
      return errorResponse('preferred crops are invalid', 400);
    }

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
