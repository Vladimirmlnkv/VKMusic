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

    func updateLabels(title title: String, artist: String, duration: Int) {
        titleLabel.text? = "\(artist) - \(title)"
        durationLabel.text? = durationString(duration)
    }
    
    private func durationString(duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration - minutes * 60
        if seconds < 10 {
            return "\(minutes):0\(seconds)"
        }
        return "\(minutes):\(seconds)"
    }
}
