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
    
    let searchController = UISearchController(searchResultsController: nil)
    var currentIndex = -1
    
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
    
    //NARK: - Notifications
    
    @objc private func handleAudioPlayerWillChangePlaybleScreenNotification() {
        if screenName != player.playbleScreen {
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
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: .None)
        }
    }

    //MARK: - Actions
    
    @IBAction func logoutAction(sender: AnyObject) {
        LoginManager.sharedManager.logout()
        player.kill()
    }
}
