//
//  AudioPlayer.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation
import AVFoundation

enum PlaybleScreen {
    case None
    case All
    case Search
    case Cache
}

let audioPlayerWillChangePlaybleScreenNotificationKey = "audioPlayerWillChangePlaybleScreenNotification"
let audioPlayerWillPlayNextSongNotificationKey = "audioPlayerWillPlayNextSongNotification"

protocol AudioPlayerDelegate {
    func audioDidChangeTime(time: Int64)
    func playerWillPlayNexAudio()
}

class AudioPlayer {
    
    static let defaultPlayer = AudioPlayer()
    
    var delegate: AudioPlayerDelegate?
        
    private var player: AVPlayer!
    var currentAudio: Audio!
    var playbleScreen = PlaybleScreen.None {
        willSet {
            NSNotificationCenter.defaultCenter().postNotificationName(audioPlayerWillChangePlaybleScreenNotificationKey, object: nil, userInfo: nil)
        }
    }
    
    private var currentPlayList = [Audio]()
    private var timeObserber: AnyObject?

    //MARK: - Time Observer
    
    private func addTimeObeserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserber = player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) {
            (time: CMTime) -> Void in
            let currentTime  = Int64(time.value) / Int64(time.timescale)
            if let d = self.delegate {
                d.audioDidChangeTime(currentTime)
            }
            if currentTime == Int64(self.currentAudio.duration) {
                self.next()
            }
        }
    }
    
    private func killTimeObserver() {
        if let observer = timeObserber {
            player.removeTimeObserver(observer)
        }
    }
    
    //MARK: - Public API
    
    func playAudioFromIndex(index: Int) {
        currentAudio = currentPlayList[index]
        let playerItem = AVPlayerItem(URL: NSURL(string: currentAudio.url)!)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        addTimeObeserver()
        CommandCenter.defaultCenter.setNowPlayingInfo()
        if let d = self.delegate {
            d.playerWillPlayNexAudio()
        }
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func next() {
        if let currentIndex = currentPlayList.indexOf(currentAudio) {
            if currentIndex + 1 <= currentPlayList.count - 1 {
                playAudioFromIndex(currentIndex + 1)
                let userInfo = ["index": currentIndex + 1, "lastIndex": currentIndex]
                NSNotificationCenter.defaultCenter().postNotificationName(audioPlayerWillPlayNextSongNotificationKey, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func previous() {
        if let currentIndex = currentPlayList.indexOf(currentAudio) {
            if currentIndex > 0 {
                playAudioFromIndex(currentIndex - 1)
                let userInfo = ["index": currentIndex - 1, "lastIndex": currentIndex]
                NSNotificationCenter.defaultCenter().postNotificationName(audioPlayerWillPlayNextSongNotificationKey, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func kill() {
        if player != nil {
            killTimeObserver()
            player.replaceCurrentItemWithPlayerItem(nil)
            currentAudio = nil
        }
    }
    
    func setPlayList(playList: [Audio]) {
        currentPlayList = playList
    }
    
    func seekToTime(time: CMTime) {
        player.seekToTime(time)
    }
}