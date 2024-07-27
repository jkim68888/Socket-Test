//
//  ViewController.swift
//  test2
//
//  Created by 김지현 on 7/26/24.
//

import UIKit
import NIO

class ViewController: UIViewController {
    
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    private lazy var url: URL? = URL(string: WebSocketURL.prod.rawValue)
    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    private var count: Int32 = 0
    private let config: Config = Config()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        
        guard let url = url else {
            print("url 없음")
            return
        }
        
        webSocketTask = session.webSocketTask(with: url, protocols: ["wss"])
        webSocketTask?.resume() // MARK: - 웹소켓 연결
        sessionLogin() // MARK: - 세션 로그인 소켓 요청
    }

    // MARK: - 세션 로그인
    private func sessionLogin() {
        let _: [String: Any] = [
            "cmd": 11000,
            "cmdSrl": count,
            "requestPacket": [
				"userId": config.myProductionId,
                "channelId": config.myProductionId
            ]
        ]
		
		let data: Data = writeByteBuffer(request: SessionLoginRequest(userId: config.myProductionId,
																	  channelId: config.myProductionId))
		
        webSocketTask?.send(.data(data)) { [weak self] error in
            if let error = error {
                print("sessionLogin 실패 \(error)")
            } else {
                print("sessionLogin 보냄")
                self?.addListener(.LOGIN_SESSION)
            }
            self?.count += 1
        }
    }
	
	// MARK: - Request
	private func writeByteBuffer(request: Any?) -> Data {
		var byteBuffer = ByteBuffer()
		
		byteBuffer.writeInteger(Int32(11000), endianness: .little)
		byteBuffer.writeInteger(count, endianness: .little)
		let str = writeObject(byteBuffer, request: request)
		
		return Data(hex: str)
	}
	
	private func writeObject(_ byteBuffer: ByteBuffer, request: Any?) -> String {
		var byteBuffer = byteBuffer
		
		if let param = request as? SessionLoginRequest {
			byteBuffer.writeInteger(Int32(param.userId.count), endianness: .little)
			byteBuffer.writeString(param.userId)
			byteBuffer.writeInteger(Int32(param.channelId.count), endianness: .little)
			byteBuffer.writeString(param.channelId)
		} else {
			byteBuffer.writeInteger(1)
		}
		
		let str = byteBuffer.hexDump(format: .plain).replacingOccurrences(of: " ", with: "")
		print(str)
		
		return str
	}
}

// MARK: - Response
extension ViewController {
    private func addListener(_ commandType: CommandType){
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                switch response {
                case .data(let data):
                    let decodedData = self?.didReceiveData(ByteBuffer(data: data), commandType: commandType)
					
					print("======response======")
					dump(decodedData)
                case .string(let message):
                    self?.didReceiveMessage(message)
                @unknown default:
                    fatalError()
                }
            case .failure(let error):
                self?.didReceiveError(error)
            }
        }
    }
    
	private func didReceiveData(_ byteBuffer: ByteBuffer, commandType: CommandType) -> BaseResponse<Any>? {
        print("==========received data===========")
        
        switch commandType {
        case .PING:
            print(byteBuffer)
        case .LOGIN_SESSION:
		
			var byteBuffer = byteBuffer
			let cmd = byteBuffer.readInteger(endianness: .little, as: Int32.self) // MARK: - byteBuffer to UINT32 - Mid-Little Endian (CDAB)
			
			let cmdSrl = byteBuffer.readInteger(endianness: .little, as: Int32.self)
			let errorCode = byteBuffer.readInteger(endianness: .little, as: Int32.self)
			let objectArrayLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
			
			var responsePacket: [ChattingRoom] = []
			
			if let objectArrayLength = objectArrayLength {
				for _ in 0..<objectArrayLength {
					if let object = readObject(byteBuffer: byteBuffer) {
						responsePacket.append(object)
					}
				}
			}
			
			let response: BaseResponse<Any> = BaseResponse(cmd: Int(cmd!), cmdSrl: Int(cmdSrl!), errorCode: Int(errorCode!), responsePacket: ChattingRooms(chattingRooms: responsePacket))
            
			return response
        default:
            break
        }
		
		return nil
    }
	
	private func readObject(byteBuffer: ByteBuffer) -> ChattingRoom? {
		var byteBuffer = byteBuffer
		let isNull = byteBuffer.readBytes(length: 1)?.first == 1
		
		if !isNull {
			return readChattingRoomModel(byteBuffer: byteBuffer)
		} else {
			return nil
		}
	}
	
	private func readChattingRoomModel(byteBuffer: ByteBuffer) -> ChattingRoom {
		var byteBuffer = byteBuffer
		
		let idLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let id = byteBuffer.readString(length: Int(idLength!), encoding: .ascii) // MARK: - byteBuffer to Ascii
		
		let chattingRoomNameLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let chattingRoomName = byteBuffer.readString(length: Int(chattingRoomNameLength!), encoding: .utf8) // MARK: - byteBuffer to utf8
		
		let chattingRoomNameEnLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let chattingRoomNameEn = byteBuffer.readString(length: Int(chattingRoomNameEnLength!), encoding: .utf8)
		
		let groupIdLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let groupId = byteBuffer.readString(length: Int(groupIdLength!), encoding: .ascii)
		
		let channelIdLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let channelId = byteBuffer.readString(length: Int(channelIdLength!), encoding: .ascii)
		
		let imageUrlLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let imageUrl = byteBuffer.readString(length: Int(imageUrlLength!), encoding: .ascii)
		
		let imageUrlEnLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let imageUrlEn = byteBuffer.readString(length: Int(imageUrlEnLength!), encoding: .ascii)
		
		let defaultImageUrlLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let defaultImageUrl = byteBuffer.readString(length: Int(defaultImageUrlLength!), encoding: .ascii)
		
		let lastChatLength = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		let lastChat = byteBuffer.readString(length: Int(lastChatLength!), encoding: .utf8)
		
		let lastChatTimeStamp = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		
		let unreadMessageCount = byteBuffer.readInteger(endianness: .little, as: Int32.self)
		
		return ChattingRoom(id: id, chattingRoomName: chattingRoomName, chattingRoomNameEn: chattingRoomNameEn, groupId: groupId, channelId: channelId, imageUrl: imageUrl, imageUrlEn: imageUrlEn, defaultImageUrl: defaultImageUrl, lastChat: lastChat, lastChatTimeStamp: Int(lastChatTimeStamp!), unreadMessageCount: Int(unreadMessageCount!))
	}
	
	
    private func didReceiveMessage(_ message: String) {
        print("==========received message===========")
        print(message)
    }
    
    private func didReceiveError(_ error: Error) {
        print("==========received error===========")
        print(error)
        
    }
}

extension ViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connection opened: \(`protocol` ?? "nil")")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed: \(closeCode.rawValue), reason: \(reason ?? Data())")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket task complete with error: \(error)")
        }
    }
}
