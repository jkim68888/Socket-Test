//
//  HexUtil.swift
//  test1
//
//  Created by 김지현 on 7/25/24.
//

import Foundation

class HexUtil {
    static func convertInt(_ number: Int) -> String {
        return NSString(format:"%02x", number) as String
    }
    
    static func convertString(_ string: String) -> String {
        let length = self.convertInt(string.count)
        let data = string.data(using: .utf8)
        let hexString: String = data?.map{ String(format:"%02x", $0) }.joined() ?? ""
        
        return length + hexString
    }
	
	static func convertData(_ data: Data) -> String {
		return data.map { String(format: "%02x", $0) }.joined()
	}
    
    static func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
}

extension Data {
	init(hex:String) {
		let scalars = hex.unicodeScalars
		var bytes = Array<UInt8>(repeating: 0, count: (scalars.count + 1) >> 1)
		for (index, scalar) in scalars.enumerated() {
			var nibble = scalar.hexNibble
			if index & 1 == 0 {
				nibble <<= 4
			}
			bytes[index >> 1] |= nibble
		}
		self = Data(bytes: bytes)
	}
}

extension UnicodeScalar {
	var hexNibble:UInt8 {
		let value = self.value
		if 48 <= value && value <= 57 {
			return UInt8(value - 48)
		}
		else if 65 <= value && value <= 70 {
			return UInt8(value - 55)
		}
		else if 97 <= value && value <= 102 {
			return UInt8(value - 87)
		}
		fatalError("\(self) not a legal hex nibble")
	}
}
