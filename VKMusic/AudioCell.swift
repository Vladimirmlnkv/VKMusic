//
//  AudioCell.swift
//  VKMusic
//
//  Created by Владимир Мельников on 26.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class AudioCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateLabels(title title: String, artist: String, duration: Int) {
        titleLabel.text? = "\(artist) \(title)"
        durationLabel.text? = "\(duration)"
    }
}
