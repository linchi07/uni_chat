---
trigger: always_on
---

项目架构：
主要分为两部分：
- app文件夹下面的flutter应用，也就是app的核心应用部分，所有有app本身的东西和资源都在这里。纯dart
- website文件夹下面是这个应用的官网+文档站，采用docasorus来构建

Flutter编写注意事项：
- 主要使用app中的预构建组建，也就是lib/utils/prebuildt_widgets.dart下的那些组件，而非标准的material UI 来实现更加美观和统一的风格