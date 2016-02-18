//
//  PlayerViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 12.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import CoreMedia

class PlayerViewController: UIViewController, AudioPlayerDelegate {
    
    private let player = AudioPlayer.defaultPlayer

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    
    @IBOutlet weak var albumCoverView: UIImageView!
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var currenTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setInfo()
    }
    
    private func setInfo() {
        let audio = player.currentAudio
        artistNameLabel.text? = audio.artist
        songNameLabel.text? = audio.title
        durationLabel.text? = durationString(audio.duration)
        currenTimeLabel.text? = "0:00"
        durationSlider.value = 0
        durationSlider.maximumValue = Float(audio.duration)
    }
    
    private func durationString(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration - minutes * 60
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        return "\(minutes):\(seconds)"
    }
    
    //MARK: - AudioPlayerDelegate
    
    func audioDidChangeTime(time: Int64) {
        currenTimeLabel.text? = durationString(Int(time))
        durationSlider.value = Float(time)
    }
    
    func playerWillPlayNexAudio() {
        setInfo()
    }
    
    //MARK: - Button Actions
    
    private func updatePlayButton() {
        if playButton.imageView?.image == UIImage(named: "play") {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
    }
    
    @IBAction func playButtonAction(sender: AnyObject) {
        let button = sender as! UIButton
        if button.imageView?.image == UIImage(named: "play") {
            button.setImage(UIImage(named: "pause"), forState: .Normal)
            player.play()
        } else {
            button.setImage(UIImage(named: "play"), forState: .Normal)
            player.pause()
        }
    }
    
    @IBAction func nextButtonAction(sender: AnyObject) {
        player.next()
        updatePlayButton()
    }
    
    @IBAction func previousButtonAction(sender: AnyObject) {
        player.previous()
        updatePlayButton()
    }
    
    @IBAction func dissmissButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Duration Actions
    
    @IBAction func remoteAction(sender: UISlider) {
        player.pause()
        let value = sender.value
        let time = CMTime(value: Int64(value), timescale: 1)
        currenTimeLabel.text? = durationString(Int(value))
        player.seekToTime(time)
    }
    
    @IBAction func remoteEnded(sender: AnyObject) {
        player.play()
        updatePlayButton()
    }
    
}
