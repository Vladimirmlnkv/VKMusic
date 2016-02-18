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
    override var audios: [Audio] {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredAudios
        }
        return allAudios
    }
    
    private var isAudioDeleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenName = .All
        tableView.allowsMultipleSelectionDuringEditing = true
        getAudious()
        addRefreshControl()
    }

    //MARK: - Support
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.whiteColor()
        refreshControl!.tintColor = UIColor.grayColor()
        refreshControl!.addTarget(self, action: Selector("updateAudios"), forControlEvents: .ValueChanged)
    }
    
    private func updateCurrentIndex() {
        if player.playbleScreen == screenName {
            tableView.deselectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false)
            if let audio = player.currentAudio {
                currentIndex = allAudios.indexOf(audio)!
            }else {
                currentIndex = -1
            }
        }
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
            self.updateCurrentIndex()
            self.updatePlayerPlaylistIfNeeded()
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
            self.updateCurrentIndex()
            self.updatePlayerPlaylistIfNeeded()
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        let audio = audios[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        setAccessoryType(cell)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            isAudioDeleted = true
            deleteAudioFromIndexPath(indexPath)
        }
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if currentIndex != -1 && !isAudioDeleted {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false, scrollPosition: .None)
        } else if editing == true {
            isAudioDeleted = false
        }
    }
    
    //MARK: - Actions
    
    @IBAction func downloadButtonAction(sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as? UITableViewCell
        if let c = cell {
            let row = tableView.indexPathForCell(c)!.row
            let audio = audios[row]
            DownloadManager.sharedManager.downloadAudio(audio)
        }
    }
    
}
