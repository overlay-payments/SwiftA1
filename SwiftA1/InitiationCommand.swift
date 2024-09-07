import Foundation
import SwiftCBOR

struct InitiationCommand {
    static func fromBytes(_ bytes: [UInt8]) -> InitiationCommand {
        let map = try! CBORDecoder(input: bytes).decodeItem()!.toDataMap()!
        return InitiationCommand(map: map)
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
