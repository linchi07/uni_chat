import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import Translate, {translate} from '@docusaurus/Translate';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">
          <Translate id="theme.tagline">A powerful AI chat client.</Translate>
        </p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/download">
            <Translate id="theme.downloadButton">Download Now</Translate>
          </Link>
        </div>
      </div>
    </header>
  );
}

function ImageVideoPlaceholders() {
  return (
    <div className="container" style={{textAlign: 'center', padding: '4rem 0'}}>
      <div style={{border: '2px dashed #ccc', padding: '4rem', marginBottom: '2rem'}}>
        <Translate id="theme.imagePlaceholder">Image Placeholder</Translate>
      </div>
      <div style={{border: '2px dashed #ccc', padding: '4rem'}}>
        <Translate id="theme.videoPlaceholder">Video Placeholder</Translate>
      </div>
    </div>
  );
}

export default function Home(): React.ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={translate({id: 'theme.title', message: `Home`})}
      description={translate({id: 'theme.description', message: 'UNICHAT Official Website'})}>
      <HomepageHeader />
      <main>
        <ImageVideoPlaceholders />
      </main>
    </Layout>
  );
}
