---
id: agent-philosophy
title: Session is Agent
description: Understand UNIChat's unique monolithic architecture philosophy and its advantages
tags:
  - Core Concepts
  - Architecture
  - Agent
sidebar_position: 2
---

# Session is Agent: Monolithic Architecture Philosophy

UNIChat adopts a unique design philosophy where you create a session in an Agent instead of selecting an Agent for a new session.

## Traditional Model vs UNIChat Model

| Feature | Traditional Chat Tools | UNIChat |
| :--- | :--- | :--- |
| **Configuration Scope** | Global or Character Library | Deeply bound within the current sagent |
| **Knowledge Base** | Global association | Agent-private association |
| **Flexibility** | Modifying a role affects all related chats | Each agent is an independently evolving entity |

## Why design it this way?

Anyone who has used ChatGPT probably knows about its feature that references chat history. Originally, OpenAI introduced this to provide personalized content. In reality, however, it often tacks on something like this at the end of a reply:

* *"You previously discussed XXX with me, and our current topic YYY shares a similar essence, which shows that you are a ... person. If you're interested, I can help you create a plan to apply the philosophy of XXX to YYY. Just say the word, and I will immediately..."*

(Never mind that XXX and YYY have absolutely nothing to do with each other.)
Honestly, seeing it forcibly draw these non-existent connections just to make small talk frequently makes my blood boil.

So, here is what an architecture like UNIChat's **brings to the table**:

### 1. Reduced Context Pollution

If you set up a global "Coding Assistant" role but want it to switch to the Python 3.12 standard library for one specific conversation, traditional tools might require you to modify the global settings. In UNIChat, you only need to tweak the specific settings within the Agent, and it won't interfere with other chats.

### 2. State Integrity

An Agent should encompass its:

* **Persona**: Who is it?
* **Knowledge**: What does it know?
* **Parameters**: What is its response style (Temperature, Top-P, etc.)?

### 3. Stronger Relevance

For instance, you can create a dedicated Agent specifically for a project. This Agent can access all your conversations and content related to this project, gaining a comprehensive understanding of it and becoming smarter with every question you ask. At the same time, it won't pollute your other non-project-related chats.

## User Guide

Click Edit in the Agent settings panel to enter the **Agent Editing Page**, where you can adjust the Agent's settings at any time. For specific details, refer to:

* ⚙️ **[Configuring Models and Parameters](./model-settings.md)**: This is the Agent's "brain". Choose a suitable model for it (like DeepSeek or GPT-4) and configure the basic parameter details.
* 🗣️ **[Writing System Prompts](./system-prompt.md)**: This is the Agent's "personality". Use prompts to define who it is, what it is responsible for, and how it communicates with you.
* 👤 **[Binding User Identity](./user-identity.md)**: This is how the Agent recognizes you. You can assign a specific persona to it or have it use a special "nickname" for you.