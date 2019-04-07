//
//  UITableView+SupportMethods.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/7/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

extension UITableView {
    func scrollToTop(animated: Bool) {
        var zeroOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
        if #available(iOS 11.0, *) {
            zeroOffset = CGPoint(x: -adjustedContentInset.left, y:-adjustedContentInset.top)
        }
        
        setContentOffset(zeroOffset, animated: false)
        layoutIfNeeded()
    }
}
