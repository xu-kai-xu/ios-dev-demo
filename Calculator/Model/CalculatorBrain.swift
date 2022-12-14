//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael Jordan on 3/16/17. Copy from Neo, iso app dev video by xu.
//  Copyright © 2017 MichaelJordan. All rights reserved.
//

import Foundation

func randomDouble() -> Double {
    return Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
}

struct CalculatorBrain {
    
    var numberFormatter: NumberFormatter?
    
    private var accumulator: (value: Double?, description: String) = (nil, "") {
        didSet {
            print(accumulator.description)
        }
    }
    
    private func formatValue(_ number: Double) -> String {
        if let formatter = numberFormatter {
            return formatter.string(from: NSNumber(value: number))!
        }
        else {
            return "\(number)"
        }
    }
    
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π"   : Operation.constant(Double.pi),
        "e"   : Operation.constant(M_E),
        "RND" : Operation.nullaryOperation(randomDouble),
        "√"   : Operation.unaryOperation(sqrt),
        "∛"   : Operation.unaryOperation({pow($0, 1.0/3.0)}),     // Cubed root function
        "x²"  : Operation.unaryOperation({$0 * $0}),
        "x³"  : Operation.unaryOperation({$0 * $0 * $0}),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "log" : Operation.unaryOperation(log10),
        "ln"  : Operation.unaryOperation(log),
        "±"   : Operation.unaryOperation({-$0}),
        "%"   : Operation.unaryOperation({$0 / 100}),
        "✕"   : Operation.binaryOperation({$0 * $1}),
        "÷"   : Operation.binaryOperation({$0 / $1}),
        "+"   : Operation.binaryOperation({$0 + $1}),
        "-"   : Operation.binaryOperation({$0 - $1}),
        "="   : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value):
                    accumulator = (value, "\(symbol)")
                case .nullaryOperation(let function):
                    let result = function()
                    accumulator = (result, formatValue(result))
                case .unaryOperation(let function):
                    if accumulator.value != nil {
                        let description : String
                        if resultIsPending {
                            // Unary operations execute on the current operand. If there
                            // is a pending operation the description of the pending
                            // operation needs to be included in the description. Include the
                            // pending operation description before the unary operation
                            // description and clear the pending operation description since
                            // it has been accounted for here.
                            //
                            description = pendingBinaryOperation!.description + "\(symbol)(\(accumulator.description))"
                            pendingBinaryOperation!.description = ""
                        }
                        else {
                            description = "\(symbol)(\(accumulator.description))"
                        }
                        accumulator = (function(accumulator.value!), description)
                    }
                case .binaryOperation(let function):
                    performPendingBinaryOperation()
                    if accumulator.value != nil {
                        pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                                        firstOperand: accumulator.value!,
                                                                        description: "\(accumulator.description) \(symbol) ")
                        accumulator = (nil, pendingBinaryOperation!.description)
                    }
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            accumulator = (pendingBinaryOperation!.perform(with: accumulator.value!),
                           pendingBinaryOperation!.description + "\(accumulator.description)")
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var description: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, formatValue(operand))
    }
    
    var result: (value: Double?, description: String) {
        get {
            // Strip off trailing white space from the accumulator description
            //
            let description = accumulator.description.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
            return (value: accumulator.value, description)
        }
    }
    
    mutating func reset() {
        accumulator = (nil, "")
        pendingBinaryOperation = nil
    }
}

