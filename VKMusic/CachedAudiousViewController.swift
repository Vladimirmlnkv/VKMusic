//
//  CachedAudiousViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import RealmSwift

class CachedAudiousViewController: AudiosViewController, UISearchResultsUpdating {
    
    private var objects = Results<SavedAudio>!()
    private var savedAudios = [Audio]()
    private var filteredAudios = [Audio]()
    override var audios: [Audio] {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredAudios
        }
        return savedAudios
    }

    
    private var isAudioDeleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAudios()
        addRefreshControl()
        screenName = .Cache
    }
    
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
                currentIndex = savedAudios.indexOf(audio)!
            }else {
                currentIndex = -1
            }
        }
    }
    
    private func deleteAudioFromIndexPath(indexPath: NSIndexPath) {
        let realm = try! Realm()
        try! realm.write({ () -> Void in
            realm.delete(self.objects[indexPath.row])
        })
        let audio = audios[indexPath.row]
        if player.currentAudio != nil && player.currentAudio == audio {
            player.kill()
        }
        if audios == filteredAudios {
            let index = savedAudios.indexOf(audio)!
            savedAudios.removeAtIndex(index)
            filteredAudios.removeAtIndex(indexPath.row)
        } else {
            savedAudios.removeAtIndex(indexPath.row)
        }
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        tableView.endUpdates()
        updateCurrentIndex()
        updatePlayerPlaylistIfNeeded()
    }
    
    //MARK: - Search
    
    override func generateSearchController() {
        super.generateSearchController()
        searchController.searchResultsUpdater = self
    }
    
    private func filterAudiosForSearchText(searchText: String) {
        filteredAudios = savedAudios.filter{ audio in
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

    //MARK: - Realm
    
    @objc private func updateAudios() {
        var indexPaths = [NSIndexPath]()
        let realm = try! Realm()
        objects = realm.objects(SavedAudio)
        for var i = savedAudios.count; i < objects.count; i++ {
            let object = objects[i]
            savedAudios.append(Audio(url: object.url, title: object.title, artist: object.artist, duration: object.duration))
            indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
        self.tableView.endUpdates()
        self.refreshControl?.endRefreshing()
        updateCurrentIndex()
        updatePlayerPlaylistIfNeeded()
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        let audio = audios[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        setAccessoryType(cell)
        return cell
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
}
