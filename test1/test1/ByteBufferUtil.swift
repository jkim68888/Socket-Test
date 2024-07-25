//
//  ByteBufferUtil.swift
//  test1
//
//  Created by 김지현 on 2024/07/25.
//

import Foundation

class ByteBufferUtil {
	func toByteBuffer<T>(from value: T) -> Data {
		var val = value
		return Data(buffer: UnsafeBufferPointer(start: &val, count: 1))
	}
}
