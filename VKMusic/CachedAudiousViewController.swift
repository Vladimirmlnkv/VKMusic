//
//  CachedAudiousViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import RealmSwift

class CachedAudiousViewController: AudiosViewController {
    
    private var objects = Results<SavedAudio>!()
    private var savedAudios = [Audio]()
    override var audios: [Audio] {
        return savedAudios
    }
    
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
        return savedAudios.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        let audio = savedAudios[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        setAccessoryType(cell)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
