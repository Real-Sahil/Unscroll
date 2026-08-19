/**
 * TikTok Blocker
 * Blocks TikTok main feed and redirects to safe pages
 */

(function() {
  const TIKTOK_FEED_SELECTORS = [
    '[data-testid="feed"]',
    'div[class*="feed"]',
    '[class*="video-feed"]',
  ];

  const AUTOPLAY_SELECTORS = [
    'video[autoplay]',
    '[class*="autoplay"]',
  ];

  function blockFeed() {
    TIKTOK_FEED_SELECTORS.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(el => {
        if (el && el.id === 'feed') {
          const blocker = document.createElement('div');
          blocker.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, #00A3FF 0%, #00AA66 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            z-index: 10000;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          `;
          blocker.innerHTML = `
            <div style="color: white; text-align: center;">
              <h2 style="font-size: 28px; margin-bottom: 16px;">
                🛡️ Protected
              </h2>
              <p style="font-size: 16px; margin-bottom: 32px;">
                You're in control. Take a break from the feed.
              </p>
              <button style="
                background: white;
                color: #0066CC;
                border: none;
                padding: 12px 32px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
              " onclick="window.history.back();">
                Go Back
              </button>
            </div>
          `;
          el.replaceWith(blocker);
        }
      });
    });
  }

  function disableAutoplay() {
    const videos = document.querySelectorAll('video');
    videos.forEach(video => {
      video.autoplay = false;
      video.removeAttribute('autoplay');
      video.pause();
    });
  }

  function redirectToHome() {
    if (window.location.pathname === '/' && window.location.hostname.includes('tiktok')) {
      const blocker = document.createElement('div');
      blocker.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(135deg, #00A3FF 0%, #00AA66 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      `;
      blocker.innerHTML = `
        <div style="color: white; text-align: center;">
          <h1 style="font-size: 32px; margin-bottom: 16px;">FocusFeed</h1>
          <p style="font-size: 16px; margin-bottom: 8px;">Taking a break from TikTok</p>
          <p style="font-size: 14px; opacity: 0.9;">You're building a healthier relationship with social media.</p>
        </div>
      `;
      document.body.replaceChildren(blocker);
    }
  }

  // Initial blocks
  blockFeed();
  disableAutoplay();
  redirectToHome();

  // MutationObserver for dynamic content
  const observer = new MutationObserver(() => {
    blockFeed();
    disableAutoplay();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  console.log('FocusFeed: TikTok blocker loaded');
})();
