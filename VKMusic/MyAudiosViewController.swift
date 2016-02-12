//
//  MyAudiosViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class MyAudiosViewController: AudiosViewController, UISearchResultsUpdating {
    
    private var allAudios = [Audio]()
    private var filteredAudios = [Audio]()
    private var audios: [Audio] {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredAudios
        }
        return allAudios
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        screenName = .All
        tableView.allowsMultipleSelectionDuringEditing = true
        getAudious()
    
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.whiteColor()
        refreshControl!.tintColor = UIColor.grayColor()
        refreshControl!.addTarget(self, action: Selector("updateAudios"), forControlEvents: .ValueChanged)
    }
    
    //MARK: - Audio
    
    @objc private func updateAudios() {
        RequestManager.sharedManager.getAudios{ serverData in
            let count = serverData.count - self.allAudios.count
            var indexPaths = [NSIndexPath]()
            for var i = count - 1; i >= 0; i-- {
                let audio = Audio(serverData: serverData[i] as! [String: AnyObject])
                self.allAudios.insert(audio, atIndex: 0)
                indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
            self.tableView.endUpdates()
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func getAudious() {
        let shouldLogin = LoginManager.sharedManager.reloginIfNeeded {
            self.loadAudios()
        }
        if !shouldLogin {
            loadAudios()
        }
    }
    
    private func loadAudios() {
        RequestManager.sharedManager.getAudios{ serverData in
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
                self.player.kill()
                self.currentIndex = -1
            }
            if self.audios == self.filteredAudios {
                let index = self.allAudios.indexOf(audio)!
                self.allAudios.removeAtIndex(index)
                self.filteredAudios.removeAtIndex(indexPath.row)
            } else {
                self.allAudios.removeAtIndex(indexPath.row)
            }
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            self.tableView.endUpdates()
            self.updatePlayerPlaylistIfNeeded()
        }
    }
    
    private func updatePlayerPlaylistIfNeeded() {
        if player.playbleScreen == .All {
            player.setPlayList(audios)
        }
    }
    
    //MARK: - Search
    
    override func generateSearchController() {
        super.generateSearchController()
        searchController.searchResultsUpdater = self
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
        if player.playbleScreen != .All {
            player.playbleScreen = .All
            player.delegate = self
            player.setPlayList(audios)
        }
        currentIndex = indexPath.row
        player.playAudioFromIndex(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if currentIndex != -1 {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false, scrollPosition: .None)
        }
    }
}
