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
    private var cmdSrl: Int = 0
    
    // MARK: - 테스트
    private var harkunStageId: String = Config().harkunStageId
    private var myProductionId: String = Config().myProductionId
    private var productionSessionRequest: String = Config().productionSessionRequest
    private var productionSessionByte: String = Config().productionSessionByte
    private var myProductionSesssionRequest: String = Config().myProductionSesssionRequest

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
        
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
        cmdSrl += 1
        
        let cmd: String = HexUtil.convertInt(11000)
        let cmdSrl: String = HexUtil.convertInt(cmdSrl)
        let userId: String = HexUtil.convertString(myProductionId)
        let channelId = HexUtil.convertString(myProductionId)
        let hexData: String = cmd + cmdSrl + userId + channelId // MARK: - myProductionSesssionRequest 나옴
        
        print("sessionLogin 요청 데이터 - \(hexData)")
    
        webSocketTask?.send(.data(Data(hex: hexData))) { [weak self] error in // MARK: - 아니 왜 ios target 14.5로 똑같이 맞췄는데 이건 hex 파라미터가 없대... ????
            if let error = error {
                print("sessionLogin 실패 \(error)")
            } else {
                print("sessionLogin 보냄")
                self?.addListener()
            }
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
