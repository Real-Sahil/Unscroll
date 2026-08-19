/**
 * UnScroll Chrome Extension - Background Service Worker
 * Handles policy sync, storage, and cross-tab communication
 */

const STORAGE_KEYS = {
  POLICY: 'unscroll_policy',
  LAST_SYNC: 'unscroll_last_sync',
  PANIC_COOLDOWN_EXPIRES: 'panic_cooldown_expires',
  PROTECTION_DISABLED_AT: 'protection_disabled_at',
  SESSION_DATA: 'session_data',
};

const SYNC_INTERVAL_MINUTES = 30;

// Initialize extension
chrome.runtime.onInstalled.addListener(async (details) => {
  if (details.reason === 'install') {
    console.log('UnScroll extension installed');
    // Open welcome page
    chrome.tabs.create({ url: 'popup/welcome.html' });
  }
});

// Handle messages from popup and content scripts
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  switch (request.action) {
    case 'GET_POLICY':
      chrome.storage.local.get([STORAGE_KEYS.POLICY], (result) => {
        sendResponse({ policy: result[STORAGE_KEYS.POLICY] || null });
      });
      break;

    case 'SET_POLICY':
      chrome.storage.local.set({ [STORAGE_KEYS.POLICY]: request.policy }, () => {
        sendResponse({ success: true });
      });
      break;

    case 'GET_PANIC_COOLDOWN':
      chrome.storage.local.get([STORAGE_KEYS.PANIC_COOLDOWN_EXPIRES], (result) => {
        const expiresAt = result[STORAGE_KEYS.PANIC_COOLDOWN_EXPIRES];
        const isActive = expiresAt && new Date(expiresAt) > new Date();
        sendResponse({ active: isActive, expiresAt });
      });
      break;

    case 'SET_PANIC_COOLDOWN':
      const expiresAt = new Date(Date.now() + request.hours * 60 * 60 * 1000);
      chrome.storage.local.set(
        { [STORAGE_KEYS.PANIC_COOLDOWN_EXPIRES]: expiresAt.toISOString() },
        () => {
          sendResponse({ success: true });
        }
      );
      break;

    case 'LOG_EVENT':
      logEvent(request.event);
      sendResponse({ success: true });
      break;

    case 'SYNC_POLICY':
      syncPolicyFromServer().then(() => {
        sendResponse({ success: true });
      });
      break;

    default:
      sendResponse({ error: 'Unknown action' });
  }

  return true; // Allow async responses
});

/**
 * Sync policy from backend
 * Called on extension load and periodically
 */
async function syncPolicyFromServer() {
  try {
    const lastSync = localStorage.getItem(STORAGE_KEYS.LAST_SYNC);
    const now = new Date();

    // Don't sync too frequently
    if (lastSync && now - new Date(lastSync) < SYNC_INTERVAL_MINUTES * 60 * 1000) {
      return;
    }

    // TODO: Implement Supabase sync when backend is ready
    // For now, use local storage
    localStorage.setItem(STORAGE_KEYS.LAST_SYNC, now.toISOString());

    console.log('UnScroll: Policy synced');
  } catch (error) {
    console.error('UnScroll: Sync failed', error);
  }
}

/**
 * Log relapse/usage events
 */
function logEvent(event) {
  try {
    chrome.storage.local.get([STORAGE_KEYS.SESSION_DATA], (result) => {
      const events = result[STORAGE_KEYS.SESSION_DATA] || [];
      events.push({
        ...event,
        timestamp: new Date().toISOString(),
      });
      chrome.storage.local.set({ [STORAGE_KEYS.SESSION_DATA]: events });
    });
  } catch (error) {
    console.error('UnScroll: Failed to log event', error);
  }
}

// Periodic sync (every 30 minutes)
chrome.alarms.create('syncPolicy', { periodInMinutes: SYNC_INTERVAL_MINUTES });

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'syncPolicy') {
    syncPolicyFromServer();
  }
});

console.log('UnScroll: Background service worker loaded');
