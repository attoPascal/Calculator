//
//  GraphViewController.swift
//  Calculator
//
//  Created by Pascal Attwenger on 27/07/15.
//  Copyright © 2015 Pascal Attwenger. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource, UIGestureRecognizerDelegate {
    
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func pan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(graphView)
        gesture.setTranslation(CGPointZero, inView: graphView)
        graphView.moveBy(translation)
    }

    @IBAction func doubleTap(gesture: UITapGestureRecognizer) {
        graphView.centerAt(gesture.locationInView(graphView))
    }
    
    @IBAction func pinch(gesture: UIPinchGestureRecognizer) {
        graphView.zoom(gesture.scale, onPoint: gesture.locationInView(graphView))
        gesture.scale = 1
    }
    
    @IBAction func twoFingerDoubleTap(gesture: UITapGestureRecognizer) {
        graphView.setDefaults()
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
