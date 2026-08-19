/**
 * Instagram Reels & Stories Blocker
 * Blocks Instagram Reels tab, Stories, and disables autoplay
 */

(function() {
  const REELS_SELECTORS = [
    '[href*="/reels/"]',
    '[href="/reels/"]',
    'a[aria-label*="Reels"]',
    'a[aria-label*="reels"]',
  ];

  const STORIES_SELECTORS = [
    '[href*="/stories/"]',
    'a[aria-label*="Stories"]',
    'a[aria-label*="stories"]',
    '.xh8yej3', // Instagram Stories button class
  ];

  const VIDEO_SELECTORS = [
    'video',
    '[class*="reel"]',
    '[class*="carousel"]',
  ];

  function blockReelsTab() {
    REELS_SELECTORS.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(el => {
        if (el && el.href) {
          el.style.display = 'none';
          el.style.pointerEvents = 'none';
          el.setAttribute('aria-hidden', 'true');
        }
      });
    });
  }

  function blockStories() {
    STORIES_SELECTORS.forEach(selector => {
      const elements = document.querySelectorAll(selector);
      elements.forEach(el => {
        if (el) {
          el.style.display = 'none';
          el.style.pointerEvents = 'none';
          el.setAttribute('aria-hidden', 'true');
        }
      });
    });
  }

  function disableAutoplay() {
    const videos = document.querySelectorAll('video');
    videos.forEach(video => {
      video.autoplay = false;
      video.removeAttribute('autoplay');
    });
  }

  function preventNavigation(e) {
    if (e.target.href && (e.target.href.includes('/reels/') || e.target.href.includes('/stories/'))) {
      e.preventDefault();
      e.stopPropagation();
      console.log('FocusFeed: Blocked navigation to Reels/Stories');
    }
  }

  // Initial blocks
  blockReelsTab();
  blockStories();
  disableAutoplay();

  // Listen for dynamic content
  document.addEventListener('click', preventNavigation, true);

  // MutationObserver for dynamically loaded content
  const observer = new MutationObserver(() => {
    blockReelsTab();
    blockStories();
    disableAutoplay();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  console.log('FocusFeed: Instagram blocker loaded');
})();
