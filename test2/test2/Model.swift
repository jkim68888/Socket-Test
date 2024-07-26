//
//  Model.swift
//  test2
//
//  Created by 김지현 on 7/26/24.
//

import Foundation

struct BaseResponse<T> {
    var cmd: Int?
    var cmdSrl: Int?
    var errorCode: Int?
    var responsePacket: T?
}

struct ChattingRooms {
    var chattingRooms: [ChattingRoom]?
}

struct ChattingRoom {
    var idLength: Int?
    var id: String?
    var chattingRoomNameLength: Int?
    var chattingRoomName: String?
    var chattingRoomNameEnLength: Int?
    var chattingRoomNameEn: String?
    var groupIdLength: Int?
    var groupId: String?
    var channelIdLength: Int?
    var channelId: String?
    var imageUrlLength: Int?
    var imageUrl: String?
    var imageUrlEnLength: Int?
    var imageUrlEn: String?
    var defaultImageUrlLength: Int?
    var defaultImageUrl: String?
    var lastChatLength: Int?
    var lastChat: String?
    var lastChatTimeStamp: Int?
    var unreadMessageCount: Int?
}

struct User: Codable, Equatable {
    var id: String?
    var address: String? // 지갑주소
    var chattingRoomNameEn: String?
    var profileImage: String?
    var profileImageEn: String?
    var defaultProfileImage: String?
    var channelName: String?
    var channelNameEn: String?
    var exists: Bool? // 채널이 그룹에 존재하는지 안 하는지
}

struct Message: Codable, Equatable {
    var id: String?
    var roomId: String?
    var message: String?
    var sendTimeStamp: Int?
    var replyId: String? // 답장한 메시지 id 없으면 “”
    var replyMessage: String? // 답장한 메시지 내용 없으면 “”
    var replyChannelName: String? // 답장한 사람의 채널 이름
    var replyChannelNameEn: String?
    var userId: String? // 보낸 유저 id
    var type: String? // 채팅 타입 (USER, SYSTEM)
}

enum CommandType {
    case PING
    case LOGIN_SESSION
    case LOGOUT_SESSION
    case SEND_CHAT
    case CREATE_CHATROOM
    case DELETE_CHAT
    case LEAVE_CHATROOM
    case JOIN_CHATROOM
    case LIST_CHATROOM
    case LIST_CHAT
    case SEARCH_CHAT
    case VIEW_CHAT
    case EXISTS_CHAT
    case CHATROOM_USER_LIST
    case BROADCAST_SEND_CHAT
    case BROADCAST_CREATE_CHATROOM
    case BROADCAST_DELETE_CHAT
    case BROADCAST_LEAVE_CHATROOM
    case BROADCAST_JOIN_CHATROOM
    case BROADCAST_NEW_POST
    case RES_BROADCAST_MAINTENANCE
}
