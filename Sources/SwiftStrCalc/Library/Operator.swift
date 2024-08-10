//
//  Operator.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 09.08.2024.
//

import Foundation

enum OperatorType {
    case binary
    case unaryLeft
    case unaryRight
}

enum OperatorPriority: UInt {
    case lowest = 0     // =
    case evenLower = 1  // &&, ||
    case lower = 2      // ==, <, <=, >, >=
    case low = 3        // +, -
    case medium = 4     // *, /
    case high = 5       // ^
    case higher = 6     // unary
    case highest = 7    // ()
}

protocol Operator {

    var name: String { get }
    var type: OperatorType { get }
    var priority: OperatorPriority { get }

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value
}

// MARK: - Private
private extension Operator {

    func checkNumberBinary(_ args: [Calc.Value], _ lexeme: ExpressionParser.Lexeme) throws -> (leftArg: Double, rightArg: Double) {
        if args.count >= 2 {
            if case .realNumber(let left) = args[0], case .realNumber(let right) = args[1] {
                return (left, right)
            }
        }
        throw CalcError.invalidOperatorArgument(operator: lexeme.value, index: lexeme.startIndexInExp)
    }

    func checkNumberUnary(_ args: [Calc.Value], _ lexeme: ExpressionParser.Lexeme) throws -> Double {
        if args.count >= 1 {
            if case .realNumber(let arg) = args[0] {
                return arg
            }
        }
        throw CalcError.invalidOperatorArgument(operator: lexeme.value, index: lexeme.startIndexInExp)
    }

    func checkBoolBinary(_ args: [Calc.Value], _ lexeme: ExpressionParser.Lexeme) throws -> (leftArg: Bool, rightArg: Bool) {
        if args.count >= 2 {
            if case .boolean(let left) = args[0], case .boolean(let right) = args[1] {
                return (left, right)
            }
        }
        throw CalcError.invalidOperatorArgument(operator: lexeme.value, index: lexeme.startIndexInExp)
    }

    func checkBoolUnary(_ args: [Calc.Value], _ lexeme: ExpressionParser.Lexeme) throws -> Bool {
        if args.count >= 1 {
            if case .boolean(let arg) = args[0] {
                return arg
            }
        }
        throw CalcError.invalidOperatorArgument(operator: lexeme.value, index: lexeme.startIndexInExp)
    }
}

// MARK: - Default operators
struct Addition: Operator {

    let name: String = "+"
    let type: OperatorType = .binary
    let priority: OperatorPriority = .low

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value {
        let operands = try checkNumberBinary(args, lexeme)

        return .realNumber(operands.leftArg + operands.rightArg)
    }
}

struct Subtraction: Operator {

    let name: String = "-"
    let type: OperatorType = .binary
    let priority: OperatorPriority = .low

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value {
        let operands = try checkNumberBinary(args, lexeme)

        return .realNumber(operands.leftArg - operands.rightArg)
    }
}

struct Multiplication: Operator {

    let name: String = "*"
    let type: OperatorType = .binary
    let priority: OperatorPriority = .medium

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value {
        let operands = try checkNumberBinary(args, lexeme)

        return .realNumber(operands.leftArg * operands.rightArg)
    }
}

struct Division: Operator {

    let name: String = "/"
    let type: OperatorType = .binary
    let priority: OperatorPriority = .medium

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value {
        let operands = try checkNumberBinary(args, lexeme)
        let result = operands.leftArg / operands.rightArg

        if result == .infinity {
            throw CalcError.divisionByZero(operator: lexeme.value, index: lexeme.startIndexInExp)
        }
        return .realNumber(result)
    }
}

struct UnaryPlus: Operator {

    let name: String = "+"
    let type: OperatorType = .unaryLeft
    let priority: OperatorPriority = .higher

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value {
        let operand = try checkNumberUnary(args, lexeme)

        return .realNumber(operand)
    }
}

struct UnaryMinus: Operator {

    let name: String = "-"
    let type: OperatorType = .unaryLeft
    let priority: OperatorPriority = .higher

    func getValue(at args: [Calc.Value], lexeme: ExpressionParser.Lexeme) throws -> Calc.Value {
        let operand = try checkNumberUnary(args, lexeme)

        return .realNumber(-operand)
    }
}
