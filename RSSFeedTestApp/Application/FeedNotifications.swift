//
//  FeedNotification.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/7/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

enum FeedNotifications: String {
    case feedSelected
    
    var name: Notification.Name {
        get {
            return Notification.Name(rawValue)
        }
    }
}
