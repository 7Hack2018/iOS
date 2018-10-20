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

    var nfcSession: NFCNDEFReaderSession?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        youtubePlayerView.load(withVideoId: "pIfRdTgy-bc", playerVars: playerVars)
    }

    @IBAction func scan(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession(delegate: self,
                                          queue: nil,
                                          invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Let me grab all your private data! 😈"
        nfcSession?.begin()
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
                if let s = String(data: payload.payload, encoding: .utf8) {
                    result += s
                }
            }
        }

        print(result)
    }

}
