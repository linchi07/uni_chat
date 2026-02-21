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

UNIChat adopts a unique "monolithic" design philosophy: **Session is Agent**.

## Traditional Model vs UNIChat Model

| Feature | Traditional Chat Tools | UNIChat |
| :--- | :--- | :--- |
| **Configuration Scope** | Global or Character Library | Deeply bound within the current session |
| **Knowledge Base** | Global association | Session-private association |
| **Flexibility** | Modifying a role affects all related chats | Each conversation is an independently evolving entity |
| **Complexity** | High (requires jumping between multiple interfaces) | Low (One-stop configuration) |

## Why Design It This Way?

### 1. Reduce Context Pollution
If you set up a "Coding Assistant" role globally, but you want him to switch to the Python 3.12 standard library in a specific conversation, traditional tools might require you to modify global settings. In UNIChat, you only need to fine-tune it in the **current session's** settings, without interfering with other conversations.

### 2. State Integrity
An Agent should encompass its:
- **Persona**: Who is it?
- **Knowledge**: What does it know?
- **Parameters**: How is its reply style (Temperature, Top-P, etc.)?

Locking all these attributes within the session means that when you export or share this session, you are sharing a **complete, reproducible state of an intelligent entity**.

## Operation Guide

By clicking **[⚙️ Agent Settings]** at the top of the session, you can adjust at any time:
- ⚙️ **[Configuring Models and Parameters](../agents/model-settings.md)**: This is the Agent's "brain". Choose a suitable model for it (like DeepSeek or GPT-4) and configure the basic parameter details.
- 🗣️ **[Writing System Prompts](../agents/system-prompt.md)**: This is the Agent's "personality". Use prompts to define who it is, what it is responsible for, and how it communicates with you.
- 👤 **[Binding User Identity](../agents/user-identity.md)**: This is how the Agent recognizes you. You can assign a specific persona to it or have it use a special "nickname" for you.