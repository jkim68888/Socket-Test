//
//  ViewController.swift
//  test1
//
//  Created by 김지현 on 7/25/24.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    private lazy var url: URL? = URL(string: WebSocketURL.prod.rawValue)
    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    private var count: Int32 = 0
    
    // MARK: - 테스트
    private var stageId: String = Config().stageId
    private var productionId: String = Config().productionId
    private var productionSessionRequest: String = Config().productionSessionRequest
    private var productionSessionByte: String = Config().productionSessionByte
    private var myProductionSesssionRequest: String = Config().myProductionSesssionRequest
	
	// 사용 예시
	let intValue: Int32 = 11000
	let floatValue: Float = 3.14
	let doubleValue: Double = 3.141592653589793
	let boolValue: Bool = true
	lazy var stringValue: String = productionId
	
	// Int32를 바이트 버퍼로 변환
	lazy var intByteBuffer = ByteBufferUtil().toByteBuffer(from: intValue) // f82a 0000
	
	// Float를 바이트 버퍼로 변환
	lazy var floatByteBuffer = ByteBufferUtil().toByteBuffer(from: floatValue)
	
	// Double을 바이트 버퍼로 변환
	lazy var doubleByteBuffer = ByteBufferUtil().toByteBuffer(from: doubleValue)
	
	// Bool을 바이트 버퍼로 변환
	lazy var boolByteBuffer = ByteBufferUtil().toByteBuffer(from: boolValue)
	
	lazy var length: Int32 = Int32(stringValue.count)
	lazy var stringLengthByteBuffer = ByteBufferUtil().toByteBuffer(from: length) // 1000 0000
	
	// String을 바이트 버퍼로 변환 (UTF-8 인코딩 사용)
	lazy var stringByteBuffer = stringValue.data(using: .utf8)! // 3937 656f 7345 474c 744a 6951 6d51 5933
	

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
        
        guard let url = url else {
            print("url 없음")
            return
        }
        
		print("Int Byte buffer: \(intByteBuffer as NSData)")
		print("string Length Byte buffer: \(stringLengthByteBuffer as NSData)")
		print("String Byte buffer: \(stringByteBuffer as NSData)")
		
        webSocketTask = session.webSocketTask(with: url, protocols: ["wss"])
        webSocketTask?.resume() // MARK: - 웹소켓 연결
        sessionLogin() // MARK: - 세션 로그인 소켓 요청
    }

    // MARK: - 세션 로그인
    private func sessionLogin() {
		let _: [String: Any] = [
			"cmd": 11000,
			"cmdSrl": 0,
			"requestPacket": [
				"userId": productionId,
				"channelId": productionId
			]
		]
        
		let cmd: String = HexUtil.convertData(ByteBufferUtil().toByteBuffer(from: intValue))
		let cmdSrl: String = HexUtil.convertData(ByteBufferUtil().toByteBuffer(from: count))
		let userIdLength: String = HexUtil.convertData(ByteBufferUtil().toByteBuffer(from: Int32(productionId.count)))
		let userId: String = HexUtil.convertData(productionId.data(using: .utf8)!)
		let channelIdLength: String = HexUtil.convertData(ByteBufferUtil().toByteBuffer(from: Int32(productionId.count)))
		let channelId: String = HexUtil.convertData(productionId.data(using: .utf8)!)
		let hexString: String = cmd + cmdSrl + userIdLength + userId + channelIdLength + channelId
		
		print("hexString - \(hexString)")
		
		webSocketTask?.send(.data(Data(hex: hexString))) { [weak self] error in
			if let error = error {
				print("sessionLogin 실패 \(error)")
			} else {
				print("sessionLogin 보냄")
				self?.addListener()
			}
			self?.count += 1
		}
    }
}

extension ViewController {
    private func addListener(){
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                switch response {
                case .data(let data):
                    self?.didReceiveData(data)
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
    
    private func didReceiveData(_ data: Data) {
        print("==========received data===========")
        print(data)
        
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
