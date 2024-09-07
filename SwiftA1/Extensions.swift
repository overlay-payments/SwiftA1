import Foundation
import SwiftCBOR

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var index = hex.startIndex

        for _ in 0..<len {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard nextIndex <= hex.endIndex else { return nil }

            if let byte = UInt8(hex[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }

        self = data
    }
    
    var hexString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

extension CBOR {
    // Helper function to convert CBOR.bytes to Data
    func toData() -> Data? {
        if case let CBOR.byteString(byteArray) = self {
            return Data(byteArray)
        }
        return nil
    }
    
    // Helper function to convert an array of CBOR.bytes to [Data]
    func toDataArray() -> [Data]? {
        if case let CBOR.array(array) = self {
            return array.compactMap { $0.toData() }
        }
        return nil
    }
    
    // Helper function to convert a CBOR map to [Data: Data]
    func toDataMap() -> [Data: Data]? {
        if case let CBOR.map(map) = self {
            var dataMap = [Data: Data]()
            for (key, value) in map {
                if let keyData = key.toData(), let valueData = value.toData() {
                    dataMap[keyData] = valueData
                }
            }
            return dataMap
        }
        return nil
    }
}
