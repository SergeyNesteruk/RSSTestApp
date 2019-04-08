//
//  FeedItemTableViewCell.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/6/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

class FeedItemTableViewCell: UITableViewCell {
    static let reuseKey = "FeedItemTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(title: String?, section: EEFeeds?) {
        titleLabel.text = title
        if let section = section {
            switch section {
            case .entertainment:
                backgroundColor = UIColor.red.withAlphaComponent(0.1)
                
            case .environment:
                backgroundColor = UIColor.green.withAlphaComponent(0.1)
            }
        }
        else {
            backgroundColor = UIColor.white
        }
    }
}
