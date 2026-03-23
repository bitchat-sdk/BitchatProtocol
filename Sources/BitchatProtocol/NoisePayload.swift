//
// NoisePayload.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation

/// Helper to create typed Noise payloads
public struct NoisePayload {
    public let type: NoisePayloadType
    public let data: Data
    
    /// Encode payload with type prefix
    public func encode() -> Data {
        var encoded = Data()
        encoded.append(type.rawValue)
        encoded.append(data)
        return encoded
    }
    
    /// Decode payload from data
    public static func decode(_ data: Data) -> NoisePayload? {
        // Ensure we have at least 1 byte for the type
        guard !data.isEmpty else {
            return nil
        }
        
        // Safely get the first byte
        let firstByte = data[data.startIndex]
        guard let type = NoisePayloadType(rawValue: firstByte) else {
            return nil
        }
        
        // Create a proper Data copy (not a subsequence) for thread safety
        let payloadData = data.count > 1 ? Data(data.dropFirst()) : Data()
        return NoisePayload(type: type, data: payloadData)
    }
}
