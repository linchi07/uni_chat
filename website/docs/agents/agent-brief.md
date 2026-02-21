---
id: agent-brief
title: What is an Agent
description: Understand the core concept of an Agent and its vital role in UNIChat
tags:
  - Agent
  - Persona
  - Core Concepts
sidebar_position: 1
---

# What is an Agent
In UNIChat, AI is not just a chat box; it is a character with independent capabilities.
When you chat, you are not simply talking to an LLM, but to independent individual Agents.

You can think of each Agent as a hired "expert" or "virtual persona" with its own personality, field of expertise, and unique approach to solving problems.

## From "Chat Box" to "Independent Character"

The key to understanding an Agent lies in its independence:

**Traditional AI Chat**: It's like shouting into the void; every time, you have to re-explain who you are, what format you need, and what role you want it to play.

**Agent**: It is a pre-configured entity. It already possesses specific background knowledge (knowledge base) and action capabilities (tools). When you switch between different Agents, you are actually switching between different "experts".

## The Role Architecture of an Agent

The "independence" of an Agent is built upon three dimensions, which you can customize like "sculpting a face":

### 👤 Identity and Persona
This is the soul of the Agent. Through the System Prompt, you define its:
- **Professional Background**: Is it a senior architect or a gentle psychological counselor?
- **Communication Style**: Is it concise and to the point, or full of humor?
- **Values**: What stance does it lean towards when facing conflicts?

## Why Did UNIChat Adopt This Architecture?

At the beginning of its design, UniChat adopted the Agent->Session architecture instead of the traditional Session->Agent architecture. The purpose of this is to solidify the concept of the Agent and allow for cross-conversation memory. This "independent character" design allows you to handle complex problems with ease:

- **Capability Encapsulation**: You don't need to remember complex commands; just click on the "Code Expert" avatar, and it naturally possesses all professional qualities.
- **Role Switching**: You can quickly switch roles, like changing from a "Code Expert" to a "Translation Expert", and start your conversation.
- **Character Memory (Coming Soon)**: The Agent can remember previous conversations with the user and chat based on those memories.

In short, this architecture ensures you are not talking to a cold, lifeless model, but to **vibrant individuals with distinct personalities**.

## How to Get Started?

Don't treat it like a Q&A machine; try to **"define"** a character that belongs to you:
- **Give it a name**: For example, "My AI Reading Notes Officer".
- **Set its personality**: Tell it, "You are a rigorous scholar who excels at summarizing."

## Future Outlook
I am currently working on processing Agent memory, meaning it will gradually understand you more comprehensively as you chat. Even if you switch conversations, it will remember what was discussed before.
However, my ultimate vision for the Agent is a fully realized encapsulation of multiple capabilities. I want to equip different Agents with different functions, such as memory, knowledge, or Skills, and provide them with suitable tools. For example, some Agents could be capable of operating your computer.

If you have any ideas, please send me an email. Or simply create an issue. (Direct messaging me on QQ works too)