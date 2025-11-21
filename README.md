# 🧵 Loom

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)

**A real-time social media application built for seamless connection and instant engagement**

[Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 📖 About

Loom is a modern, real-time social media platform designed to prioritize immediacy and meaningful user interaction. Built with Flutter and powered by Firebase, Loom delivers a dynamic social experience across Android, iOS, and Web platforms. Share moments, engage with content, and connect with others—all in real-time.

## ✨ Features

- **⚡ Real-Time Updates** - Experience instant content delivery with Firebase real-time synchronization
- **💬 Interactive Engagement** - Connect through comments, reactions, and rich media sharing
- **🌐 Cross-Platform** - Native experience on Android, iOS, and Web from a single codebase
- **🎨 Modern UI/UX** - Clean, intuitive interface designed for effortless navigation
- **🔐 Secure Authentication** - Firebase Authentication for secure user management
- **📱 Responsive Design** - Optimized for all screen sizes and devices
- **☁️ Cloud Storage** - Reliable media storage and retrieval via Firebase

## 🎯 Tech Stack

- **Frontend**: Flutter & Dart
- **Backend**: Firebase (Firestore, Authentication, Cloud Storage)
- **Native**: Kotlin (Android), Swift (iOS)
- **Web**: HTML5, CSS3, JavaScript

## 📋 Prerequisites

Before getting started, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0 or higher)
- Dart SDK (bundled with Flutter)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- [Firebase account](https://console.firebase.google.com/)
- Git

### System Requirements

- **macOS**: 10.14 or later (for iOS development)
- **Windows**: Windows 10 or later
- **Linux**: Ubuntu 18.04 or later
- **Disk Space**: 2.8 GB minimum

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/peashdasrudra/Loom-.git
cd Loom-
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" and follow the setup wizard
3. Enable the following services:
   - Authentication (Email/Password, Google Sign-In)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Functions (optional)

#### Android Configuration

1. Register your Android app in Firebase Console
2. Download `google-services.json`
3. Place it in `android/app/`
4. Ensure your `android/app/build.gradle.kts` includes:

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

#### iOS Configuration

1. Register your iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Add the `.plist` file to the Runner target

#### Web Configuration

1. Register your Web app in Firebase Console
2. Copy the Firebase configuration
3. Update `web/index.html` with your Firebase config

### 4. Run the Application

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome

# All available devices
flutter devices
flutter run -d <device-id>
```

## 💻 Usage

### Basic Example

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Fetch user data
Future<DocumentSnapshot> getUserData(String userId) async {
  return await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();
}

// Create a post
Future<void> createPost(String content, String userId) async {
  await FirebaseFirestore.instance.collection('posts').add({
    'content': content,
    'userId': userId,
    'timestamp': FieldValue.serverTimestamp(),
    'likes': 0,
  });
}

// Real-time post updates
Stream<QuerySnapshot> getPostsStream() {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('timestamp', descending: true)
      .snapshots();
}
```

### Authentication Example

```dart
import 'package:firebase_auth/firebase_auth.dart';

// Sign up
Future<UserCredential> signUp(String email, String password) async {
  return await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);
}

// Sign in
Future<UserCredential> signIn(String email, String password) async {
  return await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
}

// Sign out
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}
```

## ⚙️ Configuration

### Theme Customization

Modify the app theme in `lib/main.dart`:

```dart
ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  // Add your custom theme properties
)
```

### Firebase Rules

Configure Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## 📁 Project Structure

```
Loom-/
├── android/                 # Android native code
│   └── app/
│       ├── build.gradle.kts
│       └── google-services.json
├── ios/                     # iOS native code
│   └── Runner/
│       └── GoogleService-Info.plist
├── lib/                     # Flutter application code
│   ├── main.dart
│   ├── models/             # Data models
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable widgets
│   ├── services/           # API & Firebase services
│   └── utils/              # Helper functions
├── web/                     # Web specific files
│   └── index.html
├── test/                    # Unit and widget tests
├── pubspec.yaml            # Dependencies
└── README.md
```

## 🧪 Testing

Run tests using:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Coverage report
flutter test --coverage
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before committing
- Format code using `flutter format .`

## 📝 TODO

See [TODO.md](TODO.md) for upcoming features and improvements.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) - For the amazing cross-platform framework
- [Firebase Team](https://firebase.google.com/) - For powerful backend services
- All contributors who have helped shape this project

## 📞 Contact & Support

- **GitHub**: [@peashdasrudra](https://github.com/peashdasrudra)
- **Issues**: [Report a bug or request a feature](https://github.com/peashdasrudra/Loom-/issues)

---

<div align="center">

Made with ❤️ by [Peash Das Rudra](https://github.com/peashdasrudra)

⭐ Star this repo if you find it helpful!

</div>
