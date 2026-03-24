import XCTest
@testable import BitchatProtocol

final class BitchatProtocolTests: XCTestCase {

    // MARK: - Encode / Decode round-trip

    func testBroadcastRoundTrip() throws {
        let pkt = BitchatPacket(
            type: 2,
            senderID: Data(hexString: "abcdef0123456789")!,
            recipientID: nil,
            timestamp: 0,
            payload: "Hello, BitChat!".data(using: .utf8)!,
            signature: nil,
            ttl: 7,
            version: 1
        )
        let encoded = BinaryProtocol.encode(pkt, padding: false)
        XCTAssertNotNil(encoded, "encode should succeed")
        let decoded = BinaryProtocol.decode(encoded!)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.senderID, pkt.senderID)
        XCTAssertEqual(decoded?.payload, pkt.payload)
    }

    func testDirectedRoundTrip() throws {
        let pkt = BitchatPacket(
            type: 2,
            senderID: Data(hexString: "abcdef0123456789")!,
            recipientID: Data(hexString: "0102030405060708")!,
            timestamp: 0,
            payload: "DM content".data(using: .utf8)!,
            signature: nil,
            ttl: 5,
            version: 1
        )
        let encoded = BinaryProtocol.encode(pkt, padding: false)
        XCTAssertNotNil(encoded)
        let decoded = BinaryProtocol.decode(encoded!)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.recipientID, pkt.recipientID)
    }

    func testPeerIDFromPublicKey() throws {
        let key = Data(repeating: 0xAB, count: 32)
        let peerID = PeerID(publicKey: key)
        XCTAssertFalse(peerID.id.isEmpty, "peer ID should not be empty")
        XCTAssertEqual(peerID.id.count, 16, "peer ID should be 16 hex chars (8 bytes)")
    }

    func testDecodeReturnsNilOnGarbage() {
        let garbage = Data([0xFF, 0xFF, 0xFF])
        let decoded = BinaryProtocol.decode(garbage)
        XCTAssertNil(decoded, "decode should return nil on invalid input")
    }

    func testDecodeReturnsNilOnEmpty() {
        let decoded = BinaryProtocol.decode(Data())
        XCTAssertNil(decoded, "decode should return nil on empty input")
    }
}

private extension Data {
    init?(hexString: String) {
        guard hexString.count % 2 == 0 else { return nil }
        var bytes = [UInt8]()
        var idx = hexString.startIndex
        while idx < hexString.endIndex {
            let next = hexString.index(idx, offsetBy: 2)
            guard let byte = UInt8(hexString[idx..<next], radix: 16) else { return nil }
            bytes.append(byte)
            idx = next
        }
        self.init(bytes)
    }
}
