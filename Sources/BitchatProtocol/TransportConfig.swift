// TransportConfig.swift
// BitchatProtocol
//
// Protocol-layer configuration constants.
// This is free and unencumbered software released into the public domain.

import Foundation

/// Centralized constants for the BitChat protocol layer.
public enum TransportConfig {
    // MARK: - Nostr helpers
    public static let nostrShortKeyDisplayLength: Int = 8
    public static let nostrConvKeyPrefixLength: Int = 16
    public static let nostrGeoRelayCount: Int = 5
    public static let nostrRelayInitialBackoffSeconds: TimeInterval = 1.0
    public static let nostrRelayMaxBackoffSeconds: TimeInterval = 300.0
    public static let nostrRelayBackoffMultiplier: Double = 2.0
    public static let nostrRelayMaxReconnectAttempts: Int = 10
    public static let nostrRelayDefaultFetchLimit: Int = 100
    public static let nostrReadAckInterval: TimeInterval = 0.35
    public static let nostrGeohashInitialLookbackSeconds: TimeInterval = 2_592_000
    public static let nostrGeohashInitialLimit: Int = 2_000
    public static let nostrGeohashSampleLookbackSeconds: TimeInterval = 300
    public static let nostrGeohashSampleLimit: Int = 1_000
    public static let nostrDMSubscribeLookbackSeconds: TimeInterval = 86_400
    public static let nostrInboundEventDedupCap: Int = 4_096
    public static let nostrInboundEventDedupTrimTarget: Int = 3_072
    public static let nostrDuplicateEventLogInterval: Int = 50
    public static let nostrInboundEventLogInterval: Int = 100
    public static let nostrPendingSendQueueCap: Int = 200

    // MARK: - Geo relay directory
    public static let geoRelayFetchIntervalSeconds: TimeInterval = 86_400
    public static let geoRelayRefreshCheckIntervalSeconds: TimeInterval = 3_600
    public static let geoRelayRetryInitialSeconds: TimeInterval = 60
    public static let geoRelayRetryMaxSeconds: TimeInterval = 3_600

    // MARK: - BLE / Protocol
    public static let bleDefaultFragmentSize: Int = 469
    public static let messageTTLDefault: UInt8 = 7
    public static let compressionThresholdBytes: Int = 100

    // MARK: - Message deduplication
    public static let messageDedupMaxAgeSeconds: TimeInterval = 300
    public static let messageDedupMaxCount: Int = 1_000
}
