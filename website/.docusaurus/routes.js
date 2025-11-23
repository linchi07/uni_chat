import React from 'react';
import ComponentCreator from '@docusaurus/ComponentCreator';

export default [
  {
    path: '/zh-Hans/__docusaurus/debug',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug', '555'),
    exact: true
  },
  {
    path: '/zh-Hans/__docusaurus/debug/config',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug/config', '1fa'),
    exact: true
  },
  {
    path: '/zh-Hans/__docusaurus/debug/content',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug/content', '1c6'),
    exact: true
  },
  {
    path: '/zh-Hans/__docusaurus/debug/globalData',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug/globalData', '0df'),
    exact: true
  },
  {
    path: '/zh-Hans/__docusaurus/debug/metadata',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug/metadata', '9f5'),
    exact: true
  },
  {
    path: '/zh-Hans/__docusaurus/debug/registry',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug/registry', 'ada'),
    exact: true
  },
  {
    path: '/zh-Hans/__docusaurus/debug/routes',
    component: ComponentCreator('/zh-Hans/__docusaurus/debug/routes', '11e'),
    exact: true
  },
  {
    path: '/zh-Hans/blog',
    component: ComponentCreator('/zh-Hans/blog', '575'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/archive',
    component: ComponentCreator('/zh-Hans/blog/archive', 'c6a'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/authors',
    component: ComponentCreator('/zh-Hans/blog/authors', 'eed'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/authors/all-sebastien-lorber-articles',
    component: ComponentCreator('/zh-Hans/blog/authors/all-sebastien-lorber-articles', '3cd'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/authors/yangshun',
    component: ComponentCreator('/zh-Hans/blog/authors/yangshun', 'b1b'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/first-blog-post',
    component: ComponentCreator('/zh-Hans/blog/first-blog-post', '9f9'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/long-blog-post',
    component: ComponentCreator('/zh-Hans/blog/long-blog-post', 'd61'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/mdx-blog-post',
    component: ComponentCreator('/zh-Hans/blog/mdx-blog-post', 'd1e'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/tags',
    component: ComponentCreator('/zh-Hans/blog/tags', 'c60'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/tags/docusaurus',
    component: ComponentCreator('/zh-Hans/blog/tags/docusaurus', '874'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/tags/facebook',
    component: ComponentCreator('/zh-Hans/blog/tags/facebook', '205'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/tags/hello',
    component: ComponentCreator('/zh-Hans/blog/tags/hello', '0ab'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/tags/hola',
    component: ComponentCreator('/zh-Hans/blog/tags/hola', 'c43'),
    exact: true
  },
  {
    path: '/zh-Hans/blog/welcome',
    component: ComponentCreator('/zh-Hans/blog/welcome', 'abc'),
    exact: true
  },
  {
    path: '/zh-Hans/download',
    component: ComponentCreator('/zh-Hans/download', '4ff'),
    exact: true
  },
  {
    path: '/zh-Hans/markdown-page',
    component: ComponentCreator('/zh-Hans/markdown-page', '1d3'),
    exact: true
  },
  {
    path: '/zh-Hans/docs',
    component: ComponentCreator('/zh-Hans/docs', 'b75'),
    routes: [
      {
        path: '/zh-Hans/docs',
        component: ComponentCreator('/zh-Hans/docs', '4c8'),
        routes: [
          {
            path: '/zh-Hans/docs',
            component: ComponentCreator('/zh-Hans/docs', '1c9'),
            routes: [
              {
                path: '/zh-Hans/docs/Agents/knowledge_base',
                component: ComponentCreator('/zh-Hans/docs/Agents/knowledge_base', '7a6'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/Agents/model_settings',
                component: ComponentCreator('/zh-Hans/docs/Agents/model_settings', 'fe0'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/Agents/system_prompts',
                component: ComponentCreator('/zh-Hans/docs/Agents/system_prompts', '341'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/API Providers/setup-a-provider',
                component: ComponentCreator('/zh-Hans/docs/API Providers/setup-a-provider', '5e2'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/category/agents',
                component: ComponentCreator('/zh-Hans/docs/category/agents', '6e4'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/category/api-providers',
                component: ComponentCreator('/zh-Hans/docs/category/api-providers', 'c91'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/category/knowledgebases',
                component: ComponentCreator('/zh-Hans/docs/category/knowledgebases', '67a'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/category/personas',
                component: ComponentCreator('/zh-Hans/docs/category/personas', 'e3e'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/intro',
                component: ComponentCreator('/zh-Hans/docs/intro', '16f'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/KnowledgeBases/auto_index_rules',
                component: ComponentCreator('/zh-Hans/docs/KnowledgeBases/auto_index_rules', '6cd'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/KnowledgeBases/file_manage',
                component: ComponentCreator('/zh-Hans/docs/KnowledgeBases/file_manage', 'b02'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/KnowledgeBases/memory_manage',
                component: ComponentCreator('/zh-Hans/docs/KnowledgeBases/memory_manage', '7c7'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/KnowledgeBases/website_manage',
                component: ComponentCreator('/zh-Hans/docs/KnowledgeBases/website_manage', '2fe'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/Personas/edit_persona',
                component: ComponentCreator('/zh-Hans/docs/Personas/edit_persona', '0c9'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/QuickStart/configure_api_settings',
                component: ComponentCreator('/zh-Hans/docs/QuickStart/configure_api_settings', 'fc5'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/QuickStart/create_a_persona',
                component: ComponentCreator('/zh-Hans/docs/QuickStart/create_a_persona', '82a'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/QuickStart/link_kb_to_agent',
                component: ComponentCreator('/zh-Hans/docs/QuickStart/link_kb_to_agent', '9e6'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/zh-Hans/docs/QuickStart/setup-your-first-agent',
                component: ComponentCreator('/zh-Hans/docs/QuickStart/setup-your-first-agent', 'ce3'),
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
    path: '/zh-Hans/',
    component: ComponentCreator('/zh-Hans/', '85c'),
    exact: true
  },
  {
    path: '*',
    component: ComponentCreator('*'),
  },
];
