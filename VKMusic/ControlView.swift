//
//  ControlView.swift
//  VKMusic
//
//  Created by Владимир Мельников on 27.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

enum PlayButtonState {
    case Play
    case Pause
}

class ControlView: UIView {
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    var playState = PlayButtonState.Play
    
    func updateInfo(titile title: String, artist: String, duration: Int) {
        titleLabel.text? = "\(artist) - \(title)"
        durationLabel.text? = durationString(duration)
        currentDurationLabel.text? = "0"
        updatePlayButton(.Pause)
    }
    
    func updatePlayButton(state: PlayButtonState) {
        playState = state
        switch state {
        case .Play: playButton.setTitle("Pause", forState: .Normal)
        case .Pause: playButton.setTitle("Play", forState: .Normal)
        }
    }
    
    func durationString(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration - minutes * 60
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        return "\(minutes):\(seconds)"
    }
}
