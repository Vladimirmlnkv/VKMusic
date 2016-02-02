//
//  SearchCell.swift
//  VKMusic
//
//  Created by Владимир Мельников on 02.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class SearchCell: AudioCell {


    @IBOutlet weak var durationLabel1: UILabel!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func updateLabels(title title: String, artist: String, duration: Int) {
        titleLabel1.text? = "\(artist) - \(title)"
        durationLabel1.text? = super.durationString(duration)
    }
}
