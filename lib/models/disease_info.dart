/// Static reference info for one disease class the model can output.
/// This is the content that turns a raw classifier label into something a
/// farmer can actually act on.
class DiseaseInfo {
  final String className; // raw label from the model, e.g. "Tomato___Late_blight"
  final String cropName;
  final String diseaseName;
  final bool isHealthy;
  final String description;
  final List<String> organicTreatment;
  final List<String> chemicalTreatment;
  final List<String> preventionTips;

  const DiseaseInfo({
    required this.className,
    required this.cropName,
    required this.diseaseName,
    required this.isHealthy,
    required this.description,
    required this.organicTreatment,
    required this.chemicalTreatment,
    required this.preventionTips,
  });
}
