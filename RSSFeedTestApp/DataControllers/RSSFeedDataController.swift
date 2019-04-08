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
                self.mergeFreshFeed(feed: feed)
            }
            self.loading = false
            self.spinnerPresenter?.hideNetworkActivity()
        }
    }
    
    private func mergeFreshFeed(feed: RSSFeed) {
        guard let lastFeed = lastFeed else {
            self.lastFeed = feed
            print("Initial feed assignment")
            return // In case there was no last feed before we do an update with a new feed
        }
        
        if lastFeed.items.count != feed.items.count {
            // A simple merge mechanism updates feed if the number of items is different
            self.lastFeed = feed
            print("Feed is updated by number of elements")
            return
        }
        
        let lastFeedIDs = lastFeed.items.map { (rssItem) -> String in
            if let link = rssItem.link, let idString = URL(string: link)?.lastPathComponent {
                return idString
            }
            return rssItem.title ?? rssItem.description
        }
        let newFeedIDs = feed.items.map { (rssItem) -> String in
            if let link = rssItem.link, let idString = URL(string: link)?.lastPathComponent {
                return idString
            }
            return rssItem.title ?? rssItem.description
        }
        let difference = newFeedIDs.filter { !lastFeedIDs.contains($0) }
        
        // Only assign new feed if the difference is non-zero
        if difference.count > 0 {
            self.lastFeed = feed
            print("Feed is updated")
        }
        print("Feeds are identical")
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
