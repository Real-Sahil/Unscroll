// UnScroll Chrome Extension - Background Service Worker

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'logBlockedAttempt') {
    logBlockedAttemptToStorage({
      app: request.app,
      contentType: request.contentType,
      timestamp: new Date().toISOString(),
      url: sender.url,
    });
    sendResponse({ success: true });
  }
});

// Log blocked attempt to storage
function logBlockedAttemptToStorage(data) {
  chrome.storage.local.get(['blockedAttempts'], (result) => {
    const attempts = result.blockedAttempts || [];
    attempts.push(data);
    
    // Keep last 1000 attempts
    const recentAttempts = attempts.slice(-1000);
    
    chrome.storage.local.set({
      blockedAttempts: recentAttempts,
      lastBlockedAttempt: data.timestamp,
    });
  });
}

// Initialize defaults
chrome.runtime.onInstalled.addListener(() => {
  chrome.storage.local.set({
    protectionActive: true,
    blockedApps: ['instagram_reels', 'youtube_shorts'],
    blockedAttempts: [],
  });
});

// Daily report
chrome.alarms.create('dailyReport', { periodInMinutes: 24 * 60 });

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'dailyReport') {
    generateDailyReport();
  }
});

function generateDailyReport() {
  chrome.storage.local.get(['blockedAttempts'], (result) => {
    const attempts = result.blockedAttempts || [];
    const today = new Date().toDateString();
    
    const todayAttempts = attempts.filter((a) => {
      return new Date(a.timestamp).toDateString() === today;
    });
    
    const summary = {
      date: today,
      totalBlocked: todayAttempts.length,
      byApp: {},
    };
    
    todayAttempts.forEach((attempt) => {
      summary.byApp[attempt.app] = (summary.byApp[attempt.app] || 0) + 1;
    });
    
    chrome.storage.local.set({
      dailyReport: summary,
    });
  });
}
