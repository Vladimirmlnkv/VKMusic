//
//  AccessToken.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation

struct AccessToken {
    let token: String
    let expiresIn: NSDate
    let userID: String
    
    init(components: [String]) {
        token = components[0].componentsSeparatedByString("=")[1]
        let expiresSec = Int(components[1].componentsSeparatedByString("=")[1])!
        userID = components[2].componentsSeparatedByString("=")[1]
        let timeInterval = NSTimeInterval(expiresSec)
        expiresIn = NSDate(timeIntervalSinceNow: timeInterval)
    }
    
    init(token: String, userID: String, expiresIn: NSDate) {
        self.token = token
        self.userID = userID
        self.expiresIn = expiresIn
    }
}