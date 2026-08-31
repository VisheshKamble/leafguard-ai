# 🌿 LeafGuard AI

**Offline, on-device crop disease detection for farmers who can't count on internet access.**

LeafGuard is a Flutter app that lets a farmer photograph a crop leaf and get an instant disease diagnosis, severity read, and treatment recommendation — with the entire model running **on-device**, no connectivity required. It's built for the reality of rural agriculture in India, where the people who need this most often have a phone but not reliable signal.

![Status](https://img.shields.io/badge/status-in%20development-yellow)
![Platform](https://img.shields.io/badge/platform-Flutter-02569B?logo=flutter)
![Model](https://img.shields.io/badge/model-TFLite%20INT8-orange?logo=tensorflow)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## The Problem

Smallholder and small-scale farmers lose a significant share of crop yield every year to diseases that go undiagnosed until it's too late. Agricultural extension officers and lab testing aren't accessible in most rural areas, and existing plant-diagnosis apps typically require a constant internet connection to hit a cloud API — which breaks down exactly where it's needed most. LeafGuard closes that gap by shipping the diagnosis model itself onto the phone.

## Key Features

- 📸 **Photograph a leaf, get a diagnosis in seconds** — no upload, no waiting on a network round-trip
- 🌐 **Fully offline inference** — a quantized TFLite model runs locally on the device
- 🩺 **Treatment guidance** — organic and chemical treatment options, dosage, and prevention tips per disease
- 📖 **Scan history** — local-first storage of past scans, syncing to the cloud when connectivity is available
- 🌾 **Multi-crop support** — starting with tomato, potato, and corn, with room to expand

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| On-device inference | TensorFlow Lite (`tflite_flutter`), INT8 quantized |
| Model training | TensorFlow/Keras, MobileNetV3Large (transfer learning), trained on Kaggle |
| Backend / auth / sync | Supabase |
| Local storage | Hive / SQLite (offline-first scan history) |

## Model

- **Architecture:** MobileNetV3Large, ImageNet-pretrained, fine-tuned on leaf imagery — chosen specifically because it's designed for mobile latency/size budgets rather than raw benchmark accuracy
- **Dataset:** [New Plant Diseases Dataset](https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset) — an augmented version of PlantVillage, 38 disease classes across 14 crops, ~87K labeled leaf images
- **Training:** two-phase — frozen-base head training, then fine-tuning the top ~40 layers at a lower learning rate
- **Export:** INT8-quantized TFLite via a representative dataset, targeting a model under ~5MB

| Metric | Value |
|---|---|
| Validation accuracy (frozen base) | _TBD after training_ |
| Validation accuracy (fine-tuned) | _TBD after training_ |
| TFLite model size | _TBD_ |
| On-device inference latency | _TBD_ |
| Accuracy drop after quantization | _TBD_ |

*(This table gets filled in from the training notebook's evaluation and TFLite sanity-check cells — worth keeping front and center here since it's the first thing an interviewer will ask about.)*

## Project Structure

```
leafguard-ai/
├── README.md
├── LICENSE
├── docs/
│   ├── architecture.md
│   ├── model_card.md
│   └── screenshots/
├── notebooks/
│   └── leafguard_training.ipynb
├── model/
│   ├── leafguard_v1_int8.tflite
│   ├── labels.txt
│   └── model_metadata.json
├── app/                          # Flutter project root
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                 # constants, theme, utils
│   │   ├── models/                # scan_result, disease_info, user_profile
│   │   ├── services/              # tflite_service, supabase_service, local_storage_service, camera_service
│   │   ├── screens/                # auth, home, scan, results, history, treatment_info
│   │   ├── widgets/
│   │   └── providers/              # state management
│   ├── assets/
│   │   ├── model/                  # bundled .tflite + labels.txt
│   │   └── images/
│   └── pubspec.yaml
└── scripts/
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A Supabase project (free tier is enough for development)
- Android Studio / Xcode for platform builds

### Setup
```bash
git clone https://github.com/VisheshKamble/leafguard-ai.git
cd leafguard-ai/app
flutter pub get
```

Create a `.env` file (or configure `lib/core/constants/`) with your Supabase URL and anon key, then run:

```bash
flutter run
```

The trained TFLite model and `labels.txt` should be placed in `app/assets/model/` before building — see [Model Training](#model-training) below if you haven't generated them yet.

## Model Training

The full training pipeline lives in [`notebooks/leafguard_training.ipynb`](notebooks/leafguard_training.ipynb), built to run on Kaggle (free GPU tier — T4 x2 or P100):

1. Add the [New Plant Diseases Dataset](https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset) to a new Kaggle notebook via **Add Data**
2. Enable a GPU accelerator (Settings → Accelerator)
3. Upload and run `leafguard_training.ipynb` top to bottom
4. Download the exported `leafguard_v1_int8.tflite` and `labels.txt` from the notebook's Output panel
5. Copy both into `app/assets/model/`

## Roadmap

- [ ] Finish Flutter app skeleton (camera, results, history, treatment-info screens)
- [ ] Complete model training and log final metrics above
- [ ] Wire up on-device TFLite inference in `tflite_service.dart`
- [ ] Add multi-language support for regional-language treatment info
- [ ] Expand crop/disease coverage beyond the initial 3 crops
- [ ] Publish `model_card.md` with full accuracy/size/latency trade-off writeup

## Contributing

This is currently a solo portfolio project, but issues and suggestions are welcome — feel free to open one.

## License

MIT — see [LICENSE](LICENSE) for details.

## Author

**Vishesh Kamble**
GitHub: [@VisheshKamble](https://github.com/VisheshKamble)
