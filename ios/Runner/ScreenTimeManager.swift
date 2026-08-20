import Foundation
import FamilyControls
import DeviceActivity

@available(iOS 16.1, *)
class ScreenTimeManager {
    static let shared = ScreenTimeManager()
    
    private let deviceActivityCenter = DeviceActivityCenter()
    private var authorizedApps: Set<String> = []
    
    // MARK: - Setup
    func requestFamilyControlsAuthorization(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await FamilyControls.requestAuthorization()
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Block Apps
    func blockApps(_ appIdentifiers: [String], until expireDate: Date) {
        Task {
            do {
                let restriction = ShieldRestrictionPolicy(
                    blockedApplications: Set(appIdentifiers.compactMap { identifier in
                        return findApplication(identifier)
                    }),
                    blockedCategories: []
                )
                
                var schedule = DeviceActivitySchedule(every: .day)
                schedule.repeats = true
                
                let activity = DeviceActivityName("unscroll-protection")
                
                try await deviceActivityCenter.startMonitoring(
                    activity,
                    during: schedule,
                    using: restriction
                )
            } catch {
                print("Error blocking apps: \(error)")
            }
        }
    }
    
    // MARK: - Unblock Apps
    func unblockApps() {
        Task {
            do {
                let activity = DeviceActivityName("unscroll-protection")
                try await deviceActivityCenter.stopMonitoring([activity])
            } catch {
                print("Error unblocking apps: \(error)")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func findApplication(_ bundleIdentifier: String) -> Application? {
        // Maps common app names to their bundle identifiers
        let appMap: [String: String] = [
            "instagram": "com.instagram.ios",
            "tiktok": "com.zhiliaoapp.musically",
            "youtube": "com.google.ios.youtube",
            "facebook": "com.facebook.Facebook",
            "twitter": "com.twitter.twitter",
            "reddit": "com.reddit.Reddit",
        ]
        
        let actualIdentifier = appMap[bundleIdentifier.lowercased()] ?? bundleIdentifier
        return Application(bundleIdentifier: actualIdentifier)
    }
    
    // MARK: - Status Check
    func isProtectionActive() -> Bool {
        let activity = DeviceActivityName("unscroll-protection")
        return deviceActivityCenter.isMonitoring(activity)
    }
}

// MARK: - Managed Settings Wrapper
@available(iOS 16.1, *)
class ManagedSettingsManager {
    static let shared = ManagedSettingsManager()
    
    private let store = ManagedSettingsStore()
    
    func applyScreenTimeRestrictions(
        blockedApps: [String],
        weekdaySchedule: (startHour: Int, startMinute: Int, endHour: Int, endMinute: Int)
    ) {
        let applications = blockedApps.compactMap { app in
            return findApplicationByName(app)
        }
        
        store.shield.applications = Set(applications)
        store.shield.webDomainRestrictionOnly = []
        
        // Set communication limit schedule if needed
        store.dateAndTime.automaticTimeZoneEnabled.isEnabled = true
    }
    
    func clearRestrictions() {
        store.shield.applications = nil
        store.shield.webDomainRestrictionOnly = nil
    }
    
    private func findApplicationByName(_ name: String) -> Application? {
        let appMap: [String: String] = [
            "instagram": "com.instagram.ios",
            "tiktok": "com.zhiliaoapp.musically",
            "youtube": "com.google.ios.youtube",
        ]
        
        let identifier = appMap[name.lowercased()] ?? name
        return Application(bundleIdentifier: identifier)
    }
}
