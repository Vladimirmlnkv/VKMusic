//
//  SearchAudiosViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 09.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class SearchAudiosViewController: AudiosViewController, UISearchBarDelegate {

    private var searchAudious = [Audio]()
    override var audios: [Audio] {
        return searchAudious
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = .Search
    }

    //MARK: - Support
    
    private func showMessage() {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        
        messageLabel.text = "Please search for audios.";
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont(name: ".SFUIText-Medium", size: 20)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .None
    }
    
    //NARK: - Search
    
    override func generateSearchController() {
        super.generateSearchController()
        searchController.searchBar.delegate = self
    }
    
    private func searchForAudios() {
        if searchController.active && searchController.searchBar.text != "" {
            RequestManager.sharedManager.searchAudios(searchText: searchController.searchBar.text!, offset: searchAudious.count, count: 30) { serverData in
                for data in serverData {
                    let audio = Audio(serverData: data as! [String: AnyObject])
                    self.searchAudious.append(audio)
                }
                self.tableView.reloadData()
            }
        } else {
            searchAudious = [Audio]()
            tableView.reloadData()
        }
        updatePlayerPlaylistIfNeeded()
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForAudios()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchAudious = [Audio]()
        tableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchAudious.count > 0 {
            return 1
        } else {
            showMessage()
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! SearchCell
        let audio = searchAudious[indexPath.row]
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
        if indexPath.row >= searchAudious.count - 5 {
            searchForAudios()
        }
        setAccessoryType(cell)
        return cell
    }

    //MARK: - Actions
    
    private func addAudioFromRow(row: Int) {
        var audio = searchAudious[row]
        RequestManager.sharedManager.addAudio(audio){ newID in
            audio.ownerID = Int(RequestManager.sharedManager.accessToken!.userID)!
            audio.id = newID
            let alert = UIAlertController(title: "\(audio.artist) - \(audio.title)", message: "Added to your audios", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addAction(sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as? UITableViewCell
        if let c = cell {
            let row = tableView.indexPathForCell(c)!.row
            addAudioFromRow(row)
        }
    }
}
