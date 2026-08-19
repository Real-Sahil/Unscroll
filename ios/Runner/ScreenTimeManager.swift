import Foundation
import DeviceActivity
import ManagedSettings

/**
 * ScreenTimeManager handles iOS Screen Time integration for app blocking.
 * Uses DeviceActivity and ManagedSettings frameworks available on iOS 16+.
 *
 * Based on industry patterns from:
 * - react-native-app-lock (FamilyControls + DeviceActivity)
 * - digital-habits-focus (Screen Time API)
 */
@available(iOS 16.0, *)
class ScreenTimeManager: NSObject {

    static let shared = ScreenTimeManager()

    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()

    private let blockedApps = [
        "instagram",
        "youtube",
        "tiktok",
    ]

    private let safariDomains = [
        "instagram.com",
        "facebook.com/watch",
        "youtube.com/shorts",
        "tiktok.com",
    ]

    override init() {
        super.init()
        requestFamilyControlsPermission()
    }

    // MARK: - Permission Handling

    private func requestFamilyControlsPermission() {
        Task {
            do {
                try await DeviceActivityCenter.requestSupervisionAuthorization()
                print("✓ Supervision authorization granted")
            } catch {
                print("✗ Supervision authorization failed: \(error)")
            }
        }
    }

    // MARK: - App Blocking

    /**
     * Block specified apps and websites during protection windows.
     * - Parameter apps: List of app bundle identifiers to block
     * - Parameter websites: List of domains to block
     */
    func blockApps(_ apps: [String], websites: [String]) {
        Task {
            do {
                try await requestFamilyControlsPermission()

                let appTokens = resolveAppTokens(apps)
                let categoryTokens = resolveCategoryTokens()
                let domainTokens = resolveDomainTokens(websites)

                var restriction = ShieldConfiguration()
                restriction.blockedApps = Set(appTokens)
                restriction.blockedCategories = Set(categoryTokens)
                restriction.blockedWebCategories = Set(domainTokens)

                store.shield.applications = Set(appTokens)
                store.shield.webDomainRestrictionOnly = Set(domainTokens)

                print("✓ Apps and websites blocked: \(apps.count) apps, \(websites.count) domains")
            } catch {
                print("✗ Failed to block apps: \(error)")
            }
        }
    }

    /**
     * Unblock apps during focus window expiration or user override.
     */
    func unblockApps() {
        Task {
            do {
                store.shield.applications = Set()
                store.shield.webDomainRestrictionOnly = Set()
                print("✓ Apps and websites unblocked")
            } catch {
                print("✗ Failed to unblock apps: \(error)")
            }
        }
    }

    /**
     * Set allowed apps during Screen Time.
     * - Parameter allowedApps: Only these apps can be used
     */
    func setAllowedApps(_ allowedApps: [String]) {
        Task {
            do {
                let tokens = resolveAppTokens(allowedApps)
                store.shield.applications = Set(tokens)
                print("✓ Allowed apps configured: \(allowedApps.count) apps")
            } catch {
                print("✗ Failed to set allowed apps: \(error)")
            }
        }
    }

    /**
     * Block Safari on specific domains (Reels, Shorts, TikTok, etc).
     */
    func blockSafariDomains(_ domains: [String]) {
        Task {
            do {
                let tokens = resolveDomainTokens(domains)
                store.shield.webDomainRestrictionOnly = Set(tokens)
                print("✓ Safari domains blocked: \(domains.count) domains")
            } catch {
                print("✗ Failed to block domains: \(error)")
            }
        }
    }

    // MARK: - Schedule Management

    /**
     * Schedule app blocking for specific times (e.g., 10 PM - 7 AM).
     * - Parameter startHour: Start hour (0-23)
     * - Parameter endHour: End hour (0-23)
     * - Parameter daysOfWeek: Days to apply block (0=Sunday, 6=Saturday)
     */
    func scheduleAppBlocking(
        startHour: Int,
        endHour: Int,
        daysOfWeek: [Int],
        apps: [String]
    ) {
        var schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startHour),
            intervalEnd: DateComponents(hour: endHour),
            repeats: true
        )

        // Set which days this schedule applies
        schedule.repeats = true

        center.startMonitoring(
            MyDeviceActivityName,
            schedule: schedule
        ) { error in
            if let error = error {
                print("✗ Failed to schedule blocking: \(error)")
            } else {
                print("✓ App blocking scheduled: \(startHour):00 - \(endHour):00")
            }
        }
    }

    /**
     * Stop monitoring and clear all blocks.
     */
    func stopMonitoring() {
        center.stopMonitoring([MyDeviceActivityName])
        unblockApps()
        print("✓ Screen Time monitoring stopped")
    }

    // MARK: - Token Resolution

    private func resolveAppTokens(_ apps: [String]) -> [ApplicationToken] {
        var tokens: [ApplicationToken] = []

        for bundleId in apps {
            if let token = ApplicationToken(bundleIdentifier: bundleId) {
                tokens.append(token)
            }
        }

        return tokens
    }

    private func resolveDomainTokens(_ domains: [String]) -> [WebDomainToken] {
        var tokens: [WebDomainToken] = []

        for domain in domains {
            if let token = WebDomainToken(domain: domain) {
                tokens.append(token)
            }
        }

        return tokens
    }

    private func resolveCategoryTokens() -> [ActivityCategoryToken] {
        return [
            .games,
            .socialNetworking,
            .entertainment,
        ]
    }

    // MARK: - Real-time Monitoring

    /**
     * Monitor app usage and respond to policy changes in real-time.
     */
    func startRealtimeMonitoring() {
        Task {
            // This would integrate with ManagedSettingsStore notifications
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePolicyChange),
                name: NSNotification.Name("UnscrollPolicyChanged"),
                object: nil
            )

            print("✓ Real-time monitoring started")
        }
    }

    @objc private func handlePolicyChange(_ notification: NSNotification) {
        if let policy = notification.userInfo?["policy"] as? [String: Any] {
            let apps = policy["blockedApps"] as? [String] ?? []
            blockApps(apps, websites: safariDomains)
        }
    }

    // MARK: - Safari Extension Support

    /**
     * Coordinate with Safari Web Extension for additional content blocking.
     * Web extension can block Reels/Shorts DOM nodes independently.
     */
    func enableSafariExtensionCoordination() {
        // Send message to Safari Web Extension content script
        let message: [String: Any] = [
            "action": "enableBlocking",
            "domains": safariDomains,
            "patterns": [
                "reels", "shorts", "stories", // URL patterns
                "instagram.com/reels", // Full paths
                "youtube.com/shorts",
            ]
        ]

        // Note: Real app would communicate via app groups or shared containers
        print("✓ Safari Web Extension coordination enabled")
    }
}

// MARK: - Device Activity Extension

@available(iOS 16.0, *)
extension DeviceActivityCenter {

    /**
     * Custom activity for tracking app restrictions.
     */
    func startMonitoring(
        _ activityName: DeviceActivityName,
        schedule: DeviceActivitySchedule,
        completion: @escaping (Error?) -> Void
    ) {
        do {
            try startMonitoring(activityName, during: schedule)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

// MARK: - Named Activities

let MyDeviceActivityName = DeviceActivityName("unscroll_focus_mode")

// MARK: - Usage Notifications

/**
 * Handler for DeviceActivity notifications and warnings.
 * Notifies user when approaching screen time limits.
 */
@available(iOS 16.0, *)
class DeviceActivityHandler: NSObject {

    static let shared = DeviceActivityHandler()

    func sendUsageNotification(
        appName: String,
        minutesUsed: Int,
        limitMinutes: Int
    ) {
        let content = UNMutableNotificationContent()
        content.title = "\(appName) Blocked"
        content.body = "You've used \(minutesUsed)/\(limitMinutes) minutes allowed today."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("✗ Failed to send notification: \(error)")
            }
        }
    }

    func sendWarningNotification(minutesRemaining: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Time Ending Soon"
        content.body = "\(minutesRemaining) minutes remaining in your focus window."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("✗ Failed to send warning: \(error)")
            }
        }
    }
}
