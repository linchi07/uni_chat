---
id: lmstudio
title: 接入 LMStudio
description: 如何将本地运行的 LMStudio 作为服务端接入 UNIChat
tags:
  - API提供商
  - LMStudio
  - 本地部署
sidebar_position: 1
---

# LMStudio
LMStudio 是一个可以让你本地运行大模型的集成式软件。
本文将会介绍如何将LMStudio作为服务提供商集成到UniChat中。

## 准备

- 一台显存足够大的电脑（推荐NVIDIA显卡，或者Apple silicon MAC也可以）不需要和UniChat所运行在的设备一样。

:::tip
确保你的电脑有足够的显存。

以Q4KM量化的模型为例子：
| 模型 | 显存 | 上下文 |
| --- | --- |   --- |
| 7B | 7.5G |   ~4096 |
| 14B | 16G |   ~10000|
| 32B | 24G |   ~6500 |
| 30BA3B | 24G |   ~32000 |

可以是多个显卡并行，或者比如Mac这种统一内存架构。

:::

## 配置LMStudio
1. 访问 [LMStudio](https://lmstudio.ai/)并且下载。
2. 安装，并且按照LMStudio的提示，下载并配置模型。
3. 如图，切换到Developer模式。然后点击左侧的绿色终端图标。
4. 在打开的界面，点击settings，将所有开关全部打开。并且确保左侧status 为 Running。
5. 点击左侧导航栏的红色模型选项，打开模型页面，放着备用。

:::danger

本文假设您的电脑没有直接连接到公网环境下。
如果你的电脑有直接的公网IP（在中国大陆，这基本不可能），请务必小心，不要将端口暴露在公网上。

:::

:::tip

如果你不在本机使用LMStudio，请获取这台电脑的内网IP地址。（如果是同一台电脑不需要）
如果你想要远程使用，需要配置FRP内网穿透，这里不具体展开。
**不要**拷贝LMStudio上显示的那个地址。

:::
## 在 UNIChat 中配置

1. 打开 UNIChat 设置 -> API设置 -> 添加提供商。
2. 找到预设的 **LMStudio** 卡片
3. 在 基础配置栏目下，给你的API提供商起一个名字，比如客厅的电脑。
4. 在端点栏目，如果你的LMStudio和UNIChat在同一台电脑，填写 **http://localhost:1234 **。如果不在一台电脑，填写 **http://你的电脑的IP:1234 **。
5. 在API 密钥栏目，点击添加APIKey，由于LMStudio无须密钥，随便填写即可，这里写了一个hello。
6. 在模型配置栏目，选择添加模型，打开刚刚LMStudio的模型页面，在UniChat的模型搜索框中搜索LMStudio现在存在的模型。点击添加，然后再回到LMStudio，拷贝模型调用名。选择添加。将所有的模型添加到UniChat中。
7. 保存。

:::tip
在使用LMStudio模型的时候，必须保证LmStudio在运行，或者启用LMStudio的无头模式。
:::

