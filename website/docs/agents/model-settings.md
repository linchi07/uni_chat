---
id: model-settings
title: Model Settings
description: How to configure models and parameters for your Agent
tags:
  - Agent
  - Model Setup
  - Basic Config
sidebar_position: 2
---

# Model Settings

An Agent requires a model to function. First, navigate to the Model tab and click "Add Model" to designate a model for the Agent.

:::tip

Depending on the Agent's role—such as an assistant or for role-playing—you may achieve better results by choosing different models. For instance, DeepSeek performs exceptionally well in role-playing situations.

:::

Generally speaking, you do not need to change the other limit settings. After selecting the actual model, they will automatically be padded according to UNIChat's built-in model presets.

### Passing Basic Model Information

This feature allows the model to be aware of certain basic information, specifically:
- **Current date and time** (ISO 8601 format): Useful for targeted replies, like wishing you a Happy New Year or keeping you company late at night...
- **Current OS and device info**: Allows it to tailor responses based on whether you are an macOS or Windows user when you ask technical questions.
- **User's language**: Prevents the model from stubbornly replying to you in a foreign language.

Usually, keeping this enabled by default is fine.

### Adjusting Model Parameters

(This feature is still under development...)
