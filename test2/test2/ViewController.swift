//
//  ViewController.swift
//  test2
//
//  Created by 김지현 on 7/26/24.
//

import UIKit
import NIOCore
import NIOFoundationCompat

class ViewController: UIViewController {
    
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    private lazy var url: URL? = URL(string: WebSocketURL.stage.rawValue)
    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    private var count: Int32 = 0
    private let config: Config = Config()
    var decoder: JSONDecoder = JSONDecoder()
    var encoder: JSONEncoder = JSONEncoder()

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
            "cmdSrl": 0,
            "requestPacket": [
                "userId": "97eosEGLtJiQmQY3",
                "channelId": "97eosEGLtJiQmQY3"
            ]
        ]
        
        webSocketTask?.send(.data(Data(hex: config.sessionLoginHex))) { [weak self] error in
            if let error = error {
                print("sessionLogin 실패 \(error)")
            } else {
                print("sessionLogin 보냄")
                self?.addListener(.LOGIN_SESSION)
            }
            self?.count += 1
        }
    }
}

extension ViewController {
    private func addListener(_ commandType: CommandType){
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let response):
                switch response {
                case .data(let data):
                    self?.didReceiveData(ByteBuffer(data: data), commandType: commandType)
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
    
    private func didReceiveData(_ byteBuffer: ByteBuffer, commandType: CommandType) {
        print("==========received data===========")
        
        switch commandType {
        case .PING:
            print(byteBuffer)
        case .LOGIN_SESSION:
            print(byteBuffer)
            
            do {
                let decodedData = try self.decoder.decode(BaseResponse<ChattingRooms>.self, from: byteBuffer)
                print(decodedData)
            } catch {
                print("decode error")
            }
            
        default:
            break
        }
        
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
