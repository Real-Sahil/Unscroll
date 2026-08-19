package com.unscroll.models

/**
 * Data class representing a blocked application configuration.
 * Used to track which apps to monitor and what patterns indicate short-form content.
 */
data class BlockedApp(
    val packageName: String,
    val name: String,
    val urlPatterns: List<String>,
    val category: String = "social",
    val isEnabled: Boolean = true,
    val blockReels: Boolean = true,
    val blockStories: Boolean = true,
    val blockShorts: Boolean = true,
    val frictionLevel: String = "hard" // easy, medium, hard
)

/**
 * Event tracking for accessibility service activities.
 */
data class AccessibilityEvent(
    val timestamp: Long,
    val eventType: String,
    val packageName: String,
    val contentType: String? = null,
    val duration: Long = 0L
)

/**
 * Configuration for friction layers.
 */
data class FrictionConfig(
    val showCountdown: Boolean = true,
    val countdownSeconds: Int = 30,
    val requireTextConfirmation: Boolean = true,
    val confirmationPhrase: String = "I accept I may lose time",
    val showConsequences: Boolean = true,
    val allowDisable: Boolean = true,
    val cooldownHours: Int = 24
)

/**
 * Block event for analytics.
 */
data class BlockEvent(
    val id: String,
    val timestamp: Long,
    val appName: String,
    val contentType: String,
    val blocked: Boolean,
    val frictionShown: Boolean = false,
    val userDisabledProtection: Boolean = false
)
