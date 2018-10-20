//
//  ViewController.swift
//  SevenHack
//
//  Created by Miguel Dönicke on 20.10.18.
//  Copyright © 2018 Miguel Dönicke. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class ViewController: UIViewController {

    @IBOutlet weak var youtubePlayerView: YTPlayerView!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        print("viewDidLoad")
        youtubePlayerView.load(withVideoId: "pIfRdTgy-bc", playerVars: playerVars)
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
