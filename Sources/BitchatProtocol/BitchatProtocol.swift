// BitchatProtocol.swift
// BitchatProtocol
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>

import Foundation

// MARK: - Message Types

/// Wire-level message type identifiers (1 byte in packet header).
public enum MessageType: UInt8, CaseIterable, Sendable {
    case announce      = 0x01   // Peer presence announcement with nickname
    case message       = 0x02   // Public chat message
    case leave         = 0x03   // Peer departing the mesh
    case noiseHandshake = 0x10  // Noise Protocol handshake frame
    case noiseEncrypted = 0x11  // Noise-encrypted payload
    case fragment      = 0x20   // Fragment of a larger message
    case requestSync   = 0x21   // GCS filter-based sync request
    case fileTransfer  = 0x22   // Binary file / audio / image payload

    public var description: String {
        switch self {
        case .announce:       return "announce"
        case .message:        return "message"
        case .leave:          return "leave"
        case .noiseHandshake: return "noiseHandshake"
        case .noiseEncrypted: return "noiseEncrypted"
        case .fragment:       return "fragment"
        case .requestSync:    return "requestSync"
        case .fileTransfer:   return "fileTransfer"
        }
    }
}

// MARK: - Noise Payload Types

/// Type tag embedded as the first byte of a decrypted Noise payload.
/// Keeps private communication metadata opaque to observers.
public enum NoisePayloadType: UInt8, CaseIterable, Sendable {
    case privateMessage  = 0x01  // Private chat message
    case readReceipt     = 0x02  // Message was read
    case delivered       = 0x03  // Message was delivered
    case fileTransfer    = 0x20  // Encrypted file transfer
    case verifyChallenge = 0x10  // OOB verification challenge
    case verifyResponse  = 0x11  // OOB verification response

    public var description: String {
        switch self {
        case .privateMessage:  return "privateMessage"
        case .readReceipt:     return "readReceipt"
        case .delivered:       return "delivered"
        case .fileTransfer:    return "fileTransfer"
        case .verifyChallenge: return "verifyChallenge"
        case .verifyResponse:  return "verifyResponse"
        }
    }
}

// MARK: - Packet Flags

/// Bit flags in the packet header's flags byte.
public enum PacketFlag: UInt8, Sendable {
    case hasRecipient = 0x01  // recipientID field is present
    case hasSignature = 0x02  // signature field is present
    case isCompressed = 0x04  // payload is zlib-compressed
    case hasRoute     = 0x08  // route field is present (v2+)
    case isRSR        = 0x10  // relay store-and-relay flag
}

// MARK: - Delivery Status

/// Observable delivery state for outbound messages.
public enum DeliveryStatus: Codable, Equatable, Hashable, Sendable {
    case sending
    case sent
    case delivered(to: String, at: Date)
    case read(by: String, at: Date)
    case failed(reason: String)
    case partiallyDelivered(reached: Int, total: Int)

    public var displayText: String {
        switch self {
        case .sending:                               return "Sending…"
        case .sent:                                  return "Sent"
        case .delivered(let name, _):                return "Delivered to \(name)"
        case .read(let name, _):                     return "Read by \(name)"
        case .failed(let reason):                    return "Failed: \(reason)"
        case .partiallyDelivered(let r, let t):      return "Delivered to \(r)/\(t)"
        }
    }
}
