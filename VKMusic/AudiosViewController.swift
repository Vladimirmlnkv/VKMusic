//
//  AudiosViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 11.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class AudiosViewController: UITableViewController, AudioPlayerDelegate {

    let player = AudioPlayer.defaultPlayer
    var screenName = PlaybleScreen.None
    
    let searchController = UISearchController(searchResultsController: nil)
    var currentIndex = -1
    
    override func viewDidLoad() {
        generateSearchController()
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

    //MARK: - Actions
    
    @IBAction func logoutAction(sender: AnyObject) {
        LoginManager.sharedManager.logout()
        player.kill()
    }
    
    //MARK: - AudioPlayerDelegate
    
    func playerWillPlayNextSong(index index: Int, lastIndex: Int) {
        currentIndex = index
        tableView.deselectRowAtIndexPath(NSIndexPath(forRow: lastIndex, inSection: 0), animated: true)
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: .None)
    }
    
    func playerWillChangePlaybleScreen() {
        currentIndex = -1
    }
}
