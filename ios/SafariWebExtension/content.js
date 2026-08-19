/**
 * Safari Web Extension Content Script for UnScroll
 * Blocks Instagram Reels, YouTube Shorts, TikTok, and related content
 *
 * Based on industry patterns from:
 * - slowth (Safari extension for Reels/Shorts/TikTok)
 * - digital-habits-focus (Safari extension)
 * - beyluta/swift-shorts-blocker (YouTube Shorts blocker)
 */

// Configuration
const BLOCKED_SELECTORS = {
  instagram: [
    '[href="/reels/"]',
    '[href*="/reels/"]',
    'a[href*="instagram.com/reels"]',
    '[aria-label*="Reels"]',
    '[role="button"][aria-label*="Reels"]',
    'div[data-testid="reels_tab"]',
    'a[href*="instagram.com/stories"]',
    'svg[aria-label*="Stories"]',
  ],
  youtube: [
    'ytm-single-column-browse-results-grid-renderer[page-subtype="shorts"]',
    'a[href="/shorts"]',
    'a[href*="/shorts/"]',
    '[title="Shorts"]',
    '[aria-label="Shorts"]',
    'yt-formatted-string:contains("Shorts")',
  ],
  tiktok: [
    'a[href="/following"]',
    'a[href="/discover"]',
    'a[href="/"]',
    '[data-testid="side-nav-homepage"]',
  ],
  facebook: [
    'a[href="/watch"]',
    '[aria-label="Watch"]',
    '[data-testid="reel"]',
  ],
};

const BLOCKED_URLS = [
  /instagram\.com\/reels\//i,
  /instagram\.com\/stories\//i,
  /youtube\.com\/shorts\//i,
  /youtu\.be\/shorts\//i,
  /tiktok\.com\/@.*\/video\//i,
  /facebook\.com\/watch\//i,
];

// State management
let isProtectionEnabled = false;
let blockedDomains = [];
let blockCounters = {
  instagram: 0,
  youtube: 0,
  tiktok: 0,
  facebook: 0,
};

// Initialize extension
function init() {
  loadSettings();
  if (isProtectionEnabled) {
    blockContent();
    monitorDOMChanges();
    interceptNavigation();
  }
  setupMessageListener();
}

/**
 * Load settings from extension storage
 */
function loadSettings() {
  browser.storage.local.get(['enabled', 'blockedDomains'], (result) => {
    isProtectionEnabled = result.enabled || false;
    blockedDomains = result.blockedDomains || [];

    if (isProtectionEnabled) {
      blockContent();
    }
  });
}

/**
 * Block short-form content on page load
 */
function blockContent() {
  const currentDomain = window.location.hostname;

  // Instagram blocking
  if (currentDomain.includes('instagram.com')) {
    blockInstagramReels();
    blockInstagramStories();
  }

  // YouTube blocking
  if (currentDomain.includes('youtube.com') || currentDomain.includes('youtu.be')) {
    blockYouTubeShorts();
  }

  // TikTok blocking
  if (currentDomain.includes('tiktok.com')) {
    blockTikTok();
  }

  // Facebook Watch blocking
  if (currentDomain.includes('facebook.com')) {
    blockFacebookWatch();
  }
}

/**
 * Block Instagram Reels and Stories
 */
function blockInstagramReels() {
  // Hide Reels tab
  const reelsButtons = document.querySelectorAll(
    'a[href="/reels/"], [aria-label="Reels"], [data-testid="reels_tab"]'
  );

  reelsButtons.forEach((button) => {
    button.style.display = 'none';
    button.setAttribute('aria-hidden', 'true');
  });

  // Prevent navigation to Reels
  const reelsLinks = document.querySelectorAll('a[href*="instagram.com/reels"]');
  reelsLinks.forEach((link) => {
    link.removeAttribute('href');
    link.style.opacity = '0.5';
    link.style.cursor = 'not-allowed';
    link.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      showBlockNotification('Instagram Reels are blocked');
    });
  });

  // Block Stories
  const storiesElements = document.querySelectorAll(
    '[aria-label*="Stories"], [href*="stories"]'
  );
  storiesElements.forEach((element) => {
    element.style.display = 'none';
  });

  blockCounters.instagram++;
  console.log('✓ Instagram Reels & Stories blocked');
}

/**
 * Block YouTube Shorts
 */
function blockYouTubeShorts() {
  // Hide Shorts in sidebar
  const shortsButton = document.querySelector('[aria-label="Shorts"]');
  if (shortsButton) {
    shortsButton.closest('a')?.style.display = 'none';
  }

  // Block shorts URL
  const shortsLinks = document.querySelectorAll('a[href*="/shorts"]');
  shortsLinks.forEach((link) => {
    link.style.pointerEvents = 'none';
    link.style.opacity = '0.5';
    link.addEventListener('click', (e) => {
      e.preventDefault();
      showBlockNotification('YouTube Shorts are blocked');
    });
  });

  // Redirect if already on shorts page
  if (window.location.href.includes('/shorts/')) {
    showBlockPage('YouTube Shorts are blocked during your focus time');
  }

  blockCounters.youtube++;
  console.log('✓ YouTube Shorts blocked');
}

/**
 * Block TikTok navigation
 */
function blockTikTok() {
  // Block main feed navigation
  const feedLinks = document.querySelectorAll(
    'a[href="/"], a[href="/discover"], a[href="/following"]'
  );

  feedLinks.forEach((link) => {
    link.removeAttribute('href');
    link.style.cursor = 'not-allowed';
    link.style.opacity = '0.5';
    link.addEventListener('click', (e) => {
      e.preventDefault();
      showBlockNotification('TikTok is blocked');
    });
  });

  blockCounters.tiktok++;
  console.log('✓ TikTok blocked');
}

/**
 * Block Facebook Watch
 */
function blockFacebookWatch() {
  const watchLinks = document.querySelectorAll('a[href*="facebook.com/watch"]');
  watchLinks.forEach((link) => {
    link.style.display = 'none';
  });

  if (window.location.href.includes('/watch/')) {
    showBlockPage('Facebook Watch is blocked during your focus time');
  }

  blockCounters.facebook++;
  console.log('✓ Facebook Watch blocked');
}

/**
 * Monitor DOM changes for dynamically loaded content
 */
function monitorDOMChanges() {
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === 'childList') {
        // Re-run blocking on new content
        blockContent();
      }
    });
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true,
    attributes: false,
  });

  console.log('✓ DOM change monitoring started');
}

/**
 * Intercept navigation attempts
 */
function interceptNavigation() {
  document.addEventListener('click', (e) => {
    const link = e.target.closest('a');
    if (!link) return;

    const href = link.getAttribute('href') || '';
    const isBlockedURL = BLOCKED_URLS.some((pattern) => pattern.test(href));

    if (isBlockedURL && isProtectionEnabled) {
      e.preventDefault();
      e.stopPropagation();
      showBlockNotification('This content is blocked');
    }
  }, true);

  console.log('✓ Navigation interception active');
}

/**
 * Show block notification to user
 */
function showBlockNotification(message) {
  const notification = document.createElement('div');
  notification.innerHTML = `
    <div style="
      position: fixed;
      top: 20px;
      right: 20px;
      background: #FF8C00;
      color: white;
      padding: 12px 16px;
      border-radius: 8px;
      font-weight: 500;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      z-index: 999999;
      animation: slideIn 0.3s ease-out;
    ">
      ${message}
    </div>
    <style>
      @keyframes slideIn {
        from {
          transform: translateX(400px);
          opacity: 0;
        }
        to {
          transform: translateX(0);
          opacity: 1;
        }
      }
    </style>
  `;

  document.body.appendChild(notification);

  setTimeout(() => notification.remove(), 3000);
}

/**
 * Show block page for full-page content
 */
function showBlockPage(message) {
  const blockPage = `
    <html>
      <head>
        <title>Content Blocked</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #0066CC 0%, #00A3FF 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            color: white;
          }
          .container {
            text-align: center;
            padding: 40px;
          }
          h1 { font-size: 32px; margin: 0 0 16px 0; }
          p { font-size: 16px; margin: 0; opacity: 0.9; }
          button {
            margin-top: 24px;
            padding: 12px 24px;
            background: white;
            color: #0066CC;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🎯 Content Blocked</h1>
          <p>${message}</p>
          <p style="margin-top: 16px; opacity: 0.7;">Focus Mode is protecting your attention</p>
          <button onclick="window.history.back()">Go Back</button>
        </div>
      </body>
    </html>
  `;

  document.documentElement.innerHTML = blockPage;
}

/**
 * Setup message listener for communication with native app
 */
function setupMessageListener() {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    switch (message.action) {
      case 'enableBlocking':
        isProtectionEnabled = true;
        blockContent();
        monitorDOMChanges();
        sendResponse({ status: 'enabled' });
        break;

      case 'disableBlocking':
        isProtectionEnabled = false;
        location.reload();
        sendResponse({ status: 'disabled' });
        break;

      case 'getStats':
        sendResponse({ blockCounters });
        break;

      default:
        sendResponse({ status: 'unknown' });
    }
  });
}

/**
 * Listen for setting changes
 */
browser.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'local' && changes.enabled) {
    isProtectionEnabled = changes.enabled.newValue;
    if (isProtectionEnabled) {
      blockContent();
    }
  }
});

// Initialize on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}

console.log('UnScroll Safari Web Extension loaded');
