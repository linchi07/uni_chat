---
id: modelscope
title: Connect to ModelScope
description: Discover how to tap into free inference blocks utilizing the ModelScope API inside UNIChat
tags:
  - API Provider
  - ModelScope
sidebar_position: 4
---

# ModelScope
Should you desire to avoid topping up account balances arbitrarily, the ModelScope community yields a finite spectrum of non-paid quotas targeting models such as DeepSeek, Qwen, and Kimi—positioning it as a spectacular alternative. Be advised, however, that sporadically, the community API route suffers from spotty uptime.

## Preparation
- A Chinese mainland phone number.
- A Chinese second-generation ID card string.

## Obtain an API Key

1. Navigate to [ModelScope](https://modelscope.cn).
2. After finalizing an account, clicking your user profile avatar ought to immediately project your active API quota. If the indicator reads missing, attempt authentication protocols.
3. Puncture the avatar to traverse into User Center settings. Identify and tap "Access Control".
4. Solicit a Long-Term Access Token parameter.

:::danger
Never carelessly leak the access parameters provided above!
:::

## Configure within UNIChat

1. Crack open UNIChat Settings -> API Setup -> Add Provider.
2. Isolate the predefined **ModelScope** widget.
3. Inside the designated API Key zone, inject the authorization string synthesized via ModelScope.
4. Lock it down utilizing Save.
