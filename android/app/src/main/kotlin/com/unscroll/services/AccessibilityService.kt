package com.unscroll.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.unscroll.utils.PolicyEngine
import com.unscroll.utils.SharedPreferencesHelper
import com.unscroll.models.BlockedApp

/**
 * AccessibilityService for detecting and blocking short-form video apps on Android.
 * Implements accessibility-based app monitoring for Reels, Shorts, TikTok.
 *
 * Based on industry patterns from:
 * - nudge (Android app blocking)
 * - Reality (accessibility monitoring)
 * - PureShield (app detection)
 */
class UnscrollAccessibilityService : AccessibilityService() {

    private lateinit var policyEngine: PolicyEngine
    private lateinit var preferencesHelper: SharedPreferencesHelper
    private val blockedApps = listOf(
        BlockedApp(packageName = "com.instagram.android", name = "Instagram", urlPatterns = listOf("reels", "stories")),
        BlockedApp(packageName = "com.google.android.youtube", name = "YouTube", urlPatterns = listOf("shorts")),
        BlockedApp(packageName = "com.zhiliaoapp.musically", name = "TikTok", urlPatterns = listOf()),
        BlockedApp(packageName = "com.jingdong.app.mall", name = "JD", urlPatterns = listOf()),
        BlockedApp(packageName = "com.kuaishou.android", name = "Kuaishou", urlPatterns = listOf()),
    )

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> handleScreenOff()
                Intent.ACTION_SCREEN_ON -> handleScreenOn()
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        policyEngine = PolicyEngine(this)
        preferencesHelper = SharedPreferencesHelper(this)

        // Configure accessibility service
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPES_ALL_MASK
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_TREE
            packageNames = blockedApps.map { it.packageName }.toTypedArray()
        }
        serviceInfo = info

        // Register screen on/off receiver
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        ContextCompat.registerBroadcastReceiver(
            this,
            screenReceiver,
            filter,
            ContextCompat.RECEIVER_EXPORTED
        )

        logEvent("AccessibilityService connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> handleWindowStateChanged(event)
            AccessibilityEvent.TYPE_VIEW_FOCUSED -> handleViewFocused(event)
            AccessibilityEvent.TYPE_VIEW_CLICKED -> handleViewClicked(event)
        }
    }

    private fun handleWindowStateChanged(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        val className = event.className?.toString() ?: return

        logEvent("Window changed: $packageName / $className")

        if (!isProtectionEnabled()) return

        val blockedApp = blockedApps.find { it.packageName == packageName }
        if (blockedApp != null) {
            checkAndBlockApp(packageName, className, blockedApp)
        }
    }

    private fun handleViewFocused(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return

        if (!isProtectionEnabled()) return

        val blockedApp = blockedApps.find { it.packageName == packageName }
        if (blockedApp != null) {
            detectAndBlockShortFormContent(event, blockedApp)
        }
    }

    private fun handleViewClicked(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return

        if (!isProtectionEnabled()) return

        // Track user interaction for analytics
        val timestamp = System.currentTimeMillis()
        preferencesHelper.recordUserInteraction(packageName, timestamp)
    }

    private fun checkAndBlockApp(packageName: String, className: String, blockedApp: BlockedApp) {
        // Check if protection is enabled for this app
        if (!policyEngine.isPolicyActiveForApp(blockedApp.name)) {
            return
        }

        // Detect specific content (Reels, Shorts, Stories)
        val contentType = detectContentType(className, blockedApp.urlPatterns)

        if (contentType != null) {
            logEvent("Blocked content detected: $contentType in ${blockedApp.name}")

            // Show friction UI or redirect
            if (policyEngine.shouldShowFriction()) {
                showFrictionScreen(blockedApp.name, contentType)
            } else {
                forceCloseApp(packageName)
            }

            // Record event
            recordBlockedAttempt(blockedApp.name, contentType)
        }
    }

    private fun detectAndBlockShortFormContent(event: AccessibilityEvent, blockedApp: BlockedApp) {
        val viewHierarchy = event.source ?: return

        // Search for specific UI patterns indicating short-form content
        val shortFormIndicators = listOf(
            "reels", "shorts", "stories", "video", "feed",
            "swipe", "carousel", "story"
        )

        val text = getText(viewHierarchy)?.lowercase() ?: ""

        val isShortForm = shortFormIndicators.any { indicator ->
            text.contains(indicator)
        }

        if (isShortForm) {
            logEvent("Short-form content detected in ${blockedApp.name}")

            if (policyEngine.shouldShowFriction()) {
                showFrictionScreen(blockedApp.name, "Short-form Video")
            } else {
                forceCloseApp(blockedApp.packageName)
            }

            recordBlockedAttempt(blockedApp.name, "Short-form")
        }

        viewHierarchy.recycle()
    }

    private fun detectContentType(className: String, urlPatterns: List<String>): String? {
        for (pattern in urlPatterns) {
            if (className.lowercase().contains(pattern)) {
                return pattern.replaceFirstChar { it.uppercase() }
            }
        }

        // Fallback detection based on common class names
        return when {
            className.contains("Reels") || className.contains("Reel") -> "Reels"
            className.contains("Shorts") || className.contains("Short") -> "Shorts"
            className.contains("Stories") || className.contains("Story") -> "Stories"
            className.contains("Feed") || className.contains("Timeline") -> "Feed"
            else -> null
        }
    }

    private fun getText(node: android.view.accessibility.AccessibilityNodeInfo): String? {
        if (!node.text.isNullOrEmpty()) {
            return node.text.toString()
        }

        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            val childText = getText(child)
            if (!childText.isNullOrEmpty()) {
                child.recycle()
                return childText
            }
            child.recycle()
        }

        return null
    }

    private fun showFrictionScreen(appName: String, contentType: String) {
        val intent = Intent(this, FrictionActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("appName", appName)
            putExtra("contentType", contentType)
            putExtra("timestamp", System.currentTimeMillis())
        }
        startActivity(intent)

        // Toast notification
        Toast.makeText(
            this,
            "Focus Mode active: $appName $contentType blocked",
            Toast.LENGTH_SHORT
        ).show()
    }

    private fun forceCloseApp(packageName: String) {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)

        logEvent("Forced close: $packageName")
    }

    private fun recordBlockedAttempt(appName: String, contentType: String) {
        val timestamp = System.currentTimeMillis()
        preferencesHelper.recordBlockedAttempt(appName, contentType, timestamp)

        // Update analytics
        policyEngine.recordBlockedAttempt(appName, contentType, timestamp)
    }

    private fun isProtectionEnabled(): Boolean {
        return preferencesHelper.isProtectionEnabled()
    }

    private fun handleScreenOff() {
        logEvent("Screen turned off")
        policyEngine.recordScreenEvent("off", System.currentTimeMillis())
    }

    private fun handleScreenOn() {
        logEvent("Screen turned on")
        policyEngine.recordScreenEvent("on", System.currentTimeMillis())
    }

    override fun onInterrupt() {
        logEvent("AccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(screenReceiver)
        logEvent("AccessibilityService destroyed")
    }

    private fun logEvent(message: String) {
        android.util.Log.d("UnscrollAccessibility", message)
        preferencesHelper.logAccessibilityEvent(message)
    }
}

/**
 * Friction Activity shown when user tries to access blocked content.
 * Implements friction layers to delay and discourage relapse.
 */
class FrictionActivity : android.app.Activity() {

    private lateinit var preferencesHelper: SharedPreferencesHelper
    private var countdownSeconds = 30
    private var confirmationText = ""

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        preferencesHelper = SharedPreferencesHelper(this)

        val appName = intent.getStringExtra("appName") ?: "Unknown App"
        val contentType = intent.getStringExtra("contentType") ?: "Content"

        setContentView(android.R.layout.activity_main)

        showFrictionDialog(appName, contentType)
    }

    private fun showFrictionDialog(appName: String, contentType: String) {
        val dialog = android.app.AlertDialog.Builder(this)
            .setTitle("Focus Mode Active")
            .setMessage("You tried to access $appName $contentType.\n\nThis content is blocked to help you stay focused.")
            .setPositiveButton("Go Back") { _, _ ->
                finish()
            }
            .setNegativeButton("View Consequences") { _, _ ->
                showConsequences()
            }
            .setCancelable(false)
            .create()

        dialog.show()
    }

    private fun showConsequences() {
        val dialog = android.app.AlertDialog.Builder(this)
            .setTitle("Consequences of Breaking Focus")
            .setMessage(
                "If you disable protection now:\n" +
                "• 24-hour cooldown before re-enabling\n" +
                "• Loss of 1-day streak\n" +
                "• Notification to accountability partner\n" +
                "• Reduced productivity for today\n\n" +
                "Stay strong!"
            )
            .setPositiveButton("I'll Stay Focused") { _, _ ->
                finish()
            }
            .setCancelable(false)
            .create()

        dialog.show()
    }
}
