import XCTest
import SwiftCBOR
@testable import SwiftA1

final class SwiftA1Tests: XCTestCase {
    func testExample() throws {
        let supportedCid = Data([0x69]) // This Claimed ID should be registered on the A1 registry
        let commandingDevice = CommandingDevice(respondingDevice: RespondingDevice(supportedCid: supportedCid))
        
        // build the Initiation Command
        let cid = supportedCid
        let initiationCommandAppData = "Alice".data(using: .utf8)!
        let initiationCommandMap: [Data:Data] = [cid: initiationCommandAppData]
        let initiationCommand = InitiationCommand(map: initiationCommandMap)
        
        // send the Initiation Command
        let initiationResponseBytes = commandingDevice.sendCommand(bytes: initiationCommand.bytes)
        
        // handle the Initiation Response
        let initiationResponse = InitiationResponse.fromBytes(initiationResponseBytes)
        let responderName = String(data: initiationResponse.dataForCID(cid), encoding: .utf8)!
        
        // build the Kickoff Command
        let kickoffAppData = "Yo \(responderName)!".data(using: .utf8)!
        let kickoffCommand = KickoffCommand(cid: cid, applicationData: kickoffAppData)
        
        // send the Kickoff Command
        let kickoffResponseBytes = commandingDevice.sendCommand(bytes: kickoffCommand.bytes)
        
        // handle the Kickoff Response
        let applicationResponse = String(data: Data(kickoffResponseBytes), encoding: .utf8)

        prettyPrint(initiationCommand: initiationCommand, initiationResponse: initiationResponse, kickoffCommand: kickoffCommand, kickoffResponseBytes: kickoffResponseBytes)
        
        assert(applicationResponse == "Hi Alice!")
    }
    
    func testResponderLedIC() throws {
        let cid = Data()
        let icAppData = Data()
        let icMap: [Data:Data] = [cid: icAppData]
        let ic = InitiationCommand(map: icMap)
        
        assert(Data(ic.bytes) == Data([0xA1, 0x40, 0x40]))
    }
    
    private func prettyPrint(initiationCommand: InitiationCommand, initiationResponse: InitiationResponse, kickoffCommand: KickoffCommand, kickoffResponseBytes: [UInt8]) {
        print()
        
        var icCids = ""
        for cid in initiationCommand.cids {
            icCids += "\n  \(cid.hexString) : \(initiationCommand.map[cid]!.hexString)"
        }
        print("""
Initiation Command
--------------------------
raw:  \(Data(initiationCommand.bytes).hexString)
CID map:
{\(icCids)
}

""")
        var irCids = ""
        for cid in initiationResponse.cids {
            irCids += "\n  \(cid.hexString) : \(initiationResponse.map[cid]!.hexString)"
        }
        print("""
Initiation Response
--------------------------
raw: \(Data(initiationResponse.bytes).hexString)
CID map:
{\(irCids)
}


""")
        
        print("""
Kickoff Command
--------------------------
raw:  \(Data(kickoffCommand.bytes).hexString)
CID: \(kickoffCommand.cid.hexString)
Application Data: \(kickoffCommand.applicationData.hexString)


""")
        
        print("""
Kickoff Response
--------------------------
raw:  \(Data(kickoffResponseBytes).hexString)


""")
    }
    
    struct CommandingDevice {
        var respondingDevice: RespondingDevice
        
        func sendCommand(bytes: [UInt8]) -> [UInt8] {
            return respondingDevice.respondTo(bytes)
        }
    }

    class RespondingDevice {
        var supportedCid: Data
        var otherPerson: String?
        
        init(supportedCid: Data) {
            self.supportedCid = supportedCid
        }
        
        func respondTo(_ bytes: [UInt8]) -> [UInt8] {
            if (try? CBOR.decode(bytes)!.toDataMap()) != nil {
                let response = try! handleInitiationRequest(InitiationCommand.fromBytes(bytes))
                return response.bytes
            } else {
                let cborItems = CBORSequence(bytes).items
                if cborItems[0].toData() == supportedCid {
                    return [UInt8]("Hi \(otherPerson!)!".data(using: .utf8)!)
                } else {
                    print("Unsupported message: \(Data(bytes).hexString)")
                    return [UInt8]([])
                }
            }
        }
        
        private func handleInitiationRequest(_ ic: InitiationCommand) throws -> InitiationResponse {
            if ic.cids.contains(self.supportedCid) {
                let attachedData = ic.dataForCID(self.supportedCid)
                self.otherPerson = String(data: attachedData, encoding: .utf8)
                let irDataItem = "Bob".data(using: .utf8)!
                return InitiationResponse(map: [self.supportedCid: irDataItem])
            } else {
                fatalError("No supported CID")
            }
        }
    }
}
