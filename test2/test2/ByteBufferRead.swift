//
//  ByteBufferRead.swift
//  test2
//
//  Created by 김지현 on 7/26/24.
//

import Foundation
import NIOCore
import NIOFoundationCompat

class ByteBufferRead {
    // MARK: - BaseResponse 읽기
    func readBaseResponse(_ data: ByteBuffer, commandType: CommandType) -> BaseResponse<Any?> {
        var cmd: Int = readInt(data)
        var cmdSrl: Int = readInt(data)
        var errorCode: Int = readInt(data)
        var responsePacket: Any? = switch commandType {
        case .PING:
            readInt(data)
        case .LOGIN_SESSION:
            readObject(data)
        default:
            nil
        }
        
        return BaseResponse(cmd: cmd, cmdSrl: cmdSrl, errorCode: errorCode, responsePacket: responsePacket)
    }

    // MARK: - ChattingRoom 읽기
//    fun ByteBuffer.readChattingRoomModel(): ResponsePacket {
//        val id = this.readString()
//        val chattingRoomName = this.readString()
//        val chattingRoomNameEn = this.readString()
//        val chattingRoomNameJa = "" // 작업 반영 전
//        val groupId = this.readString()
//        val channelId = this.readString()
//        val imageUrl = this.readString()
//        val imageUrlEn = this.readString()
//        val imageUrlJa = "" // 작업 반영 전
//        val defaultImageUrl = this.readString()
//        val lastChat = this.readString()
//        val lastChatTimeStamp = this.readLong()
//        val unreadMessageCount = this.readInteger()
//        return ResponsePacket.ChattingRoomModel(id, chattingRoomName, chattingRoomNameEn, chattingRoomNameJa, groupId, channelId, imageUrl, imageUrlEn, imageUrlJa, defaultImageUrl, lastChat, lastChatTimeStamp, unreadMessageCount )
//    }
}

extension ByteBufferRead {
    // MARK: - Int 읽기
    func readInt(_ data: ByteBuffer) -> Int {
        return data.readableBytes
    }
    
    // MARK: - String 읽기
    func readString(_ data: ByteBuffer) -> String {
        let length: Int = readInt(data)
        var data = data
        if length > 0 {
            return data.readString(length: length) ?? ""
        } else {
            return ""
        }
    }

    // MARK: - Bool 읽기
    func readBool(_ data: ByteBuffer) -> Bool? {
        return data.readableBytes == 1
    }

    // MARK: - Object 읽기
    func readObject(_ data: ByteBuffer) -> AnyObject? {
       return nil
    }
    
    // MARK: - String Array 읽기
    func readStringArray(_ data: ByteBuffer) -> String {
        return ""
    }
    
    // MARK: - Object Array 읽기
    func readObjectArray() {
        
    }
}
