---
id: google-gemini
title: 接入 Google Gemini
description: 在 UNIChat 中配置及使用 Google AI Studio
tags:
  - API提供商
  - Google
  - Gemini
sidebar_position: 3
---

# Google 谷歌
这里的教程是谷歌AiStudio版本的，不是Vercel的。
谷歌AiStudio提供一些免费的额度，可以尝试。

:::note

曾经AIStudio给额度非常大方，但是最近谷歌大幅度缩减额度。
目前已经没有Gemini 3 Pro的免费额度，每个免费账号只提供2每日0次左右的Gemini 3 Flash的调用机会。
实在想舒服的用Gemini的话还是需要绑卡的，或者考虑Google cloud的300美元赠金。

:::

## 准备

- 一个稳定的谷歌账号
- 能流畅访问到谷歌（香港不可，部分新加坡地区也不可）

## 获取 API Key
1. 访问 [AiStudio](https://aistudio.google.com/)并且登录。
2. 点击Get API Key 按钮。并且点击获取APIkey
3. 在下面的项目选择中，选择创建项目。创建一个新的项目，然后将APIkey绑定到该项目，完成创建。
4. 点击创建好的APIkey，复制里面的APIkey，保留备用。

:::danger

创建的 API Key，请勿泄露。

:::

## 在 UNIChat 中配置

1. 打开 UNIChat 设置 -> API设置 -> 添加提供商。
2. 找到预设的 **谷歌** 卡片
3. 在 APIkey设置 中 添加上一步获取的API Key。
4. 保存。
