//
//  MusicTableViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import AVFoundation

class MusicTableViewController: UITableViewController {
    
    var audios = [Audio]()
    var player: AVPlayer!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        let audio = audios[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        let audio = audios[indexPath.row]
        let url = NSURL(string: audio.url)
        if let u = url {
            playAudioFromURL(u)
        }
    }

}
