//
//  SpinnerView.swift
//  RSSFeedTestApp
//
//  Created by Sergii Nesteruk on 4/7/19.
//  Copyright © 2019 NLab. All rights reserved.
//

import UIKit

protocol SpinnerViewPresenter {
    func showNetworkActivity()
    func hideNetworkActivity()
}

class SpinnerView: UIActivityIndicatorView, SpinnerViewPresenter {
    private var indicatorCount = 0 {
        didSet {
            if indicatorCount <= 0 {
                stopAnimating()
                isHidden = true
            }
            else {
                startAnimating()
                isHidden = false
            }
        }
    }
    
    func showNetworkActivity() {
        DispatchQueue.main.async {
            self.indicatorCount += 1
        }
    }
    
    func hideNetworkActivity() {
        DispatchQueue.main.async {
            self.indicatorCount -= 1
        }
    }
}
