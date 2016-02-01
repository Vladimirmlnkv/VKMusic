//
//  MusicViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 27.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

private enum UpdateAction {
    case Play
    case Pause
    case Next
    case Last
}

class MusicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controlView: ControlView!

    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentSection = 0
    
    private var allAudios = [Audio]()
    private var filteredAudios = [Audio]()
    private var searchAudious = [Audio]()
    private var audios: [Audio] {
        get {
            if currentSection == 0 {
                if searchController.active && searchController.searchBar.text != "" {
                    return filteredAudios
                } else {
                    return allAudios
                }
            } else {
                return searchAudious
            }
        }
    }
    private var currentAudio: Audio!

    private var player: AVPlayer!
    private var timeObserber: AnyObject?
    
    private let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleAudioSessionRouteChangeNotification:"), name: AVAudioSessionRouteChangeNotification, object: nil)

        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title! = "Music"
        
        setCommandCenter()
        setAudioSeccion()
        generateSearchController()
        loadAudios()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        killTimeObserver()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    //MARK: - RemoteCommandCenter
    
    private func setCommandCenter() {
        commandCenter.pauseCommand.addTarget(self, action: Selector("remoteCommandPause"))
        commandCenter.playCommand.addTarget(self, action: Selector("remoteCommandPlay"))
        commandCenter.nextTrackCommand.addTarget(self, action: Selector("remoteCommandNext"))
        commandCenter.previousTrackCommand.addTarget(self, action: Selector("remoteCommandPrevious"))
    }
    
    private func setNowPlayingInfo() {
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [MPMediaItemPropertyTitle: currentAudio.title,
                                                                    MPMediaItemPropertyArtist: currentAudio.artist,
                                                                    MPNowPlayingInfoPropertyPlaybackRate: 1.0]
    }

    @objc private func remoteCommandPause() {
        updatePlayer(.Pause)
    }
    
    @objc private func remoteCommandPlay() {
        updatePlayer(.Play)
    }
    
    @objc private func remoteCommandNext() {
        updatePlayer(.Next)
    }
    
    @objc private func remoteCommandPrevious() {
        updatePlayer(.Last)
    }
    
    //MARK: - Support
    
    private func setAudioSeccion() {
        let audioSeccion = AVAudioSession.sharedInstance()
        do {
            try audioSeccion.setCategory("AVAudioSessionCategoryPlayback")
            try audioSeccion.setActive(true)
        } catch {
            print("ERROR")
        }
    }
    
    private func generateSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    private func loadAudios() {
        RequestManager.sharedManager.getAudios { serverData in
            for data in serverData {
                let audio = Audio(serverData: data as! [String: AnyObject])
                self.allAudios.append(audio)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Notifications
    
    @objc private func handleAudioSessionRouteChangeNotification(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            if let s = info["AVAudioSessionRouteChangeReasonKey"] {
                if s as! NSObject == 2 {
                    updatePlayer(.Pause)
                }
            }
        }
    }
    
    //MARK: - Player Methods
    
    private func addTimeObeserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserber = player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) {
            (time: CMTime) -> Void in
            let currentTime  = Int64(time.value) / Int64(time.timescale)
            self.controlView.updateCurrentTime(currentTime)
            if currentTime == Int64(self.currentAudio.duration) {
                self.updatePlayer(.Next)
            }
        }
    }
    
    private func killTimeObserver() {
        if let observer = timeObserber {
            player.removeTimeObserver(observer)
        }
    }
    
    private func playAudioFromIndex(index: Int) {
        killTimeObserver()
        currentAudio = audios[index]
        setNowPlayingInfo()
        let playerItem = AVPlayerItem(URL: NSURL(string: currentAudio.url)!)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        addTimeObeserver()
        controlView.updateInfo(titile: currentAudio.title, artist: currentAudio.artist, duration: currentAudio.duration)
        controlView.updatePlayButton(.Play)
        if currentSection == 1 && index >= audios.count - 2{
            searchForAudios()
        }
    }
    
    private func updatePlayer(action: UpdateAction) {
        switch action {
        case .Play:
            if player == nil {
                if audios.count > 0 {
                    playAudioFromIndex(0)
                }
            } else {
                player.play()
                controlView.updatePlayButton(.Play)
            }
        case .Pause:
            if player != nil {
                player.pause()
                controlView.updatePlayButton(.Pause)
            }
        case .Next:
            if audios.count > 0 {
                guard let audio = currentAudio else {
                    playAudioFromIndex(0)
                    return
                }
                if let currentIndex = audios.indexOf(audio) {
                    if currentIndex + 1 <= audios.count - 1 {
                        playAudioFromIndex(currentIndex + 1)
                    }
                }
            }
        case .Last:
            if audios.count > 0 {
                guard let audio = currentAudio else {
                    return
                }
                if let currentIndex = audios.indexOf(audio) {
                    if currentIndex > 0 {
                        playAudioFromIndex(currentIndex - 1)
                    }
                }
            }
        }
    }

    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchAudious.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return searchAudious.count - 1
        }
        return audios.count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! AudioCell
        var audio: Audio
        if indexPath.section == 0 {
            audio = audios[indexPath.row]
        } else {
            audio = searchAudious[indexPath.row]
            if indexPath.row >= searchAudious.count - 5 {
                searchForAudios()
            }
        }
        cell.updateLabels(title: audio.title, artist: audio.artist, duration: audio.duration)
    
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Search results"
        }
        return nil
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        currentSection = indexPath.section
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        playAudioFromIndex(indexPath.row)
    }
    
    
    //MARK: - Search Methods
    
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
    
    private func searchForAudios() {
        if searchController.active && searchController.searchBar.text != "" {
            RequestManager.sharedManager.searchAudios(searchText: searchController.searchBar.text!, offset: searchAudious.count, count: 30) { (serverData) -> Void in
                for data in serverData {
                    let audio = Audio(serverData: data as! [String: AnyObject])
                    self.searchAudious.append(audio)
                    self.tableView.reloadData()
                }
            }
        } else {
            searchAudious = [Audio]()
            tableView.reloadData()
        }
    }
    
    //MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterAudiosForSearchText(searchController.searchBar.text!)
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchForAudios()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchAudious = [Audio]()
        currentSection = 0
        tableView.reloadData()
    }
    
    //MARK: - Actions

    @IBAction func playAction(sender: UIButton) {
        if sender.titleLabel!.text! == "Play" {
            updatePlayer(.Play)
        } else {
            updatePlayer(.Pause)
        }
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        updatePlayer(.Next)
    }
    
    @IBAction func lastAction(sender: AnyObject) {
        updatePlayer(.Last)
    }
    
    @IBAction func remoteAction(sender: UISlider) {
        updatePlayer(.Pause)
        if player != nil {
            let value = sender.value
            let time = CMTime(value: Int64(value), timescale: 1)
            controlView.updateCurrentTime(Int64(value))
            player.seekToTime(time)
        }
    }
    
    @IBAction func remoteEnded(sender: AnyObject) {
        updatePlayer(.Play)
    }
}
