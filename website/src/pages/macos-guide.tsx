import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import Translate, { translate } from '@docusaurus/Translate';
import Heading from '@theme/Heading';

function GuideStep({ number, title, description, path }) {
    return (
        <div className="guide-step animate-fade-in">
            <Heading as="h3">
                <span style={{
                    background: 'var(--ifm-color-primary)',
                    color: 'var(--ifm-background-color)',
                    width: '32px',
                    height: '32px',
                    borderRadius: '50%',
                    display: 'inline-flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '1.2rem'
                }}>{number}</span>
                {title}
            </Heading>
            <p style={{ marginTop: '1rem', fontSize: '1.1rem', opacity: 0.8 }}>{description}</p>
            <div style={{
                background: 'rgba(0,0,0,0.05)',
                height: '400px',
                borderRadius: '8px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginTop: '1.5rem',
                border: '1px dashed #ccc',
                color: '#999'
            }}>
                 <img
                            src={path}
                            alt="App UI Interface"
                            style={{
                              width: '100%',
                              height: '100%',
                              objectFit: 'contain' // 如果想填满但不裁剪用 contain，如果想铺满用 cover
                            }}
                          />
            </div>
        </div>
    );
}

export default function MacOSGuide(): React.ReactNode {
    return (
        <Layout
            title={translate({ id: 'macos_guide.title', message: 'macOS Installation Guide' })}
            description={translate({ id: 'macos_guide.subtitle', message: 'How to install UNICHAT on macOS safety' })}>
            <main className="container margin-vert--xl" style={{ maxWidth: '800px' }}>
                <div style={{ textAlign: 'center', marginBottom: '4rem' }}>
                    <Heading as="h1" style={{ fontSize: '3rem', fontWeight: 800 }}>
                        <Translate id="macos_guide.title">macOS 安全安装指南</Translate>
                    </Heading>
                    <p style={{ fontSize: '1.25rem', opacity: 0.7 }}>
                        <Translate id="macos_guide.subtitle">由于暂未购买 Apple 开发者计划，您需要手动允许应用运行</Translate>
                    </p>
                </div>

                <div className="guide-steps">
                    <GuideStep
                        number="1"
                        title={<Translate id="macos_guide.step1.title">尝试打开</Translate>}
                        description={<Translate id="macos_guide.step1.desc">双击打开下载的 dmg 或应用程序。如果提示“无法验证开发者”，点击取消。</Translate>}
                        path={"/img/macOS_guide/s1cn.png"}
                    />
                    <GuideStep
                        number="2"
                        title={<Translate id="macos_guide.step2.title">前往系统设置</Translate>}
                        description={<Translate id="macos_guide.step2.desc">打开系统设置 - 隐私与安全。向下滚动找到安全性设置。</Translate>}
                        path={"/img/macOS_guide/s2cn.png"}
                    />
                    <GuideStep
                        number="3"
                        title={<Translate id="macos_guide.step3.title">点击“仍要打开”</Translate>}
                        description={<Translate id="macos_guide.step3.desc">在安全性部分点击“仍要打开”，然后输入您的开机密码完成验证。</Translate>}
                        path={"/img/macOS_guide/s3cn.png"}
                    />
                </div>

                <div style={{ textAlign: 'center', marginTop: '5rem', padding: '3rem', background: 'rgba(0,0,0,0.02)', borderRadius: '12px', border: 'var(--uni-card-border)' }}>
                    <Heading as="h2"><Translate id="macos_guide.action">已了解，立即下载</Translate></Heading>
                    <p style={{ opacity: 0.6, marginBottom: '2rem' }}>Intel & Apple Silicon (Universal Target)</p>
                    <Link
                        className="button button--primary button--lg"
                        to="#" // Actual download link placeholder
                        style={{ borderRadius: '8px', padding: '12px 64px' }}>
                        <Translate id="theme.downloadButton">Download Now</Translate>
                    </Link>
                </div>
            </main>
        </Layout>
    );
}
