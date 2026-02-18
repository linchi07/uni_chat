import React from 'react';
import ComponentCreator from '@docusaurus/ComponentCreator';

export default [
  {
    path: '/__docusaurus/debug',
    component: ComponentCreator('/__docusaurus/debug', '5ff'),
    exact: true
  },
  {
    path: '/__docusaurus/debug/config',
    component: ComponentCreator('/__docusaurus/debug/config', '5ba'),
    exact: true
  },
  {
    path: '/__docusaurus/debug/content',
    component: ComponentCreator('/__docusaurus/debug/content', 'a2b'),
    exact: true
  },
  {
    path: '/__docusaurus/debug/globalData',
    component: ComponentCreator('/__docusaurus/debug/globalData', 'c3c'),
    exact: true
  },
  {
    path: '/__docusaurus/debug/metadata',
    component: ComponentCreator('/__docusaurus/debug/metadata', '156'),
    exact: true
  },
  {
    path: '/__docusaurus/debug/registry',
    component: ComponentCreator('/__docusaurus/debug/registry', '88c'),
    exact: true
  },
  {
    path: '/__docusaurus/debug/routes',
    component: ComponentCreator('/__docusaurus/debug/routes', '000'),
    exact: true
  },
  {
    path: '/blog',
    component: ComponentCreator('/blog', 'b2f'),
    exact: true
  },
  {
    path: '/blog/archive',
    component: ComponentCreator('/blog/archive', '182'),
    exact: true
  },
  {
    path: '/blog/authors',
    component: ComponentCreator('/blog/authors', '0b7'),
    exact: true
  },
  {
    path: '/blog/authors/all-sebastien-lorber-articles',
    component: ComponentCreator('/blog/authors/all-sebastien-lorber-articles', '4a1'),
    exact: true
  },
  {
    path: '/blog/authors/yangshun',
    component: ComponentCreator('/blog/authors/yangshun', 'a68'),
    exact: true
  },
  {
    path: '/blog/first-blog-post',
    component: ComponentCreator('/blog/first-blog-post', '89a'),
    exact: true
  },
  {
    path: '/blog/long-blog-post',
    component: ComponentCreator('/blog/long-blog-post', '9ad'),
    exact: true
  },
  {
    path: '/blog/mdx-blog-post',
    component: ComponentCreator('/blog/mdx-blog-post', 'e9f'),
    exact: true
  },
  {
    path: '/blog/tags',
    component: ComponentCreator('/blog/tags', '287'),
    exact: true
  },
  {
    path: '/blog/tags/docusaurus',
    component: ComponentCreator('/blog/tags/docusaurus', '704'),
    exact: true
  },
  {
    path: '/blog/tags/facebook',
    component: ComponentCreator('/blog/tags/facebook', '858'),
    exact: true
  },
  {
    path: '/blog/tags/hello',
    component: ComponentCreator('/blog/tags/hello', '299'),
    exact: true
  },
  {
    path: '/blog/tags/hola',
    component: ComponentCreator('/blog/tags/hola', '00d'),
    exact: true
  },
  {
    path: '/blog/welcome',
    component: ComponentCreator('/blog/welcome', 'd2b'),
    exact: true
  },
  {
    path: '/download',
    component: ComponentCreator('/download', 'b81'),
    exact: true
  },
  {
    path: '/macos-guide',
    component: ComponentCreator('/macos-guide', 'a4a'),
    exact: true
  },
  {
    path: '/markdown-page',
    component: ComponentCreator('/markdown-page', '3d7'),
    exact: true
  },
  {
    path: '/docs',
    component: ComponentCreator('/docs', 'd0e'),
    routes: [
      {
        path: '/docs',
        component: ComponentCreator('/docs', 'e8a'),
        routes: [
          {
            path: '/docs',
            component: ComponentCreator('/docs', '2df'),
            routes: [
              {
                path: '/docs/category/功能指南',
                component: ComponentCreator('/docs/category/功能指南', '4c3'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/核心概念',
                component: ComponentCreator('/docs/category/核心概念', '846'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/开发者指南',
                component: ComponentCreator('/docs/category/开发者指南', 'be9'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/快速上手',
                component: ComponentCreator('/docs/category/快速上手', '382'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/core-concepts/agent-philosophy',
                component: ComponentCreator('/docs/core-concepts/agent-philosophy', '521'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/core-concepts/branching',
                component: ComponentCreator('/docs/core-concepts/branching', '655'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/development/run-unichat-on-ios-or-ipados-devices',
                component: ComponentCreator('/docs/development/run-unichat-on-ios-or-ipados-devices', 'fb6'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/auto_index_rules',
                component: ComponentCreator('/docs/features/auto_index_rules', 'dfb'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/edit_persona',
                component: ComponentCreator('/docs/features/edit_persona', 'adb'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/file_manage',
                component: ComponentCreator('/docs/features/file_manage', '71c'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/knowledge_base',
                component: ComponentCreator('/docs/features/knowledge_base', '27f'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/knowledge-base',
                component: ComponentCreator('/docs/features/knowledge-base', '4b0'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/memory_manage',
                component: ComponentCreator('/docs/features/memory_manage', 'a7d'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/model_settings',
                component: ComponentCreator('/docs/features/model_settings', '632'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/overview',
                component: ComponentCreator('/docs/features/overview', 'a83'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/persona',
                component: ComponentCreator('/docs/features/persona', 'd65'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/setup-a-provider',
                component: ComponentCreator('/docs/features/setup-a-provider', 'efa'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/system_prompts',
                component: ComponentCreator('/docs/features/system_prompts', 'cf0'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/features/website_manage',
                component: ComponentCreator('/docs/features/website_manage', 'f11'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/get-started/configure_api_settings',
                component: ComponentCreator('/docs/get-started/configure_api_settings', '1b8'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/get-started/setup-your-first-agent',
                component: ComponentCreator('/docs/get-started/setup-your-first-agent', 'a8a'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/intro',
                component: ComponentCreator('/docs/intro', '61d'),
                exact: true,
                sidebar: "tutorialSidebar"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    path: '/',
    component: ComponentCreator('/', 'e5f'),
    exact: true
  },
  {
    path: '*',
    component: ComponentCreator('*'),
  },
];
