# BitchatProtocol

Swift SPM package — BitChat binary protocol codec for iOS and macOS.

Implements the v1/v2 wire format, TLV packet encoding, compression, peer ID derivation,
and all supporting models. Zero external dependencies beyond system frameworks and BitLogger.

## Installation

```swift
// Package.swift
.package(url: "https://github.com/bitchat-sdk/BitchatProtocol", from: "0.1.0")
```

## Usage

```swift
import BitchatProtocol

// Encode a broadcast packet
let pkt = BitchatPacket(
    version: 1, type: Int(MessageType.message.rawValue),
    ttl: 7, timestamp: 0, flags: 0,
    senderID: myPeerID.data, recipientID: nil,
    payload: "Hello!".data(using: .utf8)!,
    signature: nil
)
let wire = BinaryProtocol.encode(pkt)

// Decode
if let decoded = BinaryProtocol.decode(wire) {
    print("from:", decoded.senderID.hexString)
}

// TLV — AnnouncementPacket
let announcement = AnnouncementPacket(
    nickname: "Alice",
    noisePublicKey: noiseKey,
    signingPublicKey: signingKey
)
let tlv = announcement.encode()

// Peer ID from Noise public key
let peerID = PeerID.fromNoiseKey(noisePublicKey)
```

## License

Unlicense — public domain.
