//
//  SwiftStrCalc.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 11.07.2024.
//

import Foundation

open class Calc {

    private let expEvaluator: ExpressionEvaluator

    let library = Library()

    public init() {
        self.expEvaluator = ExpressionEvaluator(library: library)
    }

    public func evaluate(expression: String) throws {
        try expEvaluator.evaluate(expression)
    }
}

// MARK: - Types
public extension Calc {

    enum Value {
        case realNumber(Double)
        case boolean(Bool)
    }
}
