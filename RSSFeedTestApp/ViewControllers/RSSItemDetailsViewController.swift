//
//  RSSItemDetailsViewController.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/7/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit
import AlamofireRSSParser

class RSSItemDetailsViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var rssItem: RSSItem!
    
    private let dateFormatter: DateFormatter
    
    required init?(coder aDecoder: NSCoder) {
        dateFormatter = DateFormatter()
        super.init(coder: aDecoder)
        
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ"
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = rssItem.title
        if let date = rssItem.pubDate {
            dateLabel.text = dateFormatter.string(from: date)
        }
        else {
            dateLabel.text = "--"
        }
        if let htmlString = rssItem.itemDescription, let htmlData = htmlString.data(using: .unicode) {
            textView.attributedText = try? NSAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }
    }
    
    @IBAction func titleSelected(_ sender: UITapGestureRecognizer) {
        if let urlString = rssItem.link, let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
