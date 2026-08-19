/**
 * YouTube Shorts Blocker
 * Blocks YouTube Shorts and disables autoplay
 */

(function() {
  const SHORTS_SELECTORS = [
    'a[href*="/shorts/"]',
    '[href*="youtube.com/shorts"]',
    'a[aria-label*="Shorts"]',
  ];

  const GUIDE_ITEMS = [
    'ytd-guide-entry-renderer:has-text("Shorts")',
  ];

  function blockShorts() {
    SHORTS_SELECTORS.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(el => {
        if (el && el.href) {
          el.style.display = 'none';
          el.style.pointerEvents = 'none';
          el.setAttribute('aria-hidden', 'true');
        }
      });
    });

    // Block Shorts from sidebar
    const sidebarItems = document.querySelectorAll('ytd-guide-entry-renderer');
    sidebarItems.forEach(item => {
      const text = item.textContent;
      if (text && text.includes('Shorts')) {
        item.style.display = 'none';
        item.style.pointerEvents = 'none';
      }
    });
  }

  function disableAutoplay() {
    // Disable autoplay via video element
    const videos = document.querySelectorAll('video');
    videos.forEach(video => {
      video.autoplay = false;
      video.removeAttribute('autoplay');
    });

    // Disable autoplay toggle in settings
    try {
      const settingsPanel = document.querySelector('tp-yt-paper-toggle-button[aria-label*="autoplay"]');
      if (settingsPanel && !settingsPanel.getAttribute('aria-checked')) {
        settingsPanel.click();
      }
    } catch (e) {
      console.debug('FocusFeed: Could not disable autoplay via UI');
    }
  }

  function preventShortsNavigation(e) {
    const target = e.target.closest('a');
    if (target && target.href && target.href.includes('/shorts/')) {
      e.preventDefault();
      e.stopPropagation();
      console.log('FocusFeed: Blocked navigation to YouTube Shorts');
    }
  }

  // Initial blocks
  blockShorts();
  disableAutoplay();

  // Listen for navigation
  document.addEventListener('click', preventShortsNavigation, true);

  // MutationObserver for dynamically loaded content
  const observer = new MutationObserver(() => {
    blockShorts();
    disableAutoplay();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  console.log('FocusFeed: YouTube blocker loaded');
})();
