---
id: system-prompt
title: System Prompts
description: A guide to writing excellent system prompts for your Agent
tags:
  - Agent
  - Prompt Tricks
  - Character Settings
sidebar_position: 3
---

# System Prompts

The system prompt is the very first and highest-level instruction sent to the AI model. It is usually invisible to the user, but it silently constrains every single response the AI generates in the background. It defines the core attributes of an Agent.

In short, the system prompt is the Agent's **"Factory Settings", "Personality Traits", and "Professional Background"**.

### Writing Guide

#### The Core Formula of a System Prompt

Writing a powerful Agent prompt typically involves the following four elements:

- 👤 **Establish Identity (Who are you?)**
  - Clarify the AI's identity.
  - Example: "You are a science writer adept at explaining complex scientific concepts in simple, easy-to-understand language."

- 🎯 **Define the Task (What to do?)**
  - Tell it what it represents and primarily handles.
  - Example: "Your task is to analyze financial reports uploaded by users and identify potential financial risks."

- 🎭 **Set the Tone (How to speak?)**
  - Define the tone, word count, or format of the replies.
  - Example: "Please use a professional, objective tone. Try to use Markdown tables to present comparative data."

- ⚠️ **Set Boundaries (Constraints)**
  - Tell it what it absolutely must not do.
  - Example: "If a question involves politically sensitive content, please decline to answer politely. Do not provide specific investment advice in your answers."

#### Writing Tips

- **Use "You are..." instead of "I want you to act as..."**: Directly defining the identity makes the model more stable.
- **Provide Examples (Few-shot)**: Giving a pair of "Q&A" examples in the prompt helps the AI learn very quickly.
- **Paragraph Formatting**: Use numbering, bold text, or `#` headings to help the model better recognize the structure of your instructions.
- **Dynamic Adjustments**: If the Agent's replies are too wordy, add a line to the prompt: "Please keep your answers concise, no more than 200 words."

#### Examples

You can try pasting the following content into your Agent's "System Prompt" box:

- **Code Review Expert**:
  >"You are a senior full-stack engineer. Please inspect the code submitted by the user, point out logical flaws, performance bottlenecks, and potential security vulnerabilities. Please provide optimized suggestions using code blocks."

- **Psychological Counselor**:
  >"You are an empathetic psychological counselor. Please converse with the user in a gentle and encouraging tone. Listen more, ask questions, and guide the user toward self-discovery, rather than giving blunt advice."

:::tip

A great Agent emerges through continuous refinement. When you notice its replies aren't meeting your expectations, modifying the system prompt is usually the most effective solution.

:::

### Future Outlook
First, we should add a `{{placeholder}}` feature similar to Tavern to customize dynamic variables.
