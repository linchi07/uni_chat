---
id: api-intro
title: 模型与 API 概览
description: 了解什么是 API 以及如何在 UNIChat 中配置它们
tags:
  - API
  - 模型设置
sidebar_position: 1
---

# 模型与 API

## 什么是 API？

API (Application Programming Interface) 是 UNIChat 与人工智能模型进行沟通的桥梁。

UNIChat 本身是一个**客户端**（Client），它就像是一个精美的浏览器或播放器。为了让你能够与 AI 进行对话，你需要连接到一个**服务端**（Server），也就是这里所说的 API。

想象一下：
- **UNIChat** 是你的手机。
- **API** 是电信运营商的信号塔。

只有插入了 SIM 卡（配置了 API Key），手机才能拨打电话（与 AI 对话）。

## 为什么要配置 API？

1. **灵活性**：你可以自由选择使用世界上最聪明的模型（如 GPT-4, Claude 3.5）还是最经济实惠的模型（如 DeepSeek, Gemini）。
2. **隐私与控制**：通过支持从本地或者自定义端点接入，你可以完全掌控数据流向，甚至可以在没有网络的情况下运行本地模型（如 Ollama）。
3. **成本效益**：直接使用模型供应商的 API 通常比订阅各类“套壳”服务要便宜得多，且按量付费，用多少付多少。

在接下来的章节中，我们将指导你如何获取并配置这些 API。
