---
id: branching
title: Multi-Branch Conversations
description: Explore UNIChat's non-linear conversation and branching capabilities
tags:
  - Core Concepts
  - Multi-Branch
  - Dialogue Tree
sidebar_position: 1
---

# Non-Linear Conversations and Branching

This is the most core design philosophy of UNIChat: **Conversations should not be linear; they should be tree-structured.**

## What is a Multi-Branch Conversation?

In standard AI tools, you have to stuggle in whether to keep the currently generated response witch is satisfying in most parts while have some fillars or to regeneate a completely different response. UNIChat's multi-branching system allows you to generate multiple responses simultaneously, allowing you to explore different paths and find the most suitable one. 

This generates a parallel conversation path. You can:
1. **Compare**: Try a serious tone in Branch A, and a humorous tone in Branch B.
2. **Backtrack**: After discussing a topic in depth, you can jump back to an earlier node at any time and start a completely different conversation without losing previous records.

## Application Scenarios

### 1. Literature Review and Research
When you ask AI to summarize a long text, you can open multiple branches for different chapters to ask questions in parallel, ensuring your main conversation trunk always remains clear.

### 2. Code Refactoring and Debugging
- **Branch A**: Try refactoring scheme 1.
- **Branch B**: Try refactoring scheme 2.
You can advance both schemes simultaneously and decide which one to ultimately adopt based on the AI's feedback.

### 3. Prompt Tuning (Prompt Injection)
Professional Prompt engineers can utilize the branching feature to fine-tune the System Prompt or context information until achieving the perfect output.

## How to Use

### Auto Branching
The branching system will automatically start a new branch when you :
- Regenerate a message
- Modify your input mesage

You can use the buttons to switch between branches.

### Manual Branching
Click on the branch icon and enter the name of the new branch to create a new branch on this current node.
