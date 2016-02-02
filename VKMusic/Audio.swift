//
//  Audio.swift
//  VKMusic
//
//  Created by Владимир Мельников on 26.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation

func ==(lhs: Audio, rhs: Audio) -> Bool {
    return lhs.url == rhs.url
}

struct Audio: Equatable {
    
    var id: Int
    let url: String
    let title: String
    let artist: String
    let duration: Int
    var ownerID: Int
    
    init(serverData: [String: AnyObject]) {
        url = "\(serverData["url"]!)"
        title = "\(serverData["title"]!)"
        artist = "\(serverData["artist"]!)"
        duration = serverData["duration"] as! Int
        id = serverData["aid"] as! Int
        ownerID = serverData["owner_id"] as! Int
    }
}