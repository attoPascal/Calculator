//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Pascal Attwenger on 28/01/15.
//  Copyright (c) 2015 Pascal Attwenger. All rights reserved.
//

import Foundation

enum CalculatorError: ErrorType {
    case UnknownOperation
    case UnknownVariable
    case MissingArgument
    case DivisionByZero
    case NegativeRoot
}

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case Constant(symbol: String, value: Double)
        case UnaryOperation(symbol: String, operation: Double -> Double, errorTest: (Double -> CalculatorError?)?)
        case BinaryOperation(symbol: String, operation: (Double, Double) -> Double, precedence: Int, errorTest: ((Double, Double) -> CalculatorError?)?)
        
        var description: String {
            switch self {
            case .Operand(let value):
                return value.stringUsingSignificantDigits
            case .UnaryOperation(let symbol, _, _):
                return symbol
            case .BinaryOperation(let symbol, _, _, _):
                return symbol
            case .Constant(let symbol, _):
                return symbol
            case .Variable(let symbol):
                return symbol
            }
        }
        
        var precedence: Int {
            switch self {
            case .BinaryOperation(_, _, let precedence, _):
                return precedence
            default:
                return Int.max
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    
    var variableValues = [String: Double]()
    
    var description: String {
        var parsing = parseDescription(opStack)
        guard var result = parsing.result else { return " " }
        
        while !parsing.remainingOps.isEmpty {
            parsing = parseDescription(parsing.remainingOps)
            result = "\(parsing.result!),\(result)"
        }
        
        return result
    }
    
    var history: [String] {
        return opStack.map { String($0) }
    }
    
    var calculationComplete: Bool {
        do {
            let (_, remainingOps) = try evaluate(opStack)
            return remainingOps.count == 0
        }
        catch { return false }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return history
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = Double(opSymbol) {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation(symbol: "×", operation: { $1 * $0 }, precedence: 2, errorTest: nil))
        learnOp(Op.BinaryOperation(symbol: "÷", operation: { $1 / $0 }, precedence: 2, errorTest: { divisor, _ in (divisor != 0.0) ? nil : CalculatorError.DivisionByZero }))
        learnOp(Op.BinaryOperation(symbol: "+", operation: { $1 + $0 }, precedence: 1, errorTest: nil))
        learnOp(Op.BinaryOperation(symbol: "−", operation: { $1 - $0 }, precedence: 1, errorTest: nil))
        learnOp(Op.UnaryOperation(symbol: "√",   operation: sqrt, errorTest: { ($0 >= 0.0) ? nil : CalculatorError.NegativeRoot }))
        learnOp(Op.UnaryOperation(symbol: "sin", operation: sin,  errorTest: nil))
        learnOp(Op.UnaryOperation(symbol: "cos", operation: cos,  errorTest: nil))
        learnOp(Op.UnaryOperation(symbol: "±",   operation: -,    errorTest: nil))
        learnOp(Op.Constant(symbol: "π", value: M_PI))
    }
    
    func pushOperand(value: Double) {
        opStack.append(Op.Operand(value))
    }
    
    func pushOperand(symbol: String) {
        opStack.append(Op.Variable(symbol))
    }
    
    func performOperation(symbol: String) throws {
        guard let operation = knownOps[symbol] else { throw CalculatorError.UnknownOperation }
        opStack.append(operation)
    }
    
    func undoLastOp() {
        if opStack.count > 0 {
            opStack.removeLast()
        }
    }
    
    func evaluate() throws -> Double {
        return try evaluate(opStack).result
    }
    
    private func evaluate(ops: [Op]) throws -> (result: Double, remainingOps: [Op]) {
        guard !ops.isEmpty else { throw CalculatorError.MissingArgument }
        
        var remainingOps = ops
        let op = remainingOps.removeLast()
        
        switch op {
        case .Operand(let value):
            return (value, remainingOps)
        case .UnaryOperation(_, let operation, let validate):
            let (operand, remainder) = try evaluate(remainingOps)
            if let error = validate?(operand) { throw error }
            return (operation(operand), remainder)

        case .BinaryOperation(_, let operation, _, let validate):
            let (operand1, op1Remainder) = try evaluate(remainingOps)
            let (operand2, op2Remainder) = try evaluate(op1Remainder)
            if let error = validate?(operand1, operand2) { throw error }
            return (operation(operand1, operand2), op2Remainder)

        case .Constant(_, let value):
            return (value, remainingOps)
        case .Variable(let symbol):
            guard let value = variableValues[symbol]  else { throw CalculatorError.UnknownVariable }
            return (value, remainingOps)
        }
    }
    
    private func parseDescription(ops: [Op]) -> (result: String?, remainingOps: [Op], precedence: Int) {
        guard !ops.isEmpty else { return (nil, [], 0) }
        
        var remainingOps = ops
        let op = remainingOps.removeLast()
        
        switch op {
        case .Operand, .Constant, .Variable:
            return (op.description, remainingOps, op.precedence)
        case .UnaryOperation:
            let opParse = parseDescription(remainingOps)
            if let operand = opParse.result {
                return ("\(op)(\(operand))", opParse.remainingOps, op.precedence)
            } else {
                return ("\(op)(?)", opParse.remainingOps, op.precedence)
            }
        case .BinaryOperation:
            let op1Parse = parseDescription(remainingOps)
            guard var operand1 = op1Parse.result else { return ("?\(op)?", op1Parse.remainingOps, op.precedence) }
            operand1 = (op1Parse.precedence < op.precedence) ? "(\(operand1))" : operand1
            
            let op2Parse = parseDescription(op1Parse.remainingOps)
            guard var operand2 = op2Parse.result else { return ("?\(op)\(operand1)", op2Parse.remainingOps, op.precedence) }
            operand2 = (op2Parse.precedence < op.precedence) ? "(\(operand2))" : operand2
            
            return ("\(operand2)\(op)\(operand1)", op2Parse.remainingOps, op.precedence)
        }
    }
}