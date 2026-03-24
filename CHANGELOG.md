# Changelog — BitchatProtocol (Swift)

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] — 2026-03-22

Initial GA release.

### Added
- `BitchatPacket` — value type representing a protocol packet with full `public` API
- `encode(_:padding:)` — binary encode with optional PKCS7-style block padding; returns `Data?`
- `decode(_:)` — binary decode; returns `BitchatPacket?` — never throws on any input
- Protocol v1 (14-byte header) and v2 (16-byte header) support
- Compression: zlib deflate with 50,000:1 ratio safety cap; `IS_COMPRESSED` flag handling
- `MessageType` enum with all wire-defined message types
- `PacketFlag` option set: `hasRecipient`, `hasSignature`, `isCompressed`, `hasRoute`, `isRSR`
- TLV codec: `AnnouncementPacket` and `PrivateMessagePacket` with `encode()` / `decode(_:)` → `Data?` / type?
- `peerIDFromNoiseKey(_:)` — derive 8-byte peer ID from 32-byte Noise static public key
- `peerIDToHex(_:)` / `peerIDFromHex(_:)` — hex conversion helpers
- Cross-language compatibility: wire format matches `@bitchat-sdk/protocol-core` (JS) and `bitchat_protocol` (Python)

### Protocol Compatibility
Wire-format compatible with BitChat iOS (Swift), BitChat Android (Kotlin), `@bitchat-sdk/protocol-core`, and `bitchat_protocol`.

[0.1.0]: https://github.com/bitchat-sdk/BitchatProtocol/releases/tag/0.1.0

[Unreleased]: https://github.com/bitchat-sdk/BitchatProtocol/compare/0.1.0...HEAD