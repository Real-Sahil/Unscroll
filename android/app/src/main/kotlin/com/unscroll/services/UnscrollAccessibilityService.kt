package com.unscroll.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.preference.PreferenceManager
import com.unscroll.ui.FrictionDialogActivity

class UnscrollAccessibilityService : AccessibilityService() {
    
    private lateinit var sharedPreferences: SharedPreferences
    private val handler = Handler(Looper.getMainLooper())
    
    // Protected apps (Reels, Shorts, TikTok)
    private val protectedApps = listOf(
        "com.instagram.android" to listOf("reels", "feed"),
        "com.google.android.youtube" to listOf("shorts"),
        "com.zhiliaoapp.musically" to listOf("video"),
    )
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        val packageName = event.packageName?.toString() ?: return
        
        // Check if current app is protected
        val isProtectedApp = protectedApps.any { (app, _) ->
            packageName.contains(app)
        }
        
        if (!isProtectedApp) return
        
        // Check if protection is active
        sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val isProtectionActive = sharedPreferences.getBoolean("protection_active", false)
        
        if (!isProtectionActive) return
        
        // Check time-based protection
        val isInProtectedHours = checkProtectedHours()
        if (!isInProtectedHours) return
        
        // Detect Reels/Shorts/TikTok content
        val isViewingContent = detectShortFormContent(event)
        if (!isViewingContent) return
        
        // Log attempt
        logBlockedAttempt(packageName)
        
        // Show friction dialog
        showFrictionDialog(packageName)
    }
    
    override fun onInterrupt() {
        // Handle service interruption
    }
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPES_ALL_MASK
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_ALL_MASKS
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        serviceInfo = info
        
        sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
    }
    
    // MARK: - Helper Functions
    
    private fun checkProtectedHours(): Boolean {
        val calendar = java.util.Calendar.getInstance()
        val currentHour = calendar.get(java.util.Calendar.HOUR_OF_DAY)
        val currentMinute = calendar.get(java.util.Calendar.MINUTE)
        val currentDay = calendar.get(java.util.Calendar.DAY_OF_WEEK)
        
        val startHour = sharedPreferences.getInt("protection_start_hour", 22)
        val startMinute = sharedPreferences.getInt("protection_start_minute", 0)
        val endHour = sharedPreferences.getInt("protection_end_hour", 7)
        val endMinute = sharedPreferences.getInt("protection_end_minute", 0)
        
        val daysJson = sharedPreferences.getString("protection_days", "")
        val protectedDays = parseDaysOfWeek(daysJson)
        
        if (!protectedDays.contains(currentDay)) return false
        
        val currentTime = currentHour * 60 + currentMinute
        val startTime = startHour * 60 + startMinute
        val endTime = endHour * 60 + endMinute
        
        return if (startTime < endTime) {
            currentTime in startTime..endTime
        } else {
            currentTime >= startTime || currentTime <= endTime
        }
    }
    
    private fun parseDaysOfWeek(json: String?): List<Int> {
        if (json.isNullOrEmpty()) return (1..7).toList()
        return try {
            json.removeSurrounding("[", "]")
                .split(",")
                .map { it.trim().toInt() }
        } catch (e: Exception) {
            (1..7).toList()
        }
    }
    
    private fun detectShortFormContent(event: AccessibilityEvent): Boolean {
        val windowTitle = event.contentDescription?.toString()?.lowercase() ?: return false
        val windowClass = event.className?.toString()?.lowercase() ?: return false
        
        val indicators = listOf(
            "reels", "shorts", "short", "feed", "video", "story",
            "explore", "discovery"
        )
        
        return indicators.any { indicator ->
            windowTitle.contains(indicator) || windowClass.contains(indicator)
        }
    }
    
    private fun logBlockedAttempt(packageName: String) {
        val appName = when {
            packageName.contains("instagram") -> "instagram"
            packageName.contains("youtube") -> "youtube"
            packageName.contains("musically") -> "tiktok"
            else -> packageName
        }
        
        val timestamp = System.currentTimeMillis()
        val key = "blocked_attempt_$timestamp"
        
        sharedPreferences.edit().apply {
            putString(key, appName)
            putLong("${key}_time", timestamp)
            apply()
        }
    }
    
    private fun showFrictionDialog(packageName: String) {
        val intent = Intent(this, FrictionDialogActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
        intent.putExtra("blocked_app", packageName)
        
        handler.post {
            startActivity(intent)
            Toast.makeText(
                this,
                "Protection active - app blocked",
                Toast.LENGTH_SHORT
            ).show()
        }
    }
}
