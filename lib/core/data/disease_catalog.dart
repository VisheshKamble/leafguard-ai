import '../../models/disease_info.dart';

/// Reference data for the diseases LeafGuard covers, keyed by the model's
/// raw class name (as produced by the New Plant Diseases Dataset labeling
/// convention, e.g. "Tomato___Late_blight").
///
/// Curated in full for the three launch crops (tomato, potato, corn), which
/// matches the initial scope of the model. Any other class the model can
/// output (the dataset covers 38 classes across 14 crops) still resolves to
/// a reasonable, honestly-generic entry via [lookup] rather than crashing --
/// see [_fallbackFor].
class DiseaseCatalog {
  DiseaseCatalog._();

  static final Map<String, DiseaseInfo> _entries = {
    // ---------------- Tomato ----------------
    'Tomato___Bacterial_spot': const DiseaseInfo(
      className: 'Tomato___Bacterial_spot',
      cropName: 'Tomato',
      diseaseName: 'Bacterial spot',
      isHealthy: false,
      description:
          'Small, dark, water-soaked spots on leaves and fruit caused by Xanthomonas bacteria. Spreads fast in warm, wet weather.',
      organicTreatment: [
        'Remove and destroy infected leaves promptly',
        'Apply a copper-based bactericide as a preventive spray',
        'Avoid overhead watering to keep foliage dry',
      ],
      chemicalTreatment: [
        'Copper-based bactericide, applied on a regular schedule during wet periods',
        'Rotate to a different bactericide class if the same spots keep returning',
      ],
      preventionTips: [
        'Use certified disease-free seed and transplants',
        'Rotate tomato crops with non-host plants for 2+ years',
        'Space plants for good airflow',
      ],
    ),
    'Tomato___Early_blight': const DiseaseInfo(
      className: 'Tomato___Early_blight',
      cropName: 'Tomato',
      diseaseName: 'Early blight',
      isHealthy: false,
      description:
          'Caused by the fungus Alternaria solani, showing as concentric "target-spot" rings, usually starting on older, lower leaves.',
      organicTreatment: [
        'Remove and destroy affected lower leaves',
        'Apply a copper or sulfur-based organic fungicide',
        'Mulch around the base to stop soil splashing onto leaves',
      ],
      chemicalTreatment: [
        'Chlorothalonil or mancozeb-based fungicide, applied per label directions',
        'Start treatment at the first sign of spotting for best results',
      ],
      preventionTips: [
        'Rotate crops every 2-3 years',
        'Stake or cage plants to improve airflow',
        'Water at the base of the plant, not overhead',
      ],
    ),
    'Tomato___Late_blight': const DiseaseInfo(
      className: 'Tomato___Late_blight',
      cropName: 'Tomato',
      diseaseName: 'Late blight',
      isHealthy: false,
      description:
          'A fast-moving, destructive disease caused by Phytophthora infestans -- the same pathogen behind the Irish potato famine. Can destroy a crop within days in cool, wet conditions.',
      organicTreatment: [
        'Remove and destroy infected plants immediately -- this spreads very fast',
        'Apply copper-based fungicide preventively, before an outbreak starts',
        'Improve airflow and reduce how long leaves stay wet',
      ],
      chemicalTreatment: [
        'Fungicide containing chlorothalonil, applied preventively',
        'Act immediately -- delayed treatment often means losing the crop',
      ],
      preventionTips: [
        'Avoid planting near infected potato fields',
        'Choose resistant tomato varieties where available',
        'Watch the weather -- cool, humid conditions raise risk sharply',
      ],
    ),
    'Tomato___Leaf_Mold': const DiseaseInfo(
      className: 'Tomato___Leaf_Mold',
      cropName: 'Tomato',
      diseaseName: 'Leaf mold',
      isHealthy: false,
      description:
          'A fungal disease common in humid greenhouses, causing pale spots on top of leaves and fuzzy mold underneath.',
      organicTreatment: [
        'Increase ventilation to lower humidity around plants',
        'Remove and destroy affected leaves',
        'Apply a copper-based fungicide',
      ],
      chemicalTreatment: [
        'Chlorothalonil-based fungicide applied at first sign of spotting',
      ],
      preventionTips: [
        'Grow resistant varieties where available',
        'Avoid overcrowding plants',
        'Keep humidity below roughly 85% where you can control it',
      ],
    ),
    'Tomato___Septoria_leaf_spot': const DiseaseInfo(
      className: 'Tomato___Septoria_leaf_spot',
      cropName: 'Tomato',
      diseaseName: 'Septoria leaf spot',
      isHealthy: false,
      description:
          'Produces many small circular spots with dark borders and pale centers, usually starting on lower leaves and working upward.',
      organicTreatment: [
        'Remove infected lower leaves promptly',
        'Apply a copper-based fungicide',
        'Mulch to reduce soil splash onto leaves',
      ],
      chemicalTreatment: [
        'Chlorothalonil or mancozeb-based fungicide on a regular schedule',
      ],
      preventionTips: [
        'Rotate crops season to season',
        'Avoid overhead watering',
        'Clear plant debris at the end of the season',
      ],
    ),
    'Tomato___Spider_mites Two-spotted_spider_mite': const DiseaseInfo(
      className: 'Tomato___Spider_mites Two-spotted_spider_mite',
      cropName: 'Tomato',
      diseaseName: 'Two-spotted spider mite',
      isHealthy: false,
      description:
          'Not a fungus or bacteria -- tiny mites that pierce leaf cells, causing stippling, bronzing, and fine webbing, especially in hot, dry weather.',
      organicTreatment: [
        'Spray leaves (top and underside) with a strong water jet to dislodge mites',
        'Apply insecticidal soap or neem oil',
        'Introduce predatory mites if growing at scale',
      ],
      chemicalTreatment: [
        'A miticide labeled for two-spotted spider mite, rotating products to avoid resistance',
      ],
      preventionTips: [
        'Keep plants well-watered -- mites thrive on drought-stressed plants',
        'Avoid excess nitrogen fertilizer',
        'Check the underside of leaves regularly in hot weather',
      ],
    ),
    'Tomato___Target_Spot': const DiseaseInfo(
      className: 'Tomato___Target_Spot',
      cropName: 'Tomato',
      diseaseName: 'Target spot',
      isHealthy: false,
      description:
          'A fungal disease producing brown lesions with concentric rings, visually similar to early blight.',
      organicTreatment: [
        'Remove affected foliage',
        'Apply a copper-based fungicide',
        'Improve airflow around plants',
      ],
      chemicalTreatment: [
        'Chlorothalonil or azoxystrobin-based fungicide per label directions',
      ],
      preventionTips: [
        'Rotate crops',
        'Avoid prolonged leaf wetness from overhead irrigation',
        'Maintain adequate plant spacing',
      ],
    ),
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus': const DiseaseInfo(
      className: 'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
      cropName: 'Tomato',
      diseaseName: 'Yellow leaf curl virus',
      isHealthy: false,
      description:
          'A viral disease spread by whiteflies, causing upward leaf curling, yellowing, and stunted growth. There is no cure once a plant is infected.',
      organicTreatment: [
        'Remove and destroy infected plants to slow spread',
        'Control whiteflies with yellow sticky traps and neem oil',
        'Use reflective mulch to help repel whiteflies',
      ],
      chemicalTreatment: [
        'Insecticide targeted at whitefly control -- the virus itself cannot be treated directly',
      ],
      preventionTips: [
        'Choose virus-resistant tomato varieties',
        'Use insect netting over young plants',
        'Control whitefly populations early in the season',
      ],
    ),
    'Tomato___Tomato_mosaic_virus': const DiseaseInfo(
      className: 'Tomato___Tomato_mosaic_virus',
      cropName: 'Tomato',
      diseaseName: 'Mosaic virus',
      isHealthy: false,
      description:
          'A stable, highly contagious virus causing mottled light and dark green patterns on leaves, and stunted growth. Spreads easily through contact and tools.',
      organicTreatment: [
        'Remove and destroy infected plants',
        'Disinfect tools and hands between plants',
        'Avoid handling plants while they are wet',
      ],
      chemicalTreatment: [
        'No chemical cure exists -- focus entirely on preventing further spread',
      ],
      preventionTips: [
        'Use certified virus-free seed',
        'Wash hands and tools between handling different plants',
        'Control aphids, which can spread the virus',
      ],
    ),
    'Tomato___healthy': const DiseaseInfo(
      className: 'Tomato___healthy',
      cropName: 'Tomato',
      diseaseName: 'Healthy',
      isHealthy: true,
      description: 'This leaf shows no visible signs of disease.',
      organicTreatment: [],
      chemicalTreatment: [],
      preventionTips: [
        'Keep monitoring regularly -- catching issues early makes treatment far more effective',
        'Maintain consistent watering and good airflow',
        'Rotate crops each season to reduce disease buildup in the soil',
      ],
    ),

    // ---------------- Potato ----------------
    'Potato___Early_blight': const DiseaseInfo(
      className: 'Potato___Early_blight',
      cropName: 'Potato',
      diseaseName: 'Early blight',
      isHealthy: false,
      description:
          'Caused by the fungus Alternaria solani -- the same disease that affects tomato -- showing as dark, target-ringed spots on older leaves.',
      organicTreatment: [
        'Remove affected lower leaves',
        'Apply a copper-based fungicide',
        'Mulch to reduce soil splash',
      ],
      chemicalTreatment: [
        'Chlorothalonil or mancozeb-based fungicide per label directions',
      ],
      preventionTips: [
        'Rotate potatoes with non-host crops for 2+ years',
        'Ensure good airflow between plants',
        'Avoid overhead irrigation late in the day',
      ],
    ),
    'Potato___Late_blight': const DiseaseInfo(
      className: 'Potato___Late_blight',
      cropName: 'Potato',
      diseaseName: 'Late blight',
      isHealthy: false,
      description:
          'Caused by Phytophthora infestans, the pathogen behind the 19th-century Irish potato famine. Spreads extremely fast in cool, wet weather and can destroy a field within days.',
      organicTreatment: [
        'Remove and destroy infected plants immediately',
        'Apply copper-based fungicide before an outbreak, as prevention',
        'Improve field drainage and airflow',
      ],
      chemicalTreatment: [
        'A fungicide labeled specifically for late blight, applied preventively',
        'Treat at the first sign of an outbreak in your area -- speed matters more than usual here',
      ],
      preventionTips: [
        'Plant certified disease-free seed potatoes',
        'Avoid overhead irrigation, especially in cool weather',
        'Destroy volunteer potato plants and cull piles, which can harbor the pathogen',
      ],
    ),
    'Potato___healthy': const DiseaseInfo(
      className: 'Potato___healthy',
      cropName: 'Potato',
      diseaseName: 'Healthy',
      isHealthy: true,
      description: 'This leaf shows no visible signs of disease.',
      organicTreatment: [],
      chemicalTreatment: [],
      preventionTips: [
        'Keep monitoring, especially after cool, wet weather -- that is when late blight risk spikes',
        'Rotate crops each season',
        'Use certified disease-free seed potatoes',
      ],
    ),

    // ---------------- Corn (maize) ----------------
    'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot': const DiseaseInfo(
      className: 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
      cropName: 'Corn',
      diseaseName: 'Gray leaf spot',
      isHealthy: false,
      description:
          'Caused by the fungus Cercospora zeae-maydis, producing rectangular gray-to-tan lesions that run parallel to leaf veins.',
      organicTreatment: [
        'Rotate away from corn for at least one season',
        'Choose resistant hybrids where available',
        'Improve airflow through reduced plant density in high-risk fields',
      ],
      chemicalTreatment: [
        'A strobilurin or triazole-based fungicide, applied at early disease onset',
      ],
      preventionTips: [
        'Rotate crops -- the fungus survives in corn residue',
        'Till under crop residue after harvest where practical',
        'Select resistant hybrid varieties for high-risk fields',
      ],
    ),
    'Corn_(maize)___Common_rust_': const DiseaseInfo(
      className: 'Corn_(maize)___Common_rust_',
      cropName: 'Corn',
      diseaseName: 'Common rust',
      isHealthy: false,
      description:
          'Caused by the fungus Puccinia sorghi, appearing as small, reddish-brown, powdery pustules scattered on both leaf surfaces.',
      organicTreatment: [
        'Choose resistant hybrids -- the most effective option for this disease',
        'Remove and destroy heavily infected leaves in small plantings',
      ],
      chemicalTreatment: [
        'A fungicide labeled for corn rust, typically only justified for severe outbreaks',
      ],
      preventionTips: [
        'Plant rust-resistant hybrids where common rust is a recurring issue',
        'Avoid very early or very late planting dates that extend exposure to spores',
      ],
    ),
    'Corn_(maize)___Northern_Leaf_Blight': const DiseaseInfo(
      className: 'Corn_(maize)___Northern_Leaf_Blight',
      cropName: 'Corn',
      diseaseName: 'Northern leaf blight',
      isHealthy: false,
      description:
          'Caused by the fungus Exserohilum turcicum, producing long, cigar-shaped gray-green lesions on leaves.',
      organicTreatment: [
        'Rotate away from corn for at least one season',
        'Choose resistant hybrids where available',
        'Till under crop residue after harvest where practical',
      ],
      chemicalTreatment: [
        'A strobilurin or triazole-based fungicide, applied at early disease onset in high-risk fields',
      ],
      preventionTips: [
        'Rotate crops -- residue is the main source of new infections',
        'Select resistant hybrid varieties',
        'Scout fields during humid weather, when the disease spreads fastest',
      ],
    ),
    'Corn_(maize)___healthy': const DiseaseInfo(
      className: 'Corn_(maize)___healthy',
      cropName: 'Corn',
      diseaseName: 'Healthy',
      isHealthy: true,
      description: 'This leaf shows no visible signs of disease.',
      organicTreatment: [],
      chemicalTreatment: [],
      preventionTips: [
        'Keep monitoring through the humid parts of the season',
        'Rotate crops season to season',
        'Select resistant hybrids for fields with a history of leaf disease',
      ],
    ),
  };

  /// Looks up reference info for a raw model class name. Falls back to a
  /// generated, honestly-generic entry for any class outside the curated
  /// launch crops, rather than throwing -- the model can output all 38
  /// dataset classes even though only tomato/potato/corn are fully curated.
  static DiseaseInfo lookup(String className) {
    return _entries[className] ?? _fallbackFor(className);
  }

  static DiseaseInfo _fallbackFor(String className) {
    final parts = className.split('___');
    final rawCrop = parts.isNotEmpty ? parts[0] : className;
    final rawCondition = parts.length > 1 ? parts[1] : '';

    final cropName = rawCrop.replaceAll('_', ' ').trim();
    final isHealthy = rawCondition.toLowerCase().contains('healthy');
    final diseaseName = isHealthy
        ? 'Healthy'
        : rawCondition.replaceAll('_', ' ').replaceAll('  ', ' ').trim();

    return DiseaseInfo(
      className: className,
      cropName: cropName.isEmpty ? 'Unknown crop' : cropName,
      diseaseName: diseaseName.isEmpty ? 'Unknown condition' : diseaseName,
      isHealthy: isHealthy,
      description: isHealthy
          ? 'This leaf shows no visible signs of disease.'
          : 'Detailed guidance for this specific condition is not in the app yet -- consult a local agricultural extension office for treatment advice.',
      organicTreatment: isHealthy ? const [] : const ['Consult a local agricultural extension office for treatment specific to this condition'],
      chemicalTreatment: isHealthy ? const [] : const ['Consult a local agricultural extension office before applying any chemical treatment'],
      preventionTips: const [
        'Keep monitoring regularly -- catching issues early makes treatment far more effective',
        'Rotate crops each season to reduce disease buildup in the soil',
      ],
    );
  }

  /// All class names covered with full, curated guidance -- used by the
  /// Treatment Info screen to group entries by crop.
  static List<DiseaseInfo> get curatedEntries => _entries.values.toList();
}
