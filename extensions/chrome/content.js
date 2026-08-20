// UnScroll Chrome Extension - Content Script
// Blocks Instagram Reels and YouTube Shorts

const CONFIG = {
  instagramReelsSelector: 'a[href="/reels/"], a[href*="/reels/"], [aria-label*="Reel"]',
  youtubeShortSelector: 'a[href*="/shorts/"], ytd-rich-shelf-renderer[is-short-form]',
  blockedClass: 'unscroll-blocked',
};

// Initialize
chrome.storage.local.get(['protectionActive', 'blockedApps'], (data) => {
  const protectionActive = data.protectionActive !== false;
  const blockedApps = data.blockedApps || ['instagram_reels', 'youtube_shorts'];
  
  if (!protectionActive) return;
  
  initializeBlocking(blockedApps);
});

// Listen for settings changes
chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName !== 'local') return;
  
  if (changes.protectionActive || changes.blockedApps) {
    location.reload();
  }
});

// MARK: - Blocking Functions

function initializeBlocking(blockedApps) {
  // Block Instagram Reels
  if (blockedApps.includes('instagram_reels') && isInstagram()) {
    blockInstagramReels();
    observeForNewReels();
  }
  
  // Block YouTube Shorts
  if (blockedApps.includes('youtube_shorts') && isYoutube()) {
    blockYoutubeShorts();
    observeForNewShorts();
  }
}

function isInstagram() {
  return window.location.hostname.includes('instagram.com');
}

function isYoutube() {
  return window.location.hostname.includes('youtube.com');
}

function blockInstagramReels() {
  // Hide Reels from feed
  const reelsElements = document.querySelectorAll(
    'a[href="/reels/"], a[href*="/reels/"], [aria-label*="Reel"]'
  );
  
  reelsElements.forEach((el) => {
    hideElement(el);
    logBlockedAttempt('instagram', 'reels');
  });
  
  // Redirect /reels/ navigation
  if (window.location.pathname === '/reels/' || window.location.pathname.startsWith('/reels/')) {
    showBlockedNotification('Instagram Reels are blocked');
    window.history.pushState({}, '', '/');
  }
}

function blockYoutubeShorts() {
  // Hide Shorts from sidebar
  const shortElements = document.querySelectorAll(
    'a[href*="/shorts/"], ytd-rich-shelf-renderer[is-short-form]'
  );
  
  shortElements.forEach((el) => {
    hideElement(el);
    logBlockedAttempt('youtube', 'shorts');
  });
  
  // Redirect /shorts/ navigation
  if (window.location.pathname.startsWith('/shorts/')) {
    showBlockedNotification('YouTube Shorts are blocked');
    window.history.pushState({}, '', '/');
  }
}

function observeForNewReels() {
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === 'childList') {
        const reelsElements = mutation.addedNodes[0]?.querySelectorAll?.(
          'a[href="/reels/"], [aria-label*="Reel"]'
        ) || [];
        
        reelsElements.forEach((el) => {
          hideElement(el);
          logBlockedAttempt('instagram', 'reels');
        });
      }
    });
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
}

function observeForNewShorts() {
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === 'childList') {
        const shortElements = mutation.addedNodes[0]?.querySelectorAll?.(
          'a[href*="/shorts/"]'
        ) || [];
        
        shortElements.forEach((el) => {
          hideElement(el);
          logBlockedAttempt('youtube', 'shorts');
        });
      }
    });
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true,
  });
}

function hideElement(element) {
  element.classList.add(CONFIG.blockedClass);
  element.style.display = 'none';
}

function showBlockedNotification(message) {
  const notification = document.createElement('div');
  notification.className = 'unscroll-notification';
  notification.textContent = `🛡️ ${message}`;
  notification.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: #ff6b6b;
    color: white;
    padding: 16px 24px;
    border-radius: 8px;
    font-weight: 500;
    z-index: 99999;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  `;
  
  document.body.appendChild(notification);
  
  setTimeout(() => {
    notification.remove();
  }, 3000);
}

function logBlockedAttempt(app, contentType) {
  chrome.runtime.sendMessage({
    action: 'logBlockedAttempt',
    app,
    contentType,
  });
}
