//
//  ViewController.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/4/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

class GeneralViewController: UIViewController {
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var selectedFeedTitleLabel: UILabel!
    
    private let dateFormatter: DateFormatter
    private let timeFormatter: DateFormatter
    private var updateTimer: DispatchSourceTimer?
    private static let updateIntervalSeconds = 1;
    
    required init?(coder aDecoder: NSCoder) {
        dateFormatter = DateFormatter()
        timeFormatter = DateFormatter()
        super.init(coder: aDecoder)
        
        dateFormatter.dateStyle = .medium
        timeFormatter.timeStyle = .medium
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: FeedNotifications.feedSelected.name, object: nil, queue: nil) { (notification) in
            guard let feedTitle = notification.object as? String else { return }
            DispatchQueue.main.async {
                self.selectedFeedTitleLabel.text = feedTitle
                self.selectedFeedTitleLabel.textColor = UIColor.darkGray
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*  We only care of appearing/disappearing of the screen here.
            Backgrounding/foregrounding is not applicable for current app - without background execution
         */
        switchOnTimeUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        switchOffTimeUpdate()
    }
    
    private func updateCurrentTimeLabel() {
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let timeString = timeFormatter.string(from: date)
        dateTimeLabel.text = "\(dateString) \(timeString)"
    }
    
    private func switchOnTimeUpdate() {
        if updateTimer == nil {
            updateTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            updateTimer?.schedule(wallDeadline: .now(), repeating: .seconds(GeneralViewController.updateIntervalSeconds))
            updateTimer?.setEventHandler(handler: {
                self.updateCurrentTimeLabel()
            })
        }
        updateTimer?.resume()
    }
    
    private func switchOffTimeUpdate() {
        updateTimer?.suspend()
    }
}

