# Build from Source

This document will guide you on how to compile and run UNIChat from source on your local machine.

## 🛠️ Prerequisites

Before you begin, ensure your development environment meets the following requirements:

1. **Flutter SDK**: Use **Channel stable 3.35.5** (recommended).
   - This is the version we use in our development and testing environments. Using other versions may lead to unforeseen issues.
2. **Platform-Specific Build Tools**:
   - **macOS / iOS**: Requires Xcode (latest stable version recommended) and CocoaPods.
   - **Windows**: Requires Visual Studio 2022 (with "Desktop development with C++" workload).
   - **Android**: Requires Android Studio and Android SDK.

## 📦 Getting Source Code and Dependencies

1. **Clone the repository**:
```bash
git clone https://github.com/linchi07/uni_chat.git
cd uni_chat/app
```

2. **Get dependencies**:
```bash
flutter pub get
```

## ⚙️ Code Generation

UNIChat makes extensive use of libraries like `drift` (database) and `riverpod` (state management) which require code generation. Before building or running the app, you **must** run the code generator:

```bash
dart run build_runner build -d
```
> *Tip: The `-d` (or `--delete-conflicting-outputs`) flag ensures that old conflicting files are deleted when generating new code.*

## 🚀 Running and Compiling

Once code generation is complete, you can run or compile the application.

### Local Development Run
Run the desktop version (e.g., macOS):
```bash
flutter run -d macos
```

:::tip
**Special Note for iOS Support**:
Since we do not provide pre-signed IPA files, you must build and install the app manually using Xcode:
1. Connect your iPhone to your computer via **cable**.
2. Open the project in Xcode (located in `ios/Runner.xcworkspace`).
3. Select your iPhone as the deployment target.
4. Run the following command in your terminal:
   ```bash
   flutter run --release
   ```
5. Select your device. The `--release` flag is **REQUIRED** for the app to function after being disconnected from the computer.
:::
