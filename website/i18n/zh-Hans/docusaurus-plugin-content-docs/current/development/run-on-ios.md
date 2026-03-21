---
id: run-on-ios
title: 在 iOS 设备上运行
description: 如何通过源码构建在 iPhone 或是 iPad 上运行 UNIChat
tags:
  - 安装
  - iOS
  - iPadOS
sidebar_position: 1
---

# 在苹果设备（iOS 或 iPadOS）上运行 UNIChat

由于本作者没有 99 美刀的苹果开发者账号，因此无法将应用上架 App Store。

**目前我们不再提供 IPA 文件下载。** 如果你想在 iOS 设备上使用 UNIChat，目前唯一的方案是**从源码构建**并利用 Xcode 在本地机器上安装。

### 🛠️ 安装步骤

请参考我们的 **[从源码构建](./build-from-source.md)** 指南了解详细步骤。

简而言之，你需要：
1. 一台安装了 **Xcode** 的 Mac。
2. 配置好 **Flutter SDK**。
3. 通过**有线连接**你的设备，并运行 `flutter run --release`。

:::tip
UNIChat 在我的 iPhone 13 mini 和 iPad Pro 上均经过了测试（我自己每天都在用）。
理论上它在 iOS 设备上运行良好。如果你遇到任何问题，欢迎到 GitHub 提 issue 或者在交流群里反馈。
 ![GitHub](https://github.com/linchi07/uni_chat)
:::
