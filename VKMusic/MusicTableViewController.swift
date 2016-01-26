//
//  MusicTableViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class MusicTableViewController: UITableViewController {
    
    var audious = [Audio]()
    
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
                    self.audious.append(audio)
                    self.tableView.reloadData()
                }
                print(self.audious.count)
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audious.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        let audio = audious[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        
        return cell
    }
}
