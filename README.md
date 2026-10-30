# طابوري (Taboori) - Hospital Queue & Bed Management System

Taboori is a modern Flutter application designed for the Egyptian Healthcare system. It provides real-time management of hospital queues, emergency room (ER) waiting lists, and critical bed availability (ICU, Incubators, Ventilators) across government hospitals.

## 🚀 Key Features

*   **For Patients:** 
    *   Book queue turns remotely to avoid crowding.
    *   Real-time tracking of "People ahead of you" and "Estimated wait time."
    *   Digital QR Ticket for touchless check-in at the hospital.
    *   Live view of available ICU beds and Incubators in nearby hospitals.
*   **For Hospital Staff:**
    *   Manage live queues (Call next patient, mark as completed/absent).
    *   QR Scanner for rapid patient check-in at reception.
    *   Live update of bed occupancy rates.
*   **For Ministry of Health (Admin):**
    *   Centralized dashboard with analytics for all governorates.
    *   Critical shortage alerts (e.g., ICU bed capacity warnings).

---

## 🛠 Developer Setup Guide

Follow these steps one by one to set up the project on your machine.

### 1. Prerequisites
*   **Flutter SDK:** [Install Flutter](https://docs.flutter.dev/get-started/install) (v3.11.5 or higher recommended).
*   **Java:** JDK 17 required for Android builds.
*   **Firebase Account:** A project created on the [Firebase Console](https://console.firebase.google.com/).

### 2. Clone the Project
```bash
git clone https://github.com/paulamer/tabory-hospital.git
cd hospital
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Firebase Configuration (Mandatory)
The app uses Firebase for Auth and Firestore. To connect your own backend:
1.  **Install Firebase CLI:** `npm install -g firebase-tools`
2.  **Login:** `firebase login`
3.  **Activate FlutterFire:** `dart pub global activate flutterfire_cli`
4.  **Configure:** `flutterfire configure`
    *   Select your Firebase project.
    *   Select `android` and `ios`.
    *   This will generate `lib/firebase_options.dart` and `android/app/google-services.json`.

### 5. Create Firestore Indexes
The app uses complex queries for the dashboards. You **must** create composite indexes in your Firebase Console. 
*   **Easy Way:** Run the app on a device. When you open the Patient or Staff dashboard, a link will appear in the debug console/logs. Click that link to auto-generate the required index.
*   **Manual Way:** Create an index for the `queues` collection:
    *   Fields: `patientId` (Ascending), `createdAt` (Descending).
    *   Fields: `hospitalId` (Ascending), `departmentId` (Ascending), `createdAt` (Ascending).

---

## 📱 How to Install the APK (For Users)

If you just want to test the app on your Android phone:

1.  **Download the APK:** [**Click here to download Taboori v1.0.0 (Fixed)**](https://github.com/paulamer/tabory-hospital/releases/latest)
2.  **Enable Unknown Sources:** Go to `Settings > Security` and allow installation from "Unknown Sources" or your browser.
3.  **Install:** Open the `.apk` file and tap **Install**.
4.  **Important Requirements:**
    *   **National ID:** You must enter a valid **14-digit** Egyptian National ID to register.
    *   **Internet:** The app requires an active internet connection to sync queue data.

---

## 🏗 Building from Source

To generate a new APK yourself:
```bash
flutter build apk --release
```
The file will be located at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing with Mock Data
If you don't have Firebase set up yet, the app has a built-in **Mock Mode**. If the app fails to initialize Firebase, it will automatically switch to a local mock repository so you can still browse the UI and test the booking flow.

---

## 📝 Localization
The app fully supports **Arabic (Default)** and **English**. You can toggle the language from the top-right corner of the login screen or the dashboard.

## 👥 Authors & Team
* **Paula Amer Gerges** & **Retaj**
* Faculty of Engineering at Shoubra — Benha University
* Computer & Communications Engineering • Graduation Project 2026

## 📄 License
This project is developed as the official Graduation Project for the Faculty of Engineering at Shoubra, Benha University (2026).
