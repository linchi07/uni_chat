# 如何编写博客文章

本文将指导你如何在 UNIChat 官网（基于 Docusaurus）上编写和发布新的博客文章。

## 📝 编写步骤

### 1. 新建文件

在项目根目录下的 `website/blog/` 文件夹中创建一个新的 `.md` 或 `.mdx` 文件。

**文件命名规范**: 建议使用 `YYYY-MM-DD-标题.md` 的格式，例如 `2026-04-01-new-feature.md`。

### 2. 配置 Front Matter

在文件的最顶部，你需要添加 Front Matter 来定义文章的元数据：

```yaml
---
slug: new-feature-announcement  # 网址路径
title: 我们发布了一个新功能！      # 文章标题
authors: [linchi]               # 作者 ID（在 website/blog/authors.yml 中定义）
tags: [feature, update]         # 标签
---
```

### 3. 编写内容

你可以使用标准的 Markdown 语法编写内容。

- **摘要切分**: 使用 `<!--truncate-->` 标签。该标签之前的内容会显示在博客首页的摘要中，之后的内容需要点击“阅读更多”才能查看。

```markdown
这是文章的简短摘要。
<!--truncate-->
这是文章的详细内容。
```

### 4. 发布

保存文件后，如果你正在运行开发服务器 (`npm run start`)，网页会自动刷新显示新文章。
当你提交代码并推送到 GitHub 后，网站会自动重新构建并发布。

## 🎨 进阶技巧

- **MDX**: 如果你使用 `.mdx` 扩展名，你可以在文章中直接使用 React 组件。
- **作者配置**: 可以在 `website/blog/authors.yml` 中添加新的作者及其头像、个人主页等信息。
- **本地预览**: 在 `website` 目录下运行 `npm run start` 即可在浏览器实时预览你的修改。

祝你的第一篇博客写作顺利！
 village
