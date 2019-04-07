//
//  RSSFeedsViewController.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/4/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class RSSFeedsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RSSFeedDataControllerDelegate, CombinedDataControllerDelegate {
    enum SegmentSelection: Int {
        case businessNews = 0
        case ee
    }
        
    private var businessNewsDataController: RSSFeedDataController!
    private var environmentDataController: RSSFeedDataController!
    private var entertainmentDataController: RSSFeedDataController!
    private var combinedDataController: CombinedDataController!
    private let showDetailsSegue = "OpenRSSItemDetails"
    private var selectedSegment: SegmentSelection {
        get {
            return SegmentSelection(rawValue: segmentedControl.selectedSegmentIndex)!
        }
    }
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataControllers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        suspendDataFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reconfigureDataFetching()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenRSSItemDetails", let feedItem = sender as? RSSItem, let vc = segue.destination as? RSSItemDetailsViewController {
            vc.rssItem = feedItem
        }
    }
    
    // MARK: UITableViewDataSource and UITableViewDeleagate methods
    func numberOfSections(in tableView: UITableView) -> Int {
        switch selectedSegment {
        case .businessNews:
            return 1
            
        default:
            return EEFeeds.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedSegment {
        case .businessNews:
            return businessNewsDataController.itemsNumber
            
        default:
            switch feedSection(section: section) {
            case .entertainment:
                return combinedDataController.entertainmentRSSItems.count
                
            case .environment:
                return combinedDataController.environmentRSSItems.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedItemTableViewCell.reuseKey, for: indexPath)
        if let feedCell = cell as? FeedItemTableViewCell {
            switch selectedSegment {
            case .businessNews:
                if let feedItem = businessNewsDataController.item(index: indexPath.row) {
                    feedCell.configure(title: feedItem.title, section: EEFeeds(rawValue: indexPath.section)!)
                }
                
            case .ee:
                switch EEFeeds(rawValue: indexPath.section)! {
                case .entertainment:
                    let rssItem = combinedDataController.entertainmentRSSItems[indexPath.row]
                    feedCell.configure(title: rssItem.title, section: EEFeeds(rawValue: indexPath.section)!)
                    
                case .environment:
                    let rssItem = combinedDataController.environmentRSSItems[indexPath.row]
                    feedCell.configure(title: rssItem.title, section: EEFeeds(rawValue: indexPath.section)!)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch selectedSegment {
        case .businessNews:
            return nil
        default:
            return titleForEESection(section: section)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item: RSSItem?
        switch selectedSegment {
        case .businessNews:
            item = businessNewsDataController.item(index: indexPath.row)
        default:
            switch feedSection(section: indexPath.section) {
            case .entertainment:
                item = combinedDataController.entertainmentRSSItems[indexPath.row]
                
            case .environment:
                item = combinedDataController.environmentRSSItems[indexPath.row]
            }
        }
        if let item = item {
            performSegue(withIdentifier: showDetailsSegue, sender: item)
            NotificationCenter.default.post(name: FeedNotifications.feedSelected.name, object: item.title)
        }
    }
    
    // MARK: RSSFeedDataControllerDelegate methods
    func feedDidUpdate(controller: RSSFeedDataController, feed: RSSFeed) {
        // In current implementation direct updates from RSSFeedDataController are only happening for
        // businessNewsDataController
        if controller === businessNewsDataController {
            itemsTableView.reloadData()
        }
    }
    
    // MARK: CombinedDataControllerDelegate methods
    func controllerDidUpdateFeed(controller: RSSFeedDataController) {
        if controller === entertainmentDataController {
            let sectionsToReload = IndexSet(arrayLiteral: EEFeeds.entertainment.rawValue)
            DispatchQueue.main.async {
                self.itemsTableView.reloadSections(sectionsToReload, with: .automatic)
            }
        }
        else if controller === environmentDataController {
            let sectionsToReload = IndexSet(arrayLiteral: EEFeeds.environment.rawValue)
            DispatchQueue.main.async {
                self.itemsTableView.reloadSections(sectionsToReload, with: .automatic)
            }
        }
    }
    func allDataDidUpdate() {
        DispatchQueue.main.async {
            self.itemsTableView.reloadData()
        }
    }
    
    // MARK: IBActions
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        suspendDataFetch()
      
        // Scroll to top on segment change
        self.itemsTableView.scrollToTop(animated: false)
        itemsTableView.reloadData()
        reconfigureDataFetching()
    }
    
    // MARK: Private methods    
    private func reconfigureDataFetching() {
        switch selectedSegment {
        case .businessNews:
            businessNewsDataController.resumePeriodicFeedUpdate()
            environmentDataController.suspendPeriodicFeedUpdate()
            entertainmentDataController.suspendPeriodicFeedUpdate()
            
        default:
            environmentDataController.resumePeriodicFeedUpdate()
            entertainmentDataController.resumePeriodicFeedUpdate()
            businessNewsDataController.suspendPeriodicFeedUpdate()
        }
    }
    
    private func setupDataControllers() {
        businessNewsDataController = DataControllersFactory.build(controllerType: .businessNews)
        environmentDataController = DataControllersFactory.build(controllerType: .environment)
        entertainmentDataController = DataControllersFactory.build(controllerType: .entertainment)
        businessNewsDataController.delegate = self
        combinedDataController = CombinedDataController(entertainmentController: entertainmentDataController, environmentController: environmentDataController)
        combinedDataController.delegate = self
    }
    
    private func suspendDataFetch() {
        businessNewsDataController.suspendPeriodicFeedUpdate()
        environmentDataController.suspendPeriodicFeedUpdate()
        entertainmentDataController.suspendPeriodicFeedUpdate()
    }
    
    private func titleForEESection(section: Int) -> String {
        switch feedSection(section: section) {
        case .entertainment:
            return "Entertainment"
            
        case .environment:
            return "Environment"
        }
    }
    
    private func feedSection(section: Int) -> EEFeeds {
        return EEFeeds(rawValue: section)!
    }
}
