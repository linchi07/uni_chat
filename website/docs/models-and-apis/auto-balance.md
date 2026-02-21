---
id: auto-balance
title: Auto-Scheduling & Load Balancing
description: Learn about UNIChat's intelligent API scheduling system and High Availability solutions
tags:
  - API
  - Load Balancing
  - Advanced Scheduling
sidebar_position: 3
---

# API Key Management and Auto-Scheduling Mechanism

To ensure stability and responsive speeds in high-frequency scenarios, UNIChat has built a smart API scheduling system. All you need to do is configure the keys; UNIChat handles the rest.

## 1. Entering API Keys and Basic Configuration

When adding a model service provider, you must provide authentication credentials:

**API Key**: Your core authentication key.

**Online Services**: Enter the `sk-...` key acquired from official websites like OpenAI, Claude, or DeepSeek.

**Local Services**: If you connect to local services with no authentication rules like Ollama or LM Studio, you can fill anything here (e.g., `sk-123456` or `local`).

**Multi-Key Support**: UNIChat allows you to add multiple API Keys for the same provider, forming the foundation of High Availability (HA).

## 2. Intelligent Load Balancing

When you configure multiple API Keys for a model, UNIChat automatically activates load balancing mode:

**Random Polling Strategy**: The system won't repeatedly lock onto a single Key; instead, it utilizes algorithms to randomly poll amongst the multiple available Keys.

**Advantage**: This effectively distributes traffic pressure off single Keys, reducing the liability of triggering provider Rate Limits and improving concurrent processing capability.

## 3. Failover & 429 Auto-Backoff

The most common problem during AI drawing tasks or high-frequency chatting is the provider returning a `429 Too Many Requests` error. UNIChat implements complete protective mechanisms against this:

**Silent Retries**: When a Key hits its quota (Rate Limit) or encounters a response timeout, UNIChat won't interrupt your chat.

**Auto-Skip**: The system auto-identifies ineffective Keys and immediately looks for other available Keys in the queue to process the request.

**Backoff Protection**: For Keys that triggered limits, the system temporarily places them in "cooldown", re-adding them to the polling pool once they recover. All of this is done fully automatically in the background.

## 4. Advanced Rate Control (TPM/RPM Management)

For advanced users requiring precise control, we provide manual rate configurations under "Advanced Settings":

**Core Metrics**:
- **TPM (Tokens Per Minute)**: Maximum allowed Tokens consumed per minute.
- **RPM (Requests Per Minute)**: Maximum allowed requests initiated per minute.
- **Daily Limit**: Prevents accidental exhaustion of account quota.

**Smart Switching Logic**: Even if you leave this empty, UNIChat dynamically adjusts polling frequency based on telemetry returned from API calls (such as rate limit headers).

**Advice**: If you wish to ensure the absolute precision of multi-Key polling (e.g., you own several accounts of differing tiers), entering official quota limits here turns them into optimal bench marks. UNIChat will govern scheduling according to these exact values.

In UNIChat, the guiding principle of API Management is "Minimal Configuration, High Performance". For the vast majority of users, simply inputting the collected API Keys is enough for the system to construct a zero-downtime, auto-scaling private API cluster for you.

## Future Outlook
During development and testing, I discovered different providers wield different API routing strategies. Naturally, when throwing errors like 429, the error responses vary. Given this, the ideal scheduling mechanism is swapping strategies built per specific provider presets. Currently, a universal scheduling strategy operates in the code, but I've already set aside the relevant classes. Adding a new strategy only requires extending and overriding. More scheduling strategies will populate over time. If you wish to contribute a mapping of your own strategy, you're welcome to submit an issue! (≧∇≦)
