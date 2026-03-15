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
    path: '/docs',
    component: ComponentCreator('/docs', '805'),
    routes: [
      {
        path: '/docs',
        component: ComponentCreator('/docs', 'b2f'),
        routes: [
          {
            path: '/docs/tags',
            component: ComponentCreator('/docs/tags', 'fce'),
            exact: true
          },
          {
            path: '/docs/tags/概览',
            component: ComponentCreator('/docs/tags/概览', '83a'),
            exact: true
          },
          {
            path: '/docs/tags/介绍',
            component: ComponentCreator('/docs/tags/介绍', '1fe'),
            exact: true
          },
          {
            path: '/docs/tags/入门',
            component: ComponentCreator('/docs/tags/入门', 'c51'),
            exact: true
          },
          {
            path: '/docs/tags/advanced-scheduling',
            component: ComponentCreator('/docs/tags/advanced-scheduling', '889'),
            exact: true
          },
          {
            path: '/docs/tags/agent',
            component: ComponentCreator('/docs/tags/agent', 'bcd'),
            exact: true
          },
          {
            path: '/docs/tags/api',
            component: ComponentCreator('/docs/tags/api', '0eb'),
            exact: true
          },
          {
            path: '/docs/tags/api-provider',
            component: ComponentCreator('/docs/tags/api-provider', 'd5b'),
            exact: true
          },
          {
            path: '/docs/tags/architecture',
            component: ComponentCreator('/docs/tags/architecture', '926'),
            exact: true
          },
          {
            path: '/docs/tags/basic-config',
            component: ComponentCreator('/docs/tags/basic-config', '6fb'),
            exact: true
          },
          {
            path: '/docs/tags/basic-settings',
            component: ComponentCreator('/docs/tags/basic-settings', 'bb6'),
            exact: true
          },
          {
            path: '/docs/tags/character-settings',
            component: ComponentCreator('/docs/tags/character-settings', '6df'),
            exact: true
          },
          {
            path: '/docs/tags/core-concepts',
            component: ComponentCreator('/docs/tags/core-concepts', '94c'),
            exact: true
          },
          {
            path: '/docs/tags/custom-endpoints',
            component: ComponentCreator('/docs/tags/custom-endpoints', '989'),
            exact: true
          },
          {
            path: '/docs/tags/deep-seek',
            component: ComponentCreator('/docs/tags/deep-seek', 'aa1'),
            exact: true
          },
          {
            path: '/docs/tags/dialogue-tree',
            component: ComponentCreator('/docs/tags/dialogue-tree', '7e8'),
            exact: true
          },
          {
            path: '/docs/tags/gemini',
            component: ComponentCreator('/docs/tags/gemini', '5d5'),
            exact: true
          },
          {
            path: '/docs/tags/google',
            component: ComponentCreator('/docs/tags/google', '2f8'),
            exact: true
          },
          {
            path: '/docs/tags/gpt',
            component: ComponentCreator('/docs/tags/gpt', 'd56'),
            exact: true
          },
          {
            path: '/docs/tags/i-os',
            component: ComponentCreator('/docs/tags/i-os', '7f4'),
            exact: true
          },
          {
            path: '/docs/tags/i-pad-os',
            component: ComponentCreator('/docs/tags/i-pad-os', '717'),
            exact: true
          },
          {
            path: '/docs/tags/identity-setup',
            component: ComponentCreator('/docs/tags/identity-setup', '693'),
            exact: true
          },
          {
            path: '/docs/tags/installation',
            component: ComponentCreator('/docs/tags/installation', 'bc4'),
            exact: true
          },
          {
            path: '/docs/tags/lm-studio',
            component: ComponentCreator('/docs/tags/lm-studio', 'eb2'),
            exact: true
          },
          {
            path: '/docs/tags/load-balancing',
            component: ComponentCreator('/docs/tags/load-balancing', 'c25'),
            exact: true
          },
          {
            path: '/docs/tags/local-deployment',
            component: ComponentCreator('/docs/tags/local-deployment', 'f72'),
            exact: true
          },
          {
            path: '/docs/tags/model-scope',
            component: ComponentCreator('/docs/tags/model-scope', 'faf'),
            exact: true
          },
          {
            path: '/docs/tags/model-setup',
            component: ComponentCreator('/docs/tags/model-setup', '8ca'),
            exact: true
          },
          {
            path: '/docs/tags/multi-branch',
            component: ComponentCreator('/docs/tags/multi-branch', '0a4'),
            exact: true
          },
          {
            path: '/docs/tags/open-ai',
            component: ComponentCreator('/docs/tags/open-ai', 'ed3'),
            exact: true
          },
          {
            path: '/docs/tags/persona',
            component: ComponentCreator('/docs/tags/persona', 'b54'),
            exact: true
          },
          {
            path: '/docs/tags/personalization',
            component: ComponentCreator('/docs/tags/personalization', 'ca8'),
            exact: true
          },
          {
            path: '/docs/tags/prompt-tricks',
            component: ComponentCreator('/docs/tags/prompt-tricks', 'af1'),
            exact: true
          },
          {
            path: '/docs/tags/quick-start',
            component: ComponentCreator('/docs/tags/quick-start', '84f'),
            exact: true
          },
          {
            path: '/docs/tags/roleplay',
            component: ComponentCreator('/docs/tags/roleplay', '934'),
            exact: true
          },
          {
            path: '/docs',
            component: ComponentCreator('/docs', '680'),
            routes: [
              {
                path: '/docs/agents/agent-brief',
                component: ComponentCreator('/docs/agents/agent-brief', '744'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/agents/model-settings',
                component: ComponentCreator('/docs/agents/model-settings', 'ccc'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/agents/persona',
                component: ComponentCreator('/docs/agents/persona', 'c89'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/agents/setup-agent',
                component: ComponentCreator('/docs/agents/setup-agent', '089'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/agents/system-prompt',
                component: ComponentCreator('/docs/agents/system-prompt', '297'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/agents/user-identity',
                component: ComponentCreator('/docs/agents/user-identity', '9ce'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/agents--personas',
                component: ComponentCreator('/docs/category/agents--personas', 'ac8'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/core-concepts',
                component: ComponentCreator('/docs/category/core-concepts', '409'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/development--installation',
                component: ComponentCreator('/docs/category/development--installation', '19f'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/category/models--apis',
                component: ComponentCreator('/docs/category/models--apis', '279'),
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
                path: '/docs/development/build-from-source',
                component: ComponentCreator('/docs/development/build-from-source', 'eb2'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/development/run-on-ios',
                component: ComponentCreator('/docs/development/run-on-ios', 'a23'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/intro',
                component: ComponentCreator('/docs/intro', '61d'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/auto-balance',
                component: ComponentCreator('/docs/models-and-apis/auto-balance', '79d'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/custom-api',
                component: ComponentCreator('/docs/models-and-apis/custom-api', 'fdb'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/intro',
                component: ComponentCreator('/docs/models-and-apis/intro', '136'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/providers/deepseek',
                component: ComponentCreator('/docs/models-and-apis/providers/deepseek', '021'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/providers/google-gemini',
                component: ComponentCreator('/docs/models-and-apis/providers/google-gemini', '7b2'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/providers/lmstudio',
                component: ComponentCreator('/docs/models-and-apis/providers/lmstudio', '5ff'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/providers/modelscope',
                component: ComponentCreator('/docs/models-and-apis/providers/modelscope', 'cc9'),
                exact: true,
                sidebar: "tutorialSidebar"
              },
              {
                path: '/docs/models-and-apis/providers/openai',
                component: ComponentCreator('/docs/models-and-apis/providers/openai', '2d8'),
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
