//
//  ViewController.swift
//  Calculator
//
//  Created by Pascal Attwenger on 27/01/15.
//  Copyright (c) 2015 Pascal Attwenger. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private var brain = CalculatorBrain()
    private var userIsInTheMiddleOfTypingANumber = false
    
    var displayValue: Double? {
        get {
            return Double(display.text ?? "")
        }
        set {
            if let value = newValue {
                display.text = value.stringUsingSignificantDigits
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber && display.text != "0" {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func appendDecimalPoint() {
        if !userIsInTheMiddleOfTypingANumber {
            display.text = "0."
            userIsInTheMiddleOfTypingANumber = true
        } else if display.text!.rangeOfString(".") == nil {
            display.text = display.text! + "."
        }
    }
    
    @IBAction func enter() {
        if let value = displayValue {
            userIsInTheMiddleOfTypingANumber = false
            brain.pushOperand(value)
            updateUI()
        }
    }
    
    @IBAction func clear() {
        brain = CalculatorBrain()
        userIsInTheMiddleOfTypingANumber = false
        updateUI()
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTypingANumber {
            // undo typing: backspace
            if display.text!.characters.count > 1 {
                display.text = String(dropLast(display.text!.characters))
            } else {
                displayValue = 0
                userIsInTheMiddleOfTypingANumber = false
            }
        } else {
            // undo last action
            brain.undoLastOp()
            updateUI()
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        guard let operation = sender.currentTitle else { return }
        
        if userIsInTheMiddleOfTypingANumber { enter() }
        try! brain.performOperation(operation)
        
        updateUI()
    }
    
    @IBAction func switchSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.hasPrefix("-") {
                // remove minus
                display.text = String(dropFirst(display.text!.characters))
            } else {
                // add minus
                display.text = "-" + display.text!
            }
        } else {
            // negate on stack
            operate(sender)
        }
    }
    
    @IBAction func setMemory() {
        if let value = displayValue {
            brain.variableValues["M"] = value
            userIsInTheMiddleOfTypingANumber = false
            updateUI()
        }
    }
    
    @IBAction func pushMemory() {
        if userIsInTheMiddleOfTypingANumber { enter() }
        brain.pushOperand("M")
        updateUI()
    }
    
    private func updateUI() {
        do {
            displayValue = try brain.evaluate()
        } catch {
            displayErrorMessage(error)
        }
        
        // history label: show equals sign only if calculation is complete
        history.text = (brain.calculationComplete) ? String(brain) + " =" : String(brain)
    }
    
    private func displayErrorMessage(error: ErrorType) {
        if let calculatorError = error as? CalculatorError {
            switch calculatorError {
            case .MissingArgument:
                display.text = "missing argument"
            case .UnknownVariable:
                display.text = "unknown variable"
            case .NegativeRoot:
                display.text = "root of negative number"
            case .DivisionByZero:
                display.text = "division by zero"
            case .UnknownOperation:
                display.text = "unknown operation"
            }
        } else {
            display.text = "unknown error"
        }
    }
}

