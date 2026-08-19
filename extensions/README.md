# UnScroll Browser Extensions

Browser extensions for blocking Instagram Reels, YouTube Shorts, and TikTok feeds across Chrome and Safari.

## Features

- **Instagram Blocker:** Hide Reels tab, Stories, and disable autoplay
- **YouTube Blocker:** Hide Shorts in sidebar and search results, disable autoplay
- **TikTok Blocker:** Block main feed with compassionate UI
- **Local Policy Enforcement:** Respects schedules and friction settings from mobile app
- **Panic Button:** Quick cooldown triggers across all platforms
- **Sync with Mobile:** Realtime policy updates from Supabase (coming soon)

## Chrome Extension

### Installation (Development)

1. Open `chrome://extensions/`
2. Enable "Developer mode" (top-right)
3. Click "Load unpacked"
4. Select `extensions/chrome/` directory

### Structure

```
chrome/
├── manifest.json              # Extension metadata
├── content/
│   ├── instagram-blocker.js   # Instagram content script
│   ├── youtube-blocker.js     # YouTube content script
│   └── tiktok-blocker.js      # TikTok content script
├── background/
│   └── background.js          # Service worker for policy sync
└── popup/
    ├── popup.html
    ├── popup.js
    └── popup.css
```

### Content Scripts

Each content script runs on specific domains and:

1. **Removes/hides** UI elements (Reels tab, Shorts button, TikTok feed)
2. **Prevents navigation** to blocked pages
3. **Disables autoplay** on videos
4. **Observes DOM** for dynamically added content

### Background Service Worker

- Syncs policies from Supabase every 30 minutes
- Stores policies locally in `chrome.storage.local`
- Handles cross-tab communication
- Logs relapse events

### Communication Flow

```
Content Script → Background → Storage → Next Tab
    (block action)    (log event)  (persist)  (apply policy)
```

## Safari Extension

### Installation (Development)

1. Open Xcode
2. Create Safari App Extension project
3. Link content scripts to domains:
   - `instagram.com`, `m.instagram.com`
   - `youtube.com`, `m.youtube.com`
   - `tiktok.com`
4. Build and run on macOS/iOS

### Constraints (Safari)

- Content script injection via `Web Extension` framework
- Limited to DOM manipulation (no native API access)
- Requires explicit permission in extension settings

## Implementation Notes

### Current Phase (MVP)

- ✅ Content script blocking (hide elements, prevent navigation)
- ✅ Autoplay disable
- ✅ Local storage of policies
- ✅ DOM observation for dynamic content

### Next Phase (v1)

- [ ] Supabase Realtime sync
- [ ] Panic button trigger via message passing
- [ ] Usage event tracking
- [ ] Cross-device policy consistency
- [ ] Advanced friction options

## Testing

### Content Script Testing

1. Open Instagram/YouTube/TikTok in Chrome with extension loaded
2. Verify Reels/Shorts are hidden
3. Check browser console for "FocusFeed: blocker loaded"
4. Try clicking hidden elements (should be prevented)

### Background Script Testing

1. Open `chrome://extensions/` and view background page
2. Check console logs for sync messages
3. Verify `chrome.storage.local` has policy data

## Security Considerations

- Content scripts run with same origin as page (DOM access only)
- No access to sensitive data (credentials, passwords)
- Policy data stored locally in extension storage
- HTTPS-only communication with Supabase (future)
- Certificate pinning optional for Supabase API

## Performance

- Minimal DOM observation (10-50ms per mutation)
- Light MutationObserver to avoid performance issues
- Policy checks cached in local storage
- Sync happens every 30 minutes (configurable)

## Debugging

Enable logs by checking extension details page:
1. `chrome://extensions/`
2. Enable "Developer mode"
3. Click "Inspect views: background page"
4. Check console for FocusFeed logs

---

See main `CLAUDE.md` for full project documentation.
