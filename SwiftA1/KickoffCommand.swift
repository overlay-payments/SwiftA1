import Foundation
import SwiftCBOR

struct KickoffCommand {
    static func fromBytes(_ bytes: [UInt8]) -> KickoffCommand {
        let items = CBORSequence(bytes).items
        let cid = items[0].toData()!
        let applicationData = items[1].toData()!
        return KickoffCommand(cid: cid, applicationData: applicationData)
    }
    
    var cid: Data
    var applicationData: Data
    
    var bytes: [UInt8] {
        return cborEncodedCid + cborEncodedApplicationData
    }
    
    var cborEncodedCid: [UInt8] {
        CBOR.encode(cid)
    }
    
    var cborEncodedApplicationData: [UInt8] {
        CBOR.encode(applicationData)
    }
}
