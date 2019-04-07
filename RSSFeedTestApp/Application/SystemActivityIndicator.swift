//
//  SystemActivityIndicator.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/6/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

class SystemActivityIndicator {
    static private var indicatorCount = 0 {
        didSet {
            if indicatorCount <= 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
    
    static func showNetworkActivity() {
        DispatchQueue.main.async {
            indicatorCount += 1
        }
    }
    
    static func hideNetworkActivity() {
        DispatchQueue.main.async {
            indicatorCount -= 1
        }
    }
}
