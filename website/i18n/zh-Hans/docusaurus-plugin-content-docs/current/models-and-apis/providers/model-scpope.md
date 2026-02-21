---
id: modelscope
title: 接入 ModelScope 魔搭
description: 如何在 UNIChat 中使用魔搭社区提供的免费调用额度
tags:
  - API提供商
  - 魔搭
  - ModelScope
sidebar_position: 4
---

# ModelScope 魔搭
如果你不想要充值，魔搭社区提供一定量的DeepSeek和Qwen以及kimi等模型的免费额度，是一个不错的选择，但是API偶发会抽风，这点要注意。
## 准备
- 一个中国大陆的手机号
- 一个中国二代身份证

## 获取 API Key

1. 访问 [魔搭社区](https://modelscope.cn)。
2. 完成注册，此时点击头像，应该会显示API额度，如果未显示，先认证。
3. 点击头像，进入用户中心。选择“访问控制”。
4. 获取长期访问令牌。

:::danger
请勿泄露访问令牌！
:::

## 在 UNIChat 中配置

1. 打开 UNIChat 设置 -> API设置 -> 添加提供商。
2. 找到预设的 **魔搭** 卡片
3. 在 APIkey设置 中 添加上一步获取的访问令牌。
4. 保存。
