---
id: persona
title: Persona System
description: Use Persona to provide the Agent with more information about yourself
tags:
  - Persona
  - Roleplay
  - Personalization
sidebar_position: 5
---

# Persona

In UNIChat, a **Persona** describes your own setting. Put simply, a Persona tells the AI who you are, along with some of your basic information. This allows the AI to better understand and interact with you.

If you have used SillyTavern, you will be very familiar with this concept.

:::tip

The original meaning of Persona is an assumed identity or character mask. The intention behind adding this system was to allow you to switch roles quickly, just like putting on different character masks.
In the Persona system, you can play any role at any time. For instance, you could be a diligent high school student during the day and a righteous "Phantom Thief of Hearts" at night.

:::

## How to Use It
### Using It in Chat

On the left side of the app's main chat interface, there is a Persona Switcher. Click to expand it and select the Persona you want to present.
:::info

When you start a new session using a certain Persona, it is automatically remembered. The next time you open that session, it will automatically switch to the Persona used when it was created. However, you can also change the Persona mid-session; the change takes effect instantly, and the AI will immediately recognize a "different" you.

:::

### Binding a Persona to an Agent

You can bind a specific Persona to an Agent. This way, whenever that particular Agent is invoked, it will automatically switch to that Persona.
Additionally, you can add Persona Extra Information for an Agent. This information will only be remembered by the current Agent, thereby creating "differentiated cognitive awareness."

For more details, see [Agents](/docs/agents/agent-brief).

## Creating a Persona
Creating a Persona is simple. In the Persona Switcher, click "Create New Persona" to open the creation page.

Choose a nice avatar, fill in the name, and briefly describe this Persona in the introduction section below the name.

In the edit bar on the right (which narrows down to "More Info" on mobile devices), you can continue adding all aspects about yourself.
For example:
- Birthday: 2000-01-01
- Held Item: Evoker

...

## Future Outlook

The current Persona system is only an initial version. In the future, I hope to make it support keyword insertion or vector indexing, so the AI can understand a much more comprehensive version of you. I also want to allow Agents to dynamically and automatically update the Persona during chats, "remembering" things about you and becoming more familiar with you as you talk more—similar to ChatGPT's Memory (Bios) system.

If you have better ideas, feel free to open an issue on GitHub, or send me an email. For more on this, see: Contributing to UNIChat.
