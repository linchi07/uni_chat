---
id: custom-api
title: Custom API
description: How to connect local or third-party large model APIs in UNIChat
tags:
  - API
  - Custom Endpoints
  - Local Deployment
sidebar_position: 2
---

# Custom API

UNIChat natively supports all API interfaces compatible with the **OpenAI format**. This means that not only the official OpenAI, but the vast majority of modern model providers (like DeepSeek, Moonshot, SiliconCloud, etc.) and local inference frameworks (like vLLM) can be connected directly.

## How to Add

1. Go to **Settings** -> **API Setup**.
2. Click the **+ Add Provider** button at the top right, and select **Add Default Provider** at the bottom.
3. Fill in the following basic information:
    - **Name**: Give it a name you like (e.g., "My Local Server").
    - **API Type**: The type of API.
         - **OpenAI Completion (Legacy)**: The older OpenAI compatible API, which is used by the **vast majority of providers**.
         - **OpenAI Response**: The newer API format OpenAI pushes, currently **rarely used**.
    - **Endpoint**: The API server endpoint address. Do not include a trailing `/`.
        - Example: `https://api.deepseek.com/v1` or `http://localhost:1234/v1`.
        - **Pay special attention** to the preview below after filling it in, careful not to add an extra `v1` or `/`.
4. Enter the **API Key**
    - **API Key**: Your authentication key. For local services without authentication, write anything (e.g., `sk-123456`).
    - UNIChat supports automatic load balancing. When multiple keys are added, it will randomly pull an API Key for use. If one Key is throttled, it automatically looks for an available Key seamlessly. This is **entirely automatic** and requires no extra setup.
    - Advanced settings are used to manually control Token access rates, etc., which usually can be ignored; UniChat automatically switches to a suitable Key based on call results. If you want to ensure precise polling, you may fill this out.
5. **Add a Model**
    - Search for the model you want to add in the search box; it's generally there.
    - Next, input the model's call name on the add model page.
        - The model property settings below generally don't need changes unless your provider enforces specific interface restrictions. (For example, if the model natively supports picture input but your provider does not, you must alter this property.)
6. Click **Save**
