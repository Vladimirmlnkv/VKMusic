//
//  DownloadManager.swift
//  VKMusic
//
//  Created by Владимир Мельников on 17.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class DownloadManager {
    
    static let sharedManager = DownloadManager()
    
    private var downloadInProgress = false
    
    private func createSavedAudio(audio: Audio, url: NSURL) {
        let savedAudio = SavedAudio()
        savedAudio.title = audio.title
        savedAudio.artist = audio.artist
        savedAudio.duration = audio.duration
        savedAudio.url = url.absoluteString
        print(savedAudio.url)
        let realm = try! Realm()
        try! realm.write {
            realm.add(savedAudio)
        }
    }
    
    //MARK: - Public API
    
    func downloadAudio(audio: Audio) {
        Alamofire.download(.GET, audio.url) { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let pathComponent = response.suggestedFilename
            let completeURL = directoryURL.URLByAppendingPathComponent(pathComponent!)
            self.createSavedAudio(audio, url: completeURL)
            
            return completeURL
        }
    }
    
}
