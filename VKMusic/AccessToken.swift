//
//  AccessToken.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation

class AccessToken {
    let token: String
    let expiresIn: String
    let userID: String
    
    init(components: [String]) {
        token = components[0].componentsSeparatedByString("=")[1]
        expiresIn = components[1].componentsSeparatedByString("=")[1]
        userID = components[2].componentsSeparatedByString("=")[1]
    }
}