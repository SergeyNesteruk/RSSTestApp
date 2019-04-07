//
//  RSSFeedDataController.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/6/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser

protocol RSSFeedDataControllerDelegate {
    func feedDidUpdate(controller: RSSFeedDataController, feed: RSSFeed)
}

class RSSFeedDataController {
    var loading = false
    var spinnerPresenter: SpinnerViewPresenter?
    var delegate: RSSFeedDataControllerDelegate?
    var itemsNumber: Int {
        get {
            guard let feed = lastFeed else { return 0 }
            return feed.items.count
        }
    }
    
    private let feedURL: URL
    private var lastFeed: RSSFeed? {
        didSet {
            if let feed = lastFeed {
                delegate?.feedDidUpdate(controller: self, feed: feed)
            }
        }
    }
    private var timerActive = false // Indicates if the timer resumed
    private var updateTimer: DispatchSourceTimer?
    static private let dataFetchQueue = DispatchQueue(label: "com.NLab.RSSFeedTestApp.DataFetchQueue", qos: .default, attributes: .concurrent)
    static private let fetchIntervalSeconds = 5
    
    required init(url: URL) {
        feedURL = url
    }
    
    private func getFeed() {
        guard !loading else { return }
        loading = true
        spinnerPresenter?.showNetworkActivity()
        Alamofire.request(feedURL).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.result.value {
                self.lastFeed = feed
            }
            self.loading = false
            self.spinnerPresenter?.hideNetworkActivity()
        }
    }
    
    func item(index: Int) -> RSSItem? {
        guard let feed = lastFeed, feed.items.count > index else { return nil }
        return feed.items[index]
    }
    
    
    /// Must be called from main thread
    func resumePeriodicFeedUpdate() {
        if updateTimer == nil {
            updateTimer = DispatchSource.makeTimerSource(flags: [], queue: RSSFeedDataController.dataFetchQueue)
            updateTimer?.schedule(wallDeadline: .now(), repeating: .seconds(RSSFeedDataController.fetchIntervalSeconds))
            updateTimer?.setEventHandler(handler: {
                self.getFeed()
            })
        }
        if (timerActive) { return }
        timerActive = true
        updateTimer?.resume()
    }
    
    /// Must be called from main thread
    func suspendPeriodicFeedUpdate() {
        guard timerActive else { return }
        timerActive = false
        updateTimer?.suspend()
    }
}
