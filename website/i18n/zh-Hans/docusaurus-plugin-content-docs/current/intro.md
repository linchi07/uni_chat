---
sidebar_position: 1
---

# 教程介绍

让我们在 **5分钟内了解 Docusaurus**。

## 入门

通过 **创建一个新站点** 开始。

或者通过 **[docusaurus.new](https://docusaurus.new)** **立即试用 Docusaurus**。

### 你需要什么

- [Node.js](https://nodejs.org/en/download/) 20.0 或更高版本：
  - 安装 Node.js 时，建议您选中所有与依赖项相关的复选框。

## 生成一个新站点

使用 **classic 模板** 生成一个新的 Docusaurus 站点。

运行以下命令后，classic 模板将自动添加到您的项目中：

```bash
npm init docusaurus@latest my-website classic
```

您可以将此命令输入到命令提示符、Powershell、终端或代码编辑器的任何其他集成终端中。

该命令还会安装运行 Docusaurus 所需的所有必要依赖项。

## 启动您的站点

运行开发服务器：

```bash
cd my-website
npm run start
```

`cd` 命令会更改您正在使用的目录。为了使用您新创建的 Docusaurus 站点，您需要在此处导航终端。

`npm run start` 命令会在本地构建您的网站，并通过开发服务器提供服务，您可以在 http://localhost:3000/ 上查看。

打开 `docs/intro.md`（此页面）并编辑一些行：网站会 **自动重新加载** 并显示您的更改。
