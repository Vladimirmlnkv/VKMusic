//
//  CommandCenter.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation
import MediaPlayer

class CommandCenter: NSObject {
    
    static let defaultCenter = CommandCenter()
    
    private let player = AudioPlayer.defaultPlayer
    
    private override init() {
        super.init()
        setCommandCenter()
        setAudioSeccion()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleAudioSessionRouteChangeNotification:"), name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setAudioSeccion() {
        let audioSeccion = AVAudioSession.sharedInstance()
        do {
            try audioSeccion.setCategory("AVAudioSessionCategoryPlayback")
            try audioSeccion.setActive(true)
        } catch {
            print("ERROR")
        }
    }
    
    //MARK: - Notifications
    
    @objc private func handleAudioSessionRouteChangeNotification(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            if let s = info["AVAudioSessionRouteChangeReasonKey"] {
                if s as! NSObject == 2 {
                    player.pause()
                }
            }
        }
    }
    
    //MARK: - Remote Command Center
    
    private func setCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.pauseCommand.addTarget(self, action: Selector("remoteCommandPause"))
        commandCenter.playCommand.addTarget(self, action: Selector("remoteCommandPlay"))
        commandCenter.nextTrackCommand.addTarget(self, action: Selector("remoteCommandNext"))
        commandCenter.previousTrackCommand.addTarget(self, action: Selector("remoteCommandPrevious"))
    }
    
    @objc private func remoteCommandPause() {
        player.pause()
    }
    
    @objc private func remoteCommandPlay() {
        player.play()
    }
    
    @objc private func remoteCommandNext() {
        player.next()
    }
    
    @objc private func remoteCommandPrevious() {
        player.previous()
    }
    
    //MARK: - Public Methods
    
    func setNowPlayingInfo() {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: player.currentAudio.title,
                                                                MPMediaItemPropertyArtist: player.currentAudio.artist,
                                                                MPNowPlayingInfoPropertyPlaybackRate: 1.0]
    }
    
}