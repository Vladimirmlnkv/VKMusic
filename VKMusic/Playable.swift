//
//  Playable.swift
//  VKMusic
//
//  Created by Владимир Мельников on 18.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation

protocol Playable: Equatable {
    var url: String { get }
    var title: String { get }
    var artist: String { get }
    var duration: Int { get }
}