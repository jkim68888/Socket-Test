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
    
    static func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
}
