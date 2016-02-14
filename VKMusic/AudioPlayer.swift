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

let audioPlayerWillPlaySongNotificationKey = "audioPlayerWillPlaySongNotification"

let audioPlayerWillChangePlaybleScreenNotificationKey = "audioPlayerWillChangePlaybleScreenNotification"
let audioPlayerWillPlayNextSongNotificationKey = "audioPlayerWillPlayNextSongNotification"

class AudioPlayer {
    
    static let defaultPlayer = AudioPlayer()
        
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
        killTimeObserver()
        currentAudio = currentPlayList[index]
        let playerItem = AVPlayerItem(URL: NSURL(string: currentAudio.url)!)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        addTimeObeserver()
        CommandCenter.defaultCenter.setNowPlayingInfo()
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
            player.replaceCurrentItemWithPlayerItem(nil)
            currentAudio = nil
        }
    }
    
    func setPlayList(playList: [Audio]) {
        currentPlayList = playList
    }
}