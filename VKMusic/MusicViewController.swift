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
    
    private func playAudioFromURL(url: NSURL) {
        let playerItem = AVPlayerItem(URL: url)
        self.player = AVPlayer(playerItem: playerItem)
        self.player.play()
    }
    
    private func updatePlayer(action: UpdateAction) {

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
        let audio = audios[indexPath.row]
        if let url = NSURL(string: audio.url) {
            playAudioFromURL(url)
            controlView.updateInfo(titile: audio.title, artist: audio.artist, duration: audio.duration)
        }
    }
    
    //MARK: - Action
    

    @IBAction func playAction(sender: UIButton) {
        switch sender.titleLabel!.text! {
        case "Play":
            controlView.updatePlayButton(.Pause)
            player.play()
        case "Pause":
            controlView.updatePlayButton(.Play)
            player.pause()
        default: return
        }
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        
    }
    
    @IBAction func lastAction(sender: AnyObject) {
        
    }
    
}
