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
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
    
}
