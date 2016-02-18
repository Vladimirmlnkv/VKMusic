//
//  SavedAudio.swift
//  VKMusic
//
//  Created by Владимир Мельников on 17.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import Foundation
import RealmSwift

class SavedAudio: Object {
    dynamic var url         = ""
    dynamic var title       = ""
    dynamic var artist      = ""
    dynamic var duration    = 0
}
