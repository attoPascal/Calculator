//
//  GraphViewController.swift
//  Calculator
//
//  Created by Pascal Attwenger on 27/07/15.
//  Copyright © 2015 Pascal Attwenger. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }
    
    var program: AnyObject?
    
    private var calculator = CalculatorBrain()
    private var variable = "x"
    
    override func viewDidLoad() {
        if let graphProgram = program {
            calculator.program = graphProgram
        }
    }
    
    func valueFor(x x: CGFloat) -> CGFloat? {
        do {
            calculator.variableValues[variable] = Double(x)
            return CGFloat(try calculator.evaluate())
        } catch {
            return nil
        }
    }
    
}
