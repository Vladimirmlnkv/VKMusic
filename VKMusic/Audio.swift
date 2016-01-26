//
//  Audio.swift
//  VKMusic
//
//  Created by Владимир Мельников on 26.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation

struct Audio {
    
    let url: String
    let title: String
    let artist: String
    let duration: Int
    
    init(serverData: [String: AnyObject]) {
        url = "\(serverData["url"]!)"
        title = "\(serverData["title"]!)"
        artist = "\(serverData["artist"]!)"
        duration = serverData["duration"] as! Int
    }
    
}