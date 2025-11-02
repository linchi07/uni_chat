import React from 'react';
import Layout from '@theme/Layout';
import Translate, {translate} from '@docusaurus/Translate';

function DownloadPageContent() {
  return (
    <div className="container" style={{padding: '4rem 0', textAlign: 'center'}}>
      <h1><Translate id="theme.downloadPage.title">Download UNICHAT</Translate></h1>
      <p><Translate id="theme.downloadPage.description">Choose your operating system to download.</Translate></p>
      {/* Add OS detection logic here later */}
      <div style={{marginTop: '2rem'}}>
        <a href="#" className="button button--primary button--lg" style={{margin: '0.5rem'}}>
          <Translate id="theme.downloadPage.windows">Download for Windows</Translate>
        </a>
        <a href="#" className="button button--primary button--lg" style={{margin: '0.5rem'}}>
          <Translate id="theme.downloadPage.macos">Download for macOS</Translate>
        </a>
        <a href="#" className="button button--primary button--lg" style={{margin: '0.5rem'}}>
          <Translate id="theme.downloadPage.linux">Download for Linux</Translate>
        </a>
      </div>
    </div>
  );
}

export default function Download(): React.ReactNode {
  return (
    <Layout
      title={translate({id: 'theme.downloadPage.title', message: 'Download UNICHAT'})}
      description={translate({id: 'theme.downloadPage.description', message: 'Download UNICHAT for your OS'})}>
      <main>
        <DownloadPageContent />
      </main>
    </Layout>
  );
}
