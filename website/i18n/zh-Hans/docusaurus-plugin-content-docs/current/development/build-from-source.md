# 从源码构建 (Build from Source)

本文档将指导你如何在本地机器上从源码编译并运行 UNIChat。

## 🛠️ 环境要求

在开始之前，请确保你的开发环境满足以下要求：

1. **Flutter SDK**: 建议使用 **Channel stable 3.35.5**。
   - 这也是目前我们在开发和测试环境中所使用的版本，使用其它版本可能会遇到不可预见的问题。
2. **特定平台构建工具**:
   - **macOS / iOS**: 需要安装 Xcode（推荐最新正式版）和 CocoaPods。
   - **Windows**: 需要安装 Visual Studio 2022（包含 C++ 桌面开发工作负载）。
   - **Android**: 需要安装 Android Studio 及 Android SDK。

## 📦 获取源码与依赖

1. **克隆代码库**:
```bash
git clone https://github.com/linchi07/uni_chat.git
cd uni_chat/app
```

2. **获取依赖包**:
```bash
flutter pub get
```

## ⚙️ 代码生成 (Code Generation)

UNIChat 大量使用了如 `drift` (数据库) 和 `riverpod` (状态管理) 等需要代码生成的库。在构建或运行应用之前，**必须**先运行代码生成器：

```bash
dart run build_runner build -d
```
> *提示：`-d` (或 `--delete-conflicting-outputs`) 参数可以确保在生成新代码时删除旧的冲突文件。*

## 🚀 运行与编译

代码生成完成后，你可以正常运行或编译应用了。

### 本地开发运行
运行桌面端（以 macOS 为例）：
```bash
flutter run -d macos
```
:::tip
在iOS运行或安装时请特别注意
将iPhone通过**有线**连接到电脑，然后在Xcode中选择iPhone设备，
在命令行输入 flutter run -- release

然后选择你的手机。此处的release是**必须的**，否则的话app将无法在脱离电脑后运行！
:::
