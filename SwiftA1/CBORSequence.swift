import SwiftCBOR

class CBORSequence {
    let bytes: [UInt8]
    
    init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }
    
    lazy var items: [CBOR] = {
        let decoder = CBORDecoder(input: self.bytes)
        var items = [CBOR]()
        while true {
            do {
                if let item = try decoder.decodeItem() {
                    items.append(item)
                } else {
                    break
                }
            } catch {
                break
            }
        }
        return items
    }()
}
