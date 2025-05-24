# gcalc

GoldCalc (gcalc) is a Flutter-based gold price calculator app. It helps users calculate the total price of gold coins and ornaments based on the current 22k gold rate, weight, purity, and making charges. The app fetches live gold prices from Firebase Firestore and provides a detailed price breakdown including GST.

**Hosted App:** [https://gcalc-e45c3.web.app/](https://gcalc-e45c3.web.app/)

## Features
- Live 22k gold price fetch from Firestore
- Editable gold price field for custom calculations
- Supports gold coins and ornaments
- Purity selection (24k, 22k, 18k, 14k, 12k, 10k)
- Making charge presets and custom slider
- Instant calculation and detailed price breakup
- Responsive UI for mobile and desktop

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Firebase project (for live gold price)

### Setup
1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd gcalc
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Firebase setup:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS/web apps as needed
   - Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) and place them in the respective folders
   - Update `lib/firebase_options.dart` using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
   - Make sure Firestore is enabled and a `gprice` collection exists

### Running the App
- **Android/iOS:**
  ```sh
  flutter run
  ```
- **Web:**
  ```sh
  flutter run -d chrome
  ```
- **Desktop (macOS/Linux/Windows):**
  ```sh
  flutter run -d <device>
  ```

## Firestore Data Structure
- Collection: `gprice`
- Document fields:
  - `price` (number): Current 22k gold price per gram
  - `updated_time` (timestamp): Last update time

## License
MIT License
