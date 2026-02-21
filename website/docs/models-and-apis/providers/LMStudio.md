---
id: lmstudio
title: Connect to LMStudio
description: How to integrate locally running LMStudio as a service provider into UNIChat
tags:
  - API Provider
  - LMStudio
  - Local Deployment
sidebar_position: 1
---

# LMStudio
LMStudio is an integrated software application letting you run Large Language Models locally.
This guide introduces how to integrate LMStudio into UNIChat as a service provider.

## Preparation

- A computer with sufficient VRAM (NVIDIA graphics cards recommended, or Apple Silicon Macs perform well, too). It doesn't have to be the exact same device that UNIChat relies on.

:::tip
Ensure your computer has adequate VRAM.

Taking Q4KM quantized models as examples:
| Model | VRAM | Context |
| --- | --- |   --- |
| 7B | 7.5G |   ~4096 |
| 14B | 16G |   ~10000|
| 32B | 24G |   ~6500 |
| 30B/33B | 24G |   ~32000 |

This can be handled via multiple GPUs acting in parallel or unified memory architectures like on Mac.

:::

## Configure LMStudio
1. Visit [LMStudio](https://lmstudio.ai/) and download the app.
2. Install it, and following LMStudio's guidance, download your preferred models.
3. Switch to Developer mode. Then click the green terminal icon on the far left.
4. On the opened interface, click settings and toggle all switches on. Also, make sure the left-side status reads "Running".
5. Click the red model icon on the left navigation bar. Keep this model page open for reference.

:::danger

This guide assumes your computer is not directly connected to a public network.
If your machine has a direct public IP address, please be extremely cautious: **do not expose these ports directly to the internet**.

:::

:::tip

If you plan on hooking into LMStudio resting on a DIFFERENT local machine, you'll need the Local Intranet IP of that machine. (If it's on the same computer, you don't need this.)
If you intend strictly remote internet access, an FRP intranet penetration setup is needed. That is beyond this guide's scope.
**DO NOT** simply copy strings populated arbitrarily on the LMStudio UI if accessing across network nodes.

:::
## Configure within UNIChat

1. Open UNIChat Settings -> API Setup -> Add Provider.
2. Locate the **LMStudio** preset card.
3. Under Basic Setup, give your API provider a name, like "Living Room PC".
4. In the endpoint section, if your LMStudio runs concurrently strictly on the same rig as UNIChat, type **http://localhost:1234**. Alternatively, if they belong to disparate computers, fill in **http://YOUR_LOCAL_IP:1234**.
5. Moving to the API Key box, click Add API Key. Since LMStudio ignores keys by design, type anything. We populated it with "hello" as an example.
6. Below under Model Setup, choose "Add Model." Return to your open LMStudio software and search for the model IDs inside UNIChat's interface exactly as they appear in LMStudio, to make sure both environments sync up logically.
7. Save.

:::tip
Whenever interacting with an API bound to LMStudio, assure LMStudio stands actively running or activate LMStudio's Headless Mode.
:::
