//
//  StatsViewController.swift
//  Calculator
//
//  Created by Pascal Attwenger on 31/07/15.
//  Copyright © 2015 Pascal Attwenger. All rights reserved.
//

import UIKit

class StatsViewController: UITableViewController {
    
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    
    var minValue: CGFloat?
    var maxValue: CGFloat?
    
    override func viewWillAppear(animated: Bool) {
        minLabel.text = minValue?.description
        maxLabel.text = maxValue?.description
    }
    
}
