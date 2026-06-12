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

    func testRequestSyncRoundTrip() {
        let packet = RequestSyncPacket(p: 19, m: 1 << 19, data: Data([0x01, 0x02, 0x03]))
        let decoded = RequestSyncPacket.decode(from: packet.encode())
        XCTAssertEqual(decoded?.p, 19)
        XCTAssertEqual(decoded?.m, 1 << 19)
        XCTAssertEqual(decoded?.data, Data([0x01, 0x02, 0x03]))
    }

    func testRequestSyncDecodeAcceptsMaxP() {
        let packet = RequestSyncPacket(p: RequestSyncPacket.maxP, m: 1024, data: Data([0x00]))
        XCTAssertNotNil(RequestSyncPacket.decode(from: packet.encode()))
    }

    func testRequestSyncDecodeRejectsPAboveMax() {
        let packet = RequestSyncPacket(p: RequestSyncPacket.maxP + 1, m: 1024, data: Data([0x00]))
        XCTAssertNil(RequestSyncPacket.decode(from: packet.encode()),
                     "decode should reject Golomb-Rice parameter above maxP")
    }

    func testRequestSyncDecodeRejectsZeroP() {
        let packet = RequestSyncPacket(p: 0, m: 1024, data: Data([0x00]))
        XCTAssertNil(RequestSyncPacket.decode(from: packet.encode()))
    }

    // MARK: - Cross-language golden vectors
    // These hexes are pinned across all four SDK ecosystems (Swift, Kotlin,
    // TypeScript, Python) and exported to spec-tests/fixtures/request_sync.json.

    func testRequestSyncGoldenVectorBasic() throws {
        let golden = "01000113020004000800000300050102030405"
        let packet = RequestSyncPacket(p: 19, m: 1 << 19, data: Data([1, 2, 3, 4, 5]))
        XCTAssertEqual(hexString(packet.encode()), golden)

        let goldenData = try XCTUnwrap(Data(hexString: golden))
        let decoded = try XCTUnwrap(RequestSyncPacket.decode(from: goldenData))
        XCTAssertEqual(decoded.p, 19)
        XCTAssertEqual(decoded.m, 1 << 19)
        XCTAssertEqual(decoded.data, Data([1, 2, 3, 4, 5]))
        XCTAssertNil(decoded.types)
        XCTAssertNil(decoded.sinceTimestamp)
        XCTAssertNil(decoded.fragmentIdFilter)
    }

    func testRequestSyncGoldenVectorMaxP() throws {
        let golden = "01000120020004ffffffff03000100"
        let packet = RequestSyncPacket(p: RequestSyncPacket.maxP, m: 0xFFFF_FFFF, data: Data([0x00]))
        XCTAssertEqual(hexString(packet.encode()), golden)
        let goldenData = try XCTUnwrap(Data(hexString: golden))
        XCTAssertNotNil(RequestSyncPacket.decode(from: goldenData))
    }

    func testRequestSyncGoldenVectorExtended() throws {
        let golden = "0100010802000400000100030001ff0400010305000800000000000f4240060003616263"
        let packet = RequestSyncPacket(
            p: 8,
            m: 256,
            data: Data([0xFF]),
            types: SyncTypeFlags(messageTypes: [.announce, .message]),
            sinceTimestamp: 1_000_000,
            fragmentIdFilter: "abc"
        )
        XCTAssertEqual(hexString(packet.encode()), golden)

        let goldenData = try XCTUnwrap(Data(hexString: golden))
        let decoded = try XCTUnwrap(RequestSyncPacket.decode(from: goldenData))
        XCTAssertEqual(decoded.p, 8)
        XCTAssertEqual(decoded.m, 256)
        XCTAssertEqual(decoded.data, Data([0xFF]))
        XCTAssertEqual(decoded.types?.rawValue, 0x03)
        XCTAssertEqual(decoded.sinceTimestamp, 1_000_000)
        XCTAssertEqual(decoded.fragmentIdFilter, "abc")
    }

    func testRequestSyncGoldenVectorUnknownTLVSkipped() throws {
        let golden = "7f0002beef01000113020004000800000300050102030405"
        let goldenData = try XCTUnwrap(Data(hexString: golden))
        let decoded = try XCTUnwrap(RequestSyncPacket.decode(from: goldenData))
        XCTAssertEqual(decoded.p, 19)
        XCTAssertEqual(decoded.m, 1 << 19)
    }

    func testRequestSyncGoldenVectorRejects() throws {
        for hex in [
            "010001000200040000040003000100",  // p = 0
            "010001210200040000040003000100",  // p = 33 > maxP
            "010001010200040000000003000100",  // m = 0
            "0100011302000400080000",          // missing data TLV
            "010001",                          // truncated TLV
        ] {
            let data = try XCTUnwrap(Data(hexString: hex))
            XCTAssertNil(RequestSyncPacket.decode(from: data), "expected reject for \(hex)")
        }
        XCTAssertNil(RequestSyncPacket.decode(from: Data()))
    }

    private func hexString(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
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
