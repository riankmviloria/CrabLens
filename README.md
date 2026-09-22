# 🦀 CrabLens

### Crab Classification Using TensorFlow Lite

CrabLens AI is a mobile application designed to identify crab species using an **on-device TensorFlow Lite image classification model**. The application allows users to capture or select an image of a crab and receive an AI-generated species prediction, confidence score, species information, and safety classification.

The project was developed as an academic/thesis project with a focus on **mobile AI, image classification, species identification, and crab safety awareness**.

---

## 📱 About CrabLens

CrabLens provides a simple and accessible way to identify selected crab species using artificial intelligence.

Instead of relying on cloud-based image recognition services, CrabLens uses a **TensorFlow Lite model directly on the device**, allowing image classification to work without sending the user's crab images to an external vision API.

### Core capabilities

* 🦀 AI-powered crab species identification
* 📷 Image capture using the device camera
* 🖼️ Image selection from the gallery
* 🧠 TensorFlow Lite on-device classification
* 📊 AI confidence score
* 📚 Species information database
* ⚠️ Toxicity and safety awareness
* 🟢 Edible / potentially edible classification
* 🔴 Potentially toxic species warning
* 📝 Scan history
* 📱 Mobile-friendly Flutter interface
* 🔌 Offline species information
* 💾 Local history storage using SharedPreferences

---

## 🧠 Artificial Intelligence

CrabLens uses a **TensorFlow Lite (`.tflite`) image classification model** for crab identification.

### Model

```text
assets/model/model_unquant.tflite
```

Class labels are stored in:

```text
assets/model/labels.txt
```

The model performs image classification directly on the user's device.

### Why TensorFlow Lite?

Using TensorFlow Lite provides several advantages:

* On-device inference
* No external vision API required
* Reduced network dependency
* Faster classification
* Improved privacy
* Suitable for mobile deployment
* Can operate without an internet connection

The model was trained for crab-species classification and integrated into the Flutter application for real-time image analysis.

---

## 🦀 Supported Crab Species

CrabLens currently supports the following species/classes:

| Common Name       | Scientific Name           |
| ----------------- | ------------------------- |
| Alimango          | *Scylla serrata*          |
| Alimasag          | *Portunus pelagicus*      |
| Devil Crab        | *Zosimus aeneus*          |
| Mosaic Crab       | *Lophozozymus pictor*     |
| Floral Egg Crab   | *Atergatis floridus*      |
| Xanthid Crab      | *Platypodia granulosa*    |
| Seven Eleven Crab | *Carpilius maculatus*     |
| Purple Mud Crab   | *Scylla tranquebarica*    |
| Three-Spot Crab   | *Portunus sanguinolentus* |
| Spanner Crab      | *Ranina ranina*           |
| Mangrove Crab     | *Thalamita crenata*       |
| Orange Mud Crab   | *Scylla olivacea*         |
| Crucifix Crab     | *Charybdis feriata*       |

> Species support may be expanded as additional training data and model classes are added.

---

## ⚠️ Safety Classification

CrabLens includes a safety-awareness feature to help users distinguish between commonly consumed crab species and species that may be potentially toxic.

### Generally considered edible / commonly consumed

* Alimango
* Alimasag
* Purple Mud Crab
* Three-Spot Crab
* Spanner Crab
* Mangrove Crab
* Orange Mud Crab
* Crucifix Crab

### Potentially toxic / not recommended for consumption

* Devil Crab
* Mosaic Crab
* Floral Egg Crab
* Xanthid Crab
* Seven Eleven Crab

### Important Safety Disclaimer

**CrabLens is an educational and identification tool only.**

An AI prediction does not guarantee the identity, edibility, or safety of a crab.

Users should **never consume a crab solely because CrabLens identifies it as edible**. Species identification can be affected by image quality, lighting, crab orientation, physical variation, model limitations, and similarities between species.

When dealing with potentially poisonous or unfamiliar crab species, consult qualified local experts or appropriate fisheries/marine authorities.

---

## 🏗️ Technology Stack

### Frontend

* Flutter
* Dart
* Material Design

### Artificial Intelligence

* TensorFlow Lite
* Image classification
* Custom-trained classification model

### Local Storage

* SharedPreferences

### Development

* Android Studio / Visual Studio Code
* Flutter SDK
* Dart SDK
* Git
* GitHub

---

## 📂 Project Structure

```text
CrabLens/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│   ├── icon/
│   │   └── app_icon.png
│   │
│   └── model/
│       ├── labels.txt
│       └── model_unquant.tflite
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_colors.dart
│   │   │
│   │   └── data/
│   │       ├── crab_database.dart
│   │       └── crab_facts.dart
│   │
│   ├── models/
│   │   └── crab_info.dart
│   │
│   ├── screens/
│   │   ├── about_screen.dart
│   │   ├── crab_detail_screen.dart
│   │   ├── dashboard_page.dart
│   │   ├── history_screen.dart
│   │   ├── home_screen.dart
│   │   └── splash_screen.dart
│   │
│   ├── services/
│   │   └── tflite_service.dart
│   │
│   ├── utils/
│   │   └── crab_classifier.dart
│   │
│   └── main.dart
│
├── test/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

---

## 🔄 Application Flow

```text
                    ┌─────────────────┐
                    │    CrabLens     │
                    │     Launch      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Home Screen  │
                    └────────┬────────┘
                             │
                     Capture / Select
                             │
                             ▼
                    ┌─────────────────┐
                    │   Crab Image    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ TensorFlow Lite │
                    │    Inference    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Species Result  │
                    │ + Confidence    │
                    └────────┬────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │ Species Information  │
                  │ + Safety Information │
                  └──────────┬───────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  Save to Local  │
                    │     History     │
                    └─────────────────┘
```

---

## 📱 Main Application Screens

### Home

The main entry point of CrabLens where users can start the identification process.

### Crab Identification

Users can provide a crab image using the camera or device gallery.

### AI Result

The application displays:

* Predicted crab species
* Confidence percentage
* Crab image
* Common name
* Scientific name
* Safety classification

### Crab Details

Provides additional information about the identified species, including:

* Species description
* Scientific classification
* Local/common names
* Identification information
* Safety information

### History

Previously analyzed crabs are stored locally so users can review their previous scans.

### About

Provides information about CrabLens, the AI technology, supported species, project information, and safety disclaimer.

---

## 💾 Local Data Storage

CrabLens does not require user registration or an online account.

Scan history is stored locally using:

```text
SharedPreferences
```

This allows previous scan results to remain available on the user's device without requiring a backend server.

---

## 🔒 Privacy

CrabLens is designed around local processing.

The TensorFlow Lite model performs classification directly on the device. Crab images do not need to be uploaded to a cloud-based image recognition service for classification.

The application does not require:

* User accounts
* Passwords
* Cloud database accounts
* External vision APIs

---

## ⚙️ Requirements

Before running the project, install:

* Flutter SDK
* Dart SDK
* Android Studio or Visual Studio Code
* Android SDK for Android development
* Xcode for iOS development on macOS

Verify Flutter installation:

```bash
flutter doctor
```

---

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/riankmviloria/CrabLens.git
```

Enter the project directory:

```bash
cd CrabLens
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To check connected devices:

```bash
flutter devices
```

---

## 🧪 Testing

Before deployment, CrabLens should be evaluated using representative images from each supported species.

Testing should consider:

* Different lighting conditions
* Different crab orientations
* Different backgrounds
* Different image distances
* Different crab sizes
* Partial visibility
* Similar-looking species
* Low-quality images

### AI evaluation metrics

For formal model evaluation, the following metrics may be used:

* Accuracy
* Precision
* Recall
* F1-score
* Confusion matrix

These metrics should be calculated using a test dataset that is separate from the training dataset.

---

## ⚠️ Current Limitations

CrabLens has several limitations:

1. The AI model can only classify species included in its training classes.
2. Similar-looking species may be difficult to distinguish.
3. Prediction accuracy depends on image quality.
4. Poor lighting may affect classification.
5. Occluded or partially visible crabs may produce incorrect predictions.
6. AI confidence does not guarantee correct identification.
7. The application should not be used as the sole basis for determining whether a crab is safe to eat.
8. The current model may require additional training data to improve generalization.

---

## 🔮 Future Enhancements

Potential future improvements include:

* Additional crab species
* Larger and more diverse training datasets
* Improved model accuracy
* Model evaluation and benchmarking
* Confusion matrix visualization
* Improved species comparison
* More detailed geographic information
* Habitat information
* Crab size estimation
* Improved image preprocessing
* Model version management
* User feedback for incorrect predictions
* Cloud-based model update system
* Research dataset management
* Expert-verified species information

---

## 🎓 Academic Project

CrabLens AI was developed as an academic/thesis project demonstrating the practical application of:

* Artificial Intelligence
* Machine Learning
* Image Classification
* TensorFlow Lite
* Mobile Application Development
* Flutter
* Local Data Storage
* Species Identification
* Safety Awareness

### Project Team

* Eli Edon
* Anthony Eglesias
* Hero Elayda
* Cresza Joy Mojar
* Jhapil Taneo

---

## 📄 Documentation

Additional project documentation covers:

* Project overview
* Problem statement
* Objectives
* Scope and limitations
* System architecture
* AI model
* Supported species
* Application flow
* Data storage
* Safety handling
* Installation
* Testing
* Future enhancements

---

## 🦀 About the Name

**CrabLens** combines:

> **Crab + Lens**

The name represents using a camera lens together with artificial intelligence to help identify crab species.

---

## 📌 Project Status

**Version:** 1.0.0

**Status:** Active Development

CrabLens is currently being developed and improved as an academic/thesis project.

---

## ⚖️ Disclaimer

CrabLens AI is intended for **educational, research, and informational purposes only**.

The application and its AI model may produce incorrect predictions. Species identification should be independently verified, particularly when determining whether a crab is safe for consumption.

The developers are not responsible for injury, poisoning, illness, loss, or other consequences resulting from reliance on CrabLens predictions.

**When in doubt, do not consume the crab.**

---

## 📜 License

This project is developed for academic and educational purposes.

All rights reserved by the project authors unless otherwise stated.
