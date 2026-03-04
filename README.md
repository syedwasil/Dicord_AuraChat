# 🌌 AuraChat

**A Premium, Privacy-Focused Real-Time Chat Experience**

AuraChat is a modern, high-performance messaging application built with Flutter. It combines a sophisticated, ultra-premium dark aesthetic with robust real-time communication features, designed for users who value both style and functionality.

---

## 🚀 The "Why"
In a world of cluttered and generic messaging apps, **AuraChat** was built to explore the intersection of **premium UX design** and **scalable real-time architecture**. The goal was to create a "digital community space" that feels refined, like a high-end lounge, while maintaining the technical rigor required for instant synchronization and high-quality voice data.

## ✨ Core Features
- **Real-Time Messaging**: Instant global synchronization powered by Cloud Firestore.
- **Crystal Clear Voice Channels**: High-fidelity, low-latency audio communication integrated via LiveKit.
- **Dynamic Community Servers**: Discord-inspired server and channel architecture for organized communities.
- **User Discovery**: Seamless friend searching and social integration.
- **Ultra-Premium Aesthetic**: A bespoke dark-mode design system with glassmorphism and smooth micro-animations.

## 🛠️ Tech Stack
- **Frontend**: [Flutter](https://flutter.dev) (Dart) - Cross-platform performance and UI flexibility.
- **State Management**: [Riverpod](https://riverpod.dev) - Robust, reactive, and testable state handling.
- **Backend/Database**: [Firebase](https://firebase.google.com) (Auth, Firestore, Storage).
- **Voice Infrastructure**: [LiveKit](https://livekit.io) - Modern WebRTC stack for real-time voice.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) - Declarative routing for complex app flows.

## 🧠 What I Learned
### Technical Challenge: State-Synchronized Voice Channels
Integrating LiveKit with Riverpod was the biggest challenge. Ensuring that the UI reflects the real-time "speaking" state across different tabs while managing room connections/disconnections required a deep dive into asynchronous programming and stream-based state management. 

### Key Takeaway
Building this project taught me the importance of **Clean Architecture**. By separating the data layer (Repositories) from the presentation layer (Providers/Widgets), I was able to implement complex features like voice messaging without making the codebase brittle.

---

## 🛠️ Local Setup

### Prerequisites
- Flutter SDK (latest stable version)
- A Firebase Project ([Firebase Console](https://console.firebase.google.com/))
- A LiveKit Cloud Project ([LiveKit Console](https://cloud.livekit.io/))

### Installation
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/flutter_aurachat.git
    cd flutter_aurachat
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Configure Firebase**:
    - Add your `google-services.json` (Android) to `android/app/`.
    - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`.
4.  **Configure LiveKit**:
    - Update the LiveKit URL in `lib/features/chat/presentation/providers/voice_provider.dart`.
5.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.
