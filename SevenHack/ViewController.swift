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
//    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!

    private var nfcSession: NFCNDEFReaderSession?

    private let heartbeatInterval = 2.0
    private var heartbeatTimer: Timer?
    private var lastHeartbeat: Double?
    private var untrackedHeartbeatSeconds = 0.0

    private let videos = [
        "WegyKz5FJC8",
        "Wg04ktp2Ieg",
        "aqvqabwx7HU",
        "6cOOTovIyf8",
        "WuOpXzQhDFI"
    ]

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        setUpUI()
        setUpPlayer()

        fetchBalance()
        loadVideo(number: 1)
    }

//    @IBAction func scan(_ sender: Any) {
//        nfcSession = NFCNDEFReaderSession(delegate: self,
//                                          queue: nil,
//                                          invalidateAfterFirstRead: true)
//        nfcSession?.alertMessage = "Let me grab all your private data! 😈"
//        nfcSession?.begin()
//    }

    @IBAction func loadVideo(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text,
            let number = Int(text) else { return }
        loadVideo(number: number)
    }

    private func setUpUI() {
        display(balance: nil)
        noteLabel.isHidden = true
    }

    private func loadVideo(number: Int) {
        guard number > 0 && number <= videos.count else { return }
        let index = number - 1
        let id = videos[index]
        print("load video: \(number) = video[\(index)] = \(id)")
        activityIndicator.startAnimating()
        youtubePlayerView.isHidden = true
        youtubePlayerView.load(withVideoId: id, playerVars: playerVars)
    }

    private func setUpPlayer() {
        youtubePlayerView.delegate = self
    }

    private func fetchBalance() {
        API.getBalance { result in
            switch result {
            case .success(let balances):
                guard let balance = balances.first else { break }
                DispatchQueue.main.async {
                    self.display(balance: balance)
                }
                print("SUCCESS: \(balance)")
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }

    private func secondsToTime (seconds : Int) -> String {
        let (h, m, s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        var time = ""
        if h > 0 {
            time += "\(h)h "
        }
        if m > 0 {
            time += "\(m)m "
        }
        time += "\(s)s "
        return time
    }

    private func display(balance: Balance? = nil) {

        if let time = balance?.limits {
            timeLabel.text = secondsToTime(seconds: time)
            timeLabel.isHidden = false
        } else {
            timeLabel.isHidden = true
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
                DispatchQueue.main.async {
                    self.display(balance: balance)
                }
            case .failure(let error):
                print("⏲ ERROR: \(error)")
            }
        }
    }

}

extension ViewController: YTPlayerViewDelegate {

    var playerVars: [AnyHashable: Any] {
        return [
            "playsinline": 1
        ]
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        print("playerViewDidBecomeReady")
        activityIndicator.stopAnimating()
        youtubePlayerView.isHidden = false
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
