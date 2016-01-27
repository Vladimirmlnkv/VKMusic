//
//  MusicViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 27.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import AVFoundation

enum UpdateAction {
    case Play
    case Pause
    case Next
    case Last
}

class MusicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controlView: ControlView!
    
    var audios = [Audio]()
    var player: AVPlayer!
    var currentAudio: Audio!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationItem.title! = "Music"
        loadAudios()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Support
    
    private func loadAudios() {
        RequestManager.sharedManager.authorizeUser {
            RequestManager.sharedManager.getAudios { serverData in
                for data in serverData {
                    let audio = Audio(serverData: data as! [String: AnyObject])
                    self.audios.append(audio)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Player Methods
    
    func playAudioFromIndex(index: Int) {
        currentAudio = audios[index]
        let playerItem = AVPlayerItem(URL: NSURL(string: currentAudio.url)!)
        self.player = AVPlayer(playerItem: playerItem)
        self.player.play()
        controlView.updateInfo(titile: currentAudio.title, artist: currentAudio.artist, duration: currentAudio.duration)
        controlView.updatePlayButton(.Play)
    }
    
    private func updatePlayer(action: UpdateAction) {
        switch action {
        case .Play:
            if player == nil {
                playAudioFromIndex(0)
            } else {
                player.play()
                controlView.updatePlayButton(.Play)
            }
        case .Pause:
            player.pause()
            controlView.updatePlayButton(.Pause)
        case .Next:
            if audios.count > 0 {
                guard let audio = currentAudio else {
                    playAudioFromIndex(0)
                    return
                }
                let currentIndex = audios.indexOf(audio)!
                if currentIndex + 1 <= audios.count - 1 {
                    playAudioFromIndex(currentIndex + 1)
                }
            }
        case .Last:
            if audios.count > 0 {
                guard let audio = currentAudio else {
                    return
                }
                let currentIndex = audios.indexOf(audio)!
                if currentIndex > 0 {
                    playAudioFromIndex(currentIndex - 1)
                }
            }
        }
    }

    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        let audio = audios[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        playAudioFromIndex(indexPath.row)
    }
    
    //MARK: - Action
    

    @IBAction func playAction(sender: UIButton) {
        if sender.titleLabel!.text! == "Play" {
            updatePlayer(.Play)
        } else {
            updatePlayer(.Pause)
        }
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        updatePlayer(.Next)
    }
    
    @IBAction func lastAction(sender: AnyObject) {
        updatePlayer(.Last)
    }
    
}
