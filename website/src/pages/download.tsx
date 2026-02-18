import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import Translate, { translate } from '@docusaurus/Translate';
import Heading from '@theme/Heading';

function DownloadCard({ icon, title, description, link, isGuide = false }) {
  return (
    <div className="download-card">
      <div className="download-icon">{icon}</div>
      <Heading as="h3">{title}</Heading>
      <p>{description}</p>
      <Link
        className={clsx('button button--lg', isGuide ? 'button--secondary' : 'button--primary')}
        to={link}
        style={{ borderRadius: '8px' }}>
        <Translate id="theme.downloadButton">Download Now</Translate>
      </Link>
    </div>
  );
}

import clsx from 'clsx';

export default function Download(): React.ReactNode {
  return (
    <Layout
      title={translate({ id: 'download.title', message: 'Get UNICHAT' })}
      description={translate({ id: 'download.subtitle', message: 'Experience Agent-level Chat on all your devices' })}>
      <main className="container margin-vert--xl">
        <div style={{ textAlign: 'center', marginBottom: '4rem' }}>
          <Heading as="h1" style={{ fontSize: '3.5rem', fontWeight: 800 }}>
            <Translate id="download.title">Get UNICHAT</Translate>
          </Heading>
          <p style={{ fontSize: '1.25rem', opacity: 0.7 }}>
            <Translate id="download.subtitle">Experience Agent-level Chat on all your devices</Translate>
          </p>
        </div>

        <div className="download-grid">
          <DownloadCard
            icon="🪟"
            title={<Translate id="download.win.title">Windows</Translate>}
            description={<Translate id="download.win.desc">For Windows 10/11 (x64)</Translate>}
            link="#" // Release link placeholder
          />
          <DownloadCard
            icon="🍎"
            title={<Translate id="download.mac.title">macOS</Translate>}
            description={<Translate id="download.mac.desc">Intel & Apple Silicon Support</Translate>}
            link="/macos-guide"
          />
          <DownloadCard
            icon="🤖"
            title={<Translate id="download.android.title">Android</Translate>}
            description={<Translate id="download.android.desc">For Android 8.0 or later</Translate>}
            link="#" // Release link placeholder
          />
          <DownloadCard
            icon="📱"
            title={<Translate id="download.ios.title">iOS (IPA)</Translate>}
            description={<Translate id="download.ios.desc">Install via Sideloadly or AltStore</Translate>}
            link="https://github.com/linchi07/uni_chat/wiki/iOS-Installation" // Doc link placeholder
          />
        </div>

        <div style={{ textAlign: 'center', marginTop: '4rem' }}>
          <Link
            className="button button--secondary button--lg"
            to="https://github.com/linchi07/uni_chat/releases"
            style={{ borderRadius: '8px' }}>
            <Translate id="download.github">View Releases on GitHub</Translate>
          </Link>
        </div>
      </main>
    </Layout>
  );
}
