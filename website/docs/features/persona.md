---
sidebar_position: 1
---

# Persona (人格/角色卡)

在 UNIChat 中，**Persona** 决定了 Agent 的语气、性格、背景故事以及特定的对话限制。

## Tavern 角色卡支持

UNIChat 原生支持导入 **Tavern (酒馆)** 格式的角色卡（通常为带有 metadata 的 PNG 图片或 JSON 文件）。

### 如何使用
1. 进入会话的 **Agent 设置**。
2. 在 Persona 栏目点击“导入”。
3. 选择你的 Tavern 角色卡文件，UNIChat 会自动解析其中的描绘、开场白和背景设定。

## 自定义 Persona

如果你想从零开始创建一个角色，建议包含以下要素：
- **Name**: 它的名字。
- **Description**: 它的外貌、性格核心。
- **Scenario**: 当前对话所处的场景。
- **First Message**: 它的第一句话是什么？这往往能决定整个对话的调子。

## 给进阶用户的建议
使用 `{{user}}` 和 `{{char}}` 占位符可以使 Persona 定义更具通用性。UNIChat 会在发送给 AI 之前自动替换这些占位符。