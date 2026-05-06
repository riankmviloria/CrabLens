# 🦀 CrabLens AI

CrabLens AI is a **Flutter-based mobile application** that uses AI image recognition to identify crab species and determine whether they are **safe to eat or potentially toxic**.

Built for coastal communities, seafood enthusiasts, and students, CrabLens helps users make **safer decisions when handling or consuming crabs**.

---

## 🚀 Features

* 📸 **Capture or Upload Images**

  * Use camera or gallery to scan crabs

* 🤖 **AI-Powered Identification**

  * Uses Google Vision API for image labeling & detection

* ⚠️ **Toxicity Detection**

  * Identifies **deadly poisonous crabs**
  * Highlights risk level (e.g. neurotoxins like Tetrodotoxin)

* 📚 **Offline Species Database**

  * Includes:

    * Scientific name
    * Local name
    * Habitat
    * Characteristics
    * Safety handling
    * First aid

* 🧠 **Smart Classification System**

  * Custom scoring logic:

    * Toxic crabs
    * Mud crabs (Alimango)
    * Blue swimming crabs (Alimasag)

* 🕘 **Scan History**

  * Stores previous scans using SharedPreferences

* 💡 **Daily Crab Facts**

  * Displays random educational facts

---

## 🧪 Supported Species

### ☠️ Toxic / Dangerous

* Atergatis floridus (Floral Egg Crab)
* Zosimus aeneus (Devil Crab)
* Platypodia granulosa (Xanthid Crab)
* Lophozozymus pictor (Mosaic Reef Crab)

### ✅ Edible

* Scylla serrata (Alimango / Mud Crab)
* Portunus pelagicus (Alimasag / Blue Crab)

---

## 🛠️ Tech Stack

* **Flutter (Dart)**
* **Google Vision API**
* **SharedPreferences (Local Storage)**
* **HTTP package**

---

## 📂 Project Structure

```
lib/
 ├── main.dart
 ├── screens/
 ├── widgets/
assets/
 └── icon/
```

---

## 🔧 Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/crablens.git
cd crablens
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add your API key

Replace the API key inside:

```dart
final String _apiKey = "YOUR_GOOGLE_VISION_API_KEY";
```

⚠️ **Important:** Never expose your API key in public repositories.

---

### 4. Run the app

```bash
flutter run
```

---

## 📱 Permissions Required

* Camera access
* Gallery / storage access

---

## ⚠️ Disclaimer

CrabLens AI is designed for **educational and assistance purposes only**.

* AI predictions are **not 100% accurate**
* Always consult **marine experts or local authorities**
* Never consume unknown species based solely on the app

---

## 🔐 Security Note

This project currently contains a **hardcoded API key**, which is not recommended for production.

For better security:

* Use environment variables
* Store keys securely (e.g. `.env`, backend proxy)

---

## 📌 Future Improvements

* 🔍 Custom-trained ML model (instead of Vision API)
* 🌐 Offline image classification
* 📊 More species coverage
* 📍 Location-based crab data
* 👥 Community reporting feature

---

## 👨‍💻 Author

Developed by **CrabLens Team**

---

## ⭐ Support

If you like this project, feel free to:

* ⭐ Star the repository
* 🍴 Fork it
* 🛠️ Contribute improvements

---

## 📄 License

This project is for educational use. Add a license if needed.
