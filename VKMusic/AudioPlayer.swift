//
//  AudioPlayer.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    static let defaultPlayer = AudioPlayer()
    
    private let commandCenter = CommandCenter.defaultCenter
    
    private var player: AVPlayer!
    var currentAudio: Audio!
    private var currentPlayList = [Audio]()
    
    //MARK: - Public API
    
    func playAudioFromIndex(index: Int) {
        currentAudio = currentPlayList[index]
        let playerItem = AVPlayerItem(URL: NSURL(string: currentAudio.url)!)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        commandCenter.setNowPlayingInfo()
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
            }
        }
    }
    
    func previous() {
        if let currentIndex = currentPlayList.indexOf(currentAudio) {
            if currentIndex > 0 {
                playAudioFromIndex(currentIndex - 1)
            }
        }
    }
    
    func kill() {
        if player != nil {
            player.replaceCurrentItemWithPlayerItem(nil)
        }
    }
}