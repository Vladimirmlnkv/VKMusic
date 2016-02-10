//
//  MyAudiosViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class MyAudiosViewController: UITableViewController, UISearchResultsUpdating {

    private let player = AudioPlayer.defaultPlayer
    
    private var allAudios = [Audio]()
    private var filteredAudios = [Audio]()
    private var audios: [Audio] {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredAudios
        }
        return allAudios
    }
        
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        title? = "Music"
        generateSearchController()
        getAudious()
    }
    
    //MARK: - Audio
    
    private func getAudious() {
        let shouldLogin = LoginManager.sharedManager.reloginIfNeeded {
            self.loadAudios()
        }
        if !shouldLogin {
            loadAudios()
        }
    }
    
    private func loadAudios() {
        RequestManager.sharedManager.getAudios { serverData in
            for data in serverData {
                let audio = Audio(serverData: data as! [String: AnyObject])
                self.allAudios.append(audio)
            }
            self.tableView.reloadData()
        }
    }
    
    private func deleteAudioFromIndexPath(indexPath: NSIndexPath) {
        let audio = audios[indexPath.row]
        RequestManager.sharedManager.deleteAudio(audio) {
            if self.player.currentAudio != nil && self.player.currentAudio == audio {
                self.player.next()
            }
            if self.audios == self.filteredAudios {
                self.allAudios.removeAtIndex(indexPath.row)
                self.filteredAudios.removeAtIndex(indexPath.row)
            } else {
                self.allAudios.removeAtIndex(indexPath.row)
            }
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            self.tableView.endUpdates()
        }
    }
    
    //MARK: - Search
    
    private func generateSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func filterAudiosForSearchText(searchText: String) {
        filteredAudios = allAudios.filter{ audio in
            let searchWords = searchText.componentsSeparatedByString(" ")
            for word in searchWords {
                if !(audio.title.lowercaseString.containsString(word.lowercaseString) || audio.artist.lowercaseString.containsString(word.lowercaseString)) && word != "" {
                    return false
                }
            }
            return true
        }
        tableView.reloadData()
    }
    
    //MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterAudiosForSearchText(searchController.searchBar.text!)
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteAudioFromIndexPath(indexPath)
        }
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        player.setPlayList(audios)
        player.playAudioFromIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    //MARK: - Actions
    
    @IBAction func logoutAction(sender: AnyObject) {
        LoginManager.sharedManager.logout()
        player.kill()
    }
    

}
