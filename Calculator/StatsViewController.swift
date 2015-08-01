//
//  StatsViewController.swift
//  Calculator
//
//  Created by Pascal Attwenger on 31/07/15.
//  Copyright © 2015 Pascal Attwenger. All rights reserved.
//

import UIKit

class StatsViewController: UITableViewController {
    
    @IBOutlet weak var minCell: UITableViewCell!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    var minValue: CGFloat?
    var maxValue: CGFloat?
    
    override func viewWillAppear(animated: Bool) {
        minLabel.text = minValue?.description
        maxLabel.text = maxValue?.description
    }
    
    override var preferredContentSize: CGSize {
        get {
            if let pvc = presentingViewController {
                let popoverSize = pvc.view.bounds.size
                let width = minCell.sizeThatFits(popoverSize).width
                let height = tableView.sizeThatFits(popoverSize).height
                return CGSize(width: width, height: height)
            } else {
                return super.preferredContentSize
            }
        }
        set {
            super.preferredContentSize = newValue
        }
    }
}
