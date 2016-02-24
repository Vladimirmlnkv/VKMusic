//
//  AudiosViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 11.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class AudiosViewController: UITableViewController {

    let player = AudioPlayer.defaultPlayer
    var screenName = PlaybleScreen.None
    
    private final var myAudios = [Audio]()
    var audios: [Audio] {
        return myAudios
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var currentIndex = -1 {
        willSet(newIndex) {
            if newIndex != -1 {
                tableView.selectRowAtIndexPath(NSIndexPath(forRow: newIndex, inSection: 0), animated: true, scrollPosition: .None)
            }
        }
    }
    
    override func viewDidLoad() {
        generateSearchController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleAudioPlayerWillChangePlaybleScreenNotification"), name: audioPlayerWillChangePlaybleScreenNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleAudioPlayerWillPlayNextSongNotification:"), name: audioPlayerWillPlayNextSongNotificationKey, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentIndex != -1 && player.playbleScreen == screenName {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false, scrollPosition: .None)
        }
    }
    
    func generateSearchController() {
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updatePlayerPlaylistIfNeeded() {
        if player.playbleScreen == screenName {
            player.setPlayList(audios)
        }
    }
    
    func setAccessoryType(cell: AudioCell) {
        if player.currentAudio != nil && player.playbleScreen == screenName {
            if cell.titleLabel.text == "\(player.currentAudio.artist) - \(player.currentAudio.title)" {
                cell.accessoryType = .DisclosureIndicator
            } else {
                cell.accessoryType = .None
            }
        }
    }
    
    //NARK: - Notifications
    
    @objc private func handleAudioPlayerWillChangePlaybleScreenNotification() {
        if screenName == player.playbleScreen && currentIndex != -1 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0))
            cell?.accessoryType = .None
            currentIndex = -1
        }
    }
    
    @objc private func handleAudioPlayerWillPlayNextSongNotification(notification: NSNotification) {
        if screenName == player.playbleScreen {
            let info = notification.userInfo!
            let index = info["index"] as! Int
            let lastIndex = info["lastIndex"] as! Int
            currentIndex = index
            tableView.deselectRowAtIndexPath(NSIndexPath(forRow: lastIndex, inSection: 0), animated: true)
        }
    }

    //MARK: - Actions
    
    @IBAction func logoutAction(sender: AnyObject) {
        LoginManager.sharedManager.logout()
        player.kill()
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        if player.playbleScreen != screenName {
            player.playbleScreen = screenName
            player.setPlayList(audios)
        }
        if currentIndex == indexPath.row {
            let playerVC = storyboard?.instantiateViewControllerWithIdentifier("playerVC")
            presentViewController(playerVC!, animated: true, completion: nil)
        } else {
            currentIndex = indexPath.row
            player.playAudioFromIndex(indexPath.row)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .DisclosureIndicator
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .None
    }
}
