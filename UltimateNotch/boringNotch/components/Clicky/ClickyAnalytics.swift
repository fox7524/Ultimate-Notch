//
//  ClickyAnalytics.swift
//  leanring-buddy
//
//  Centralized PostHog analytics wrapper. All event names and properties
//  are defined here so instrumentation is consistent and easy to audit.
//

import Foundation

enum ClickyAnalytics {

    // MARK: - Setup

    static func configure() {
    }

    // MARK: - App Lifecycle

    static func trackAppOpened() {
    }

    // MARK: - Onboarding

    static func trackOnboardingStarted() {
    }

    static func trackOnboardingReplayed() {
    }

    static func trackOnboardingVideoCompleted() {
    }

    static func trackOnboardingDemoTriggered() {
    }

    // MARK: - Permissions

    static func trackAllPermissionsGranted() {
    }

    static func trackPermissionGranted(permission: String) {
    }

    // MARK: - Voice Interaction

    static func trackPushToTalkStarted() {
    }

    static func trackPushToTalkReleased() {
    }

    static func trackUserMessageSent(transcript: String) {
    }

    static func trackAIResponseReceived(response: String) {
    }

    static func trackElementPointed(elementLabel: String?) {
    }

    // MARK: - Errors

    static func trackResponseError(error: String) {
    }

    static func trackTTSError(error: String) {
    }
}
