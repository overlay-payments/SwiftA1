import Foundation
import SwiftCBOR

struct InitiationResponse {
    static func fromBytes(_ bytes: [UInt8]) -> InitiationResponse {
        let map = try! CBORDecoder(input: bytes).decodeItem()!.toDataMap()!
        return InitiationResponse(map: map)
    }
    
    var map: [Data:Data]
    
    var cids: [Data] {
        return Array(map.keys)
    }
    
    var bytes: [UInt8] {
        CBOR.encode(self.map)
    }
    
    func dataForCID(_ cid: Data) -> Data {
        return map[cid] != nil ? map[cid]! : Data()
    }
}
