//
//  CombinedDataController.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/7/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit
import AlamofireRSSParser

protocol CombinedDataControllerDelegate {
    func controllerDidUpdateFeed(controller: RSSFeedDataController)
    func allDataDidUpdate()
}

enum EEFeeds: Int, CaseIterable {
    case entertainment
    case environment
}

class CombinedDataController: RSSFeedDataControllerDelegate {
    private (set) var entertainmentRSSItems: [RSSItem] = []
    private (set) var environmentRSSItems: [RSSItem] = []
    var delegate: CombinedDataControllerDelegate?
    
    private let entertainmentDataController: RSSFeedDataController
    private let environmentDataController: RSSFeedDataController
    private let updateQueue = DispatchQueue(label: "com.NLab.RSSFeedTestApp.CombinedDataUpdateQueue", qos: .default)
    private var updatesDictionary = Dictionary<EEFeeds, RSSFeed>()
    private var delegateUpdateClosure: (() -> Void)?
    private let updateDelaySeconds = 0.5
    
    init(entertainmentController: RSSFeedDataController, environmentController: RSSFeedDataController) {
        entertainmentDataController = entertainmentController
        environmentDataController = environmentController
        entertainmentDataController.delegate = self
        environmentDataController.delegate = self
    }
    
    // MARK: RSSFeedDataControllerDelegate methods
    func feedDidUpdate(controller: RSSFeedDataController, feed: RSSFeed) {
        updateQueue.sync {
            // Configure deferred changes
            if (controller === entertainmentDataController) {
                updatesDictionary[.entertainment] = feed
            }
            else if (controller === environmentDataController) {
                updatesDictionary[.environment] = feed
            }
            
            // Plan update if needed
            guard delegateUpdateClosure == nil else {
                return // Update is already planned so no need to do anything
            }
            
            // Update not planned - create planned update now
            delegateUpdateClosure = {
                guard let firstKey = self.updatesDictionary.keys.first else {
                    return // Happened to have no items for the update
                }
                for key in self.updatesDictionary.keys {
                    switch key {
                    case .entertainment:
                        self.entertainmentRSSItems = self.updatesDictionary[key]!.items
                        
                    case .environment:
                        self.environmentRSSItems = self.updatesDictionary[key]!.items
                    }
                }
                if self.updatesDictionary.keys.count > 1 {
                    // Complex update we reload all data
                    self.delegate?.allDataDidUpdate()
                }
                else {
                    // Update of only 1 contoroller
                    switch firstKey {
                    case .entertainment:
                        self.delegate?.controllerDidUpdateFeed(controller: self.entertainmentDataController)
                    case .environment:
                        self.delegate?.controllerDidUpdateFeed(controller: self.environmentDataController)
                    }
                }
                self.delegateUpdateClosure = nil
            }
            
            // Schedule planned update (we can safely unwrap delegateUpdateClosure becuase it is just created)
            updateQueue.asyncAfter(deadline: .now() + updateDelaySeconds, execute: delegateUpdateClosure!)
        }
    }
}
