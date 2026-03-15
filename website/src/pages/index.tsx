import React, { useEffect, useState } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import Translate, { translate } from '@docusaurus/Translate';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './index.module.css';
function HomepageHeader() {
  return (
    <header className={clsx('hero', styles.heroBanner)} style={{ textAlign: 'center', padding: '10rem 0 5rem' }}>
      <div className="container">
        <img
          src={useBaseUrl('/img/uni_chat_no_bg.png')}
          alt="UniChatLogo"
          style={{
            width: '100%',
            height: '100px',
            objectFit: 'contain' // 如果想填满但不裁剪用 contain，如果想铺满用 cover
          }}
        />
        <Heading as="h1" className="hero__title animate-fade-in" style={{ fontSize: '4.5rem', fontWeight: 800, animationDelay: '0.1s' }}>
          <Translate id="homepage.title">UNIChat 通聊</Translate>
        </Heading>
        <p className="hero__subtitle animate-fade-in" style={{ animationDelay: '0.3s' }}>
          <Translate id="homepage.subTitle">一起集思广益 — 突破线性限制的 Agent 级对话终端</Translate>
        </p>
        <div className={clsx(styles.buttons, 'animate-fade-in')} style={{ animationDelay: '0.5s' }}>
          <Link
            className="button button--primary button--lg"
            to="/download"
            style={{ borderRadius: '8px', padding: '12px 48px', fontSize: '1.2rem' }}>
            <Translate id="homepage.download">下载 App</Translate>
          </Link>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
            style={{ borderRadius: '8px', padding: '12px 48px', marginLeft: '1rem', fontSize: '1.2rem' }}>
            <Translate id="homepage.getStarted">详细了解</Translate>
          </Link>
        </div>
      </div>
    </header>
  );
}

function HeroVisual() {
  const [scale, setScale] = useState(0.85);
  const [translateY, setTranslateY] = useState(0);
  const { i18n } = useDocusaurusContext();
  useEffect(() => {
    const handleScroll = () => {
      const scrollPos = window.scrollY;
      const windowHeight = window.innerHeight;
      // Calculate scale based on scroll position (0 to 1000px)
      const newScale = Math.min(1.2, 0.85 + (scrollPos / 1500));
      // Parallax upward movement
      const newTranslateY = Math.max(-100, -(scrollPos / 5));

      setScale(newScale);
      setTranslateY(newTranslateY);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className="container" style={{ marginBottom: '10rem' }}>
      <div
        className="hero-visual-container"
        style={{
          transform: `scale(${scale}) translateY(${translateY}px)`,
        }}
      >
        {/* 2. 将原本的占位 div 替换为 <img> */}
        <div style={{
          height: '700px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#f5f5f5',
          borderRadius: '20px', // 可选：让边缘更圆润
          overflow: 'hidden'    // 确保 GIF 不会超出圆角边界
        }}>
          <video src={useBaseUrl(i18n.currentLocale === 'zh-Hans' ? '/img/homepage/title_cn.mp4' : '/img/homepage/title_en.mp4')} autoPlay loop muted playsInline style={{ 
      width: '100%', 
      height: '100%', 
      objectFit: 'cover' // 这里的关键：让视频按比例缩放并裁剪填满容器
    }}></video>
        </div>
      </div>
    </div>
  );
}

interface FeatureItem {
  title: React.ReactNode;
  description: React.ReactNode;
  icon: string;
  image: string;
}

function FeatureList() {
  const { i18n } = useDocusaurusContext();
  return [
    {
      title: <Translate id="feature.agent.title">Agent 级对话架构</Translate>,
      description: (
        <Translate id="feature.agent.desc">
          会话即 Agent。不再是繁琐的角色切换，而是深度绑定的智能交互体验。UNIChat 将 Agent 的配置与会话状态合而为一，让每一次对话都拥有独立的灵魂。
        </Translate>
      ),
      icon: '🤖',
      image: i18n.currentLocale === 'zh-Hans' ? '/img/homepage/agent_cn.png' : '/img/homepage/agent_en.png'
    },
    {
      title: <Translate id="feature.branch.title">真·多分支变体</Translate>,
      description: (
        <Translate id="feature.branch.desc">
          原生支持非线性对话树。随时开启分支，对比不同变体，掌握对话的每一个可能。你可以像写小说一样尝试不同的对话路径，并随时切换回主干。
        </Translate>
      ),
      icon: '🌿',
      image: i18n.currentLocale === 'zh-Hans' ? '/img/homepage/tree_cn.gif' : '/img/homepage/tree_style_en.gif'
    },
    {
      title: <Translate id="feature.persona.title">酒馆级 Persona 系统</Translate>,
      description: (
        <Translate id="feature.persona.desc">
          极致的身份定义。让 Agent 真正理解并记住你的设定。深度适配角色扮演需求，打造极具沉浸感的交互环境。
        </Translate>
      ),
      icon: '🎭',
      image: i18n.currentLocale === 'zh-Hans' ? '/img/homepage/persona_cn.gif' : '/img/homepage/persona_en.gif'
    },
    {
      title: <Translate id="feature.api.title">全能 API 聚合</Translate>,
      description: (
        <Translate id="feature.api.desc">
          内置 DeepSeek, Google, LMStudio 等主流预设。支持自定义 Endpoint，掌控所有模型。无论是本地私有部署模型还是云端顶级 API，一个 App 悉数卷走。
        </Translate>
      ),
      icon: '🔌',
      image: i18n.currentLocale === 'zh-Hans' ? '/img/homepage/multi_provider_cn.gif' : '/img/homepage/model_provider_en.gif'
    },
  ];
}

function FeatureRow({ title, description, icon, image }: FeatureItem) {
  return (
    <div className="feature-row">
      <div className="feature-text">
        <span className="feature-icon-label">{icon}</span>
        <Heading as="h2">{title}</Heading>
        <p>{description}</p>
      </div>
      <div className="feature-visual">
        <div style={{
          height: '600px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#f5f5f5',
          borderRadius: '20px', // 可选：让边缘更圆润
          overflow: 'hidden'    // 确保 GIF 不会超出圆角边界
        }}>
          <img
            src={useBaseUrl(image)}
            alt="App UI Interface"
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'contain' // 如果想填满但不裁剪用 contain，如果想铺满用 cover
            }}
          />
        </div>
      </div>
    </div>
  );
}

export default function Home(): React.ReactNode {
  return (
    <Layout
      title={translate({ id: 'homepage.metaTitle', message: `UNICHAT - 一起集思广益` })}
      description={translate({ id: 'homepage.metaDesc', message: 'UNIChat - 突破线性限制的 Agent 级多分支对话终端' })}>
      <HomepageHeader />
      <main>
        <HeroVisual />
        <section className="container">
          {FeatureList().map((props, idx) => (
            <FeatureRow key={idx} {...props} />
          ))}
        </section>

        {/* Full Platform CTA */}
        <section className="container padding-vert--xl" style={{ borderTop: 'var(--uni-card-border)', marginTop: '5rem', textAlign: 'center' }}>
          <Heading as="h2" style={{ fontSize: '2.5rem', marginBottom: '1.5rem' }}>
            <Translate id="feature.platform.title">全平台原生体验</Translate>
          </Heading>
          <p style={{ maxWidth: '800px', margin: '0 auto 2rem', fontSize: '1.2rem', opacity: 0.8 }}>
            <Translate id="feature.platform.desc">
              一套代码，极致优化。深度适配 macOS, iOS, Windows 和 Android，顺滑如丝。Linux 支持也在计划中。
            </Translate>
          </p>
          <div style={{ fontSize: '3rem', display: 'flex', gap: '2rem', justifyContent: 'center', opacity: 0.7 }}>
            <span>🍎</span><span>🪟</span><span>🤖</span><span>📱</span>
          </div>
        </section>
      </main>
    </Layout>
  );
}
