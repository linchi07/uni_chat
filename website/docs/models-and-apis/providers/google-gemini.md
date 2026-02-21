---
id: google-gemini
title: Connect to Google Gemini
description: Configure and use Google AI Studio natively inside UNIChat
tags:
  - API Provider
  - Google
  - Gemini
sidebar_position: 3
---

# Google

This tutorial explicitly charts the route surrounding Google **AiStudio**, distinguishing it from Vercel frameworks.
Google AiStudio grants users a fixed tier of free quotas to trial.

:::note

Historically, AiStudio extended quite a generous boundary on quotas. Recently, Google notably compressed these lines.
Currently, zero instances for Gemini 1.5 Pro remain freely reachable; basic complimentary accounts merely hold roughly a 20 per day invocation cap towards Gemini 1.5 Flash.
If you desire a substantial threshold to use Gemini properly, attaching a credit card or considering Google Cloud's complimentary $300 promo is essential.

:::

## Preparation

- A stable Google account.
- The logistical capability to ping Google unimpeded (Certain regional exit nodes, specifically Hong Kong and specific sectors inside Singapore, are non-viable).

## Obtain an API Key
1. Venture to [AiStudio](https://aistudio.google.com/) and authorize your Google login credentials.
2. Press the "Get API Key" command button and navigate down to acquire the API Key.
3. Lower in the project hierarchy overlay, elect to "Create Project". After instantiating a fresh project, securely bind the API Key inside it.
4. Look at the formalized API Key and clone its string payload onto your clipboard for the steps below.

:::danger

The generated API Key must remain securely vaulted. Never leak it.

:::

## Configure within UNIChat

1. Engage UNIChat Settings -> API Setup -> Add Provider.
2. Filter through options and find the **Google** preset module block.
3. In the API Key configuration section, insert the authorization key generated from stage one.
4. Save.
