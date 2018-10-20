//
//  ViewController.swift
//  SevenHack
//
//  Created by Miguel Dönicke on 20.10.18.
//  Copyright © 2018 Miguel Dönicke. All rights reserved.
//

import CoreNFC
import UIKit
import youtube_ios_player_helper

class ViewController: UIViewController {

    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    @IBOutlet weak var scanButton: UIButton!

    private var nfcSession: NFCNDEFReaderSession?

    private let heartbeatInterval = 5.0
    private var heartbeatTimer: Timer?
    private var lastHeartbeat: Double?
    private var untrackedHeartbeatSeconds = 0.0

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        fetchBalance()
        setUpPlayer()
        loadVideo()
    }

    @IBAction func scan(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession(delegate: self,
                                          queue: nil,
                                          invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Let me grab all your private data! 😈"
        nfcSession?.begin()
    }

    private func setUpPlayer() {
        youtubePlayerView.delegate = self
    }

    private func loadVideo() {
        youtubePlayerView.load(withVideoId: "pIfRdTgy-bc", playerVars: playerVars)
    }

    private func fetchBalance() {
        API.getBalance { result in
            switch result {
            case .success(let balance):
                print("SUCCESS: \(balance)")
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }

    private func startHeartbeat() {
        print("START HEARTBEAT ❤")

        heartbeatTimer?.invalidate()
        lastHeartbeat = Date.now

        guard untrackedHeartbeatSeconds < 1 else {
            print("UNTRACKED HEARTBEAT: \(untrackedHeartbeatSeconds)")
            heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval - untrackedHeartbeatSeconds, repeats: false) { _ in
                self.heartbeat()
                if self.untrackedHeartbeatSeconds >= self.heartbeatInterval {
                    self.untrackedHeartbeatSeconds -= self.heartbeatInterval
                } else {
                    self.untrackedHeartbeatSeconds = 0
                }
                self.startHeartbeat()
            }
            return
        }

        heartbeatTimer = Timer.scheduledTimer(timeInterval: heartbeatInterval,
                                              target: self,
                                              selector: #selector(heartbeat),
                                              userInfo: nil,
                                              repeats: true)
    }

    private func stopHeartbeat() {
        print("STOP HEARTBEAT 💔")
        heartbeatTimer?.invalidate()
        if let distance = lastHeartbeat?.distance(to: Date.now) {
            untrackedHeartbeatSeconds += distance
            print("💔 DISTANCE: \(distance) = \(untrackedHeartbeatSeconds)")
        }
        lastHeartbeat = nil
    }

    @objc private func heartbeat() {
        print("❤️")
        lastHeartbeat = Date.now
        API.heartbeat(service: "YT") { result in
            switch result {
            case .success(let balance):
                print("⏲ BALANCE: \(balance)")
            case .failure(let error):
                print("⏲ ERROR: \(error)")
            }
        }
    }

}

extension ViewController: YTPlayerViewDelegate {

    var playerVars: [AnyHashable: Any] {
        return [
            "playsinline": 0
        ]
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("playerViewDidBecomeReady")
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print("didChangeTo state: \(state)")
        switch state {
        case .playing:
            startHeartbeat()
        default:
            stopHeartbeat()
        }
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo quality: YTPlaybackQuality) {
        print("didChangeTo quality: \(quality)")
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        print("playTime: \(playTime)")
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        print("\(error)")
    }

}

extension ViewController: NFCNDEFReaderSessionDelegate {

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("The session was invalidated: \(error.localizedDescription)")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        for message in messages {
            for payload in message.records {
                if let s = String(data: payload.payload.advanced(by: 3), encoding: .utf8) {
                    result += s
                }
            }
        }
    }

}

extension Date {

    static var now: Double {
        return Date().timeIntervalSince1970
    }

}
