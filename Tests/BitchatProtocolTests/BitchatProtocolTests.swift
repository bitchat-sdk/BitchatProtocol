import XCTest
@testable import BitchatProtocol

final class BitchatProtocolTests: XCTestCase {

    // MARK: - Encode / Decode round-trip

    func testBroadcastRoundTrip() throws {
        let pkt = BitchatPacket(
            version: 1,
            type: 2,
            ttl: 7,
            timestamp: 0,
            flags: 0,
            senderID: Data(hexString: "abcdef0123456789")!,
            recipientID: nil,
            payload: "Hello, BitChat!".data(using: .utf8)!,
            signature: nil
        )
        let encoded = BinaryProtocol.encode(pkt)
        let decoded = BinaryProtocol.decode(encoded)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.senderID, pkt.senderID)
        XCTAssertEqual(decoded?.payload, pkt.payload)
    }

    func testDirectedRoundTrip() throws {
        let pkt = BitchatPacket(
            version: 1,
            type: 2,
            ttl: 5,
            timestamp: 0,
            flags: 0x01, // hasRecipient
            senderID: Data(hexString: "abcdef0123456789")!,
            recipientID: Data(hexString: "0102030405060708")!,
            payload: "DM content".data(using: .utf8)!,
            signature: nil
        )
        let encoded = BinaryProtocol.encode(pkt)
        let decoded = BinaryProtocol.decode(encoded)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.recipientID, pkt.recipientID)
    }

    func testPeerIDFromNoiseKey() throws {
        let key = Data(repeating: 0xAB, count: 32)
        let peerID = PeerID.fromNoiseKey(key)
        XCTAssertEqual(peerID.hexString.count, 16)
    }

    // MARK: - Golden vectors (from spec-tests)

    func testGoldenBroadcastPlainText() throws {
        let hex = "010207000000000000000000000fabcdef012345678948656c6c6f2c204269744368617421"
        let data = Data(hexString: hex)!
        let decoded = BinaryProtocol.decode(data)
        XCTAssertNotNil(decoded, "broadcast-v1-plain-text should decode")
        let reEncoded = BinaryProtocol.encode(decoded!)
        XCTAssertEqual(reEncoded.hexString, hex, "round-trip must match golden vector")
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

    var hexString: String { map { String(format: "%02x", $0) }.joined() }
}
