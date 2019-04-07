//
//  DataControllersFactory.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/6/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

enum DataControllerType {
    case businessNews
    case entertainment
    case environment
}

class DataControllersFactory {
    static private let businessNewsFeedURLString = "http://feeds.reuters.com/reuters/businessNews"
    static private let entertainmentFeedURLString = "http://feeds.reuters.com/reuters/entertainment"
    static private let environmentFeedURLString = "http://feeds.reuters.com/reuters/environment"
    
    static func build(controllerType: DataControllerType) -> RSSFeedDataController {
        return RSSFeedDataController(url: getURL(controllerType: controllerType))
    }
    
    static private func getURL(controllerType: DataControllerType) -> URL {
        switch controllerType {
        case .businessNews:
            return URL(string: businessNewsFeedURLString)!
            
        case .entertainment:
            return URL(string: entertainmentFeedURLString)!
            
        default: // environment
            return URL(string: environmentFeedURLString)!
        }
    }
}
