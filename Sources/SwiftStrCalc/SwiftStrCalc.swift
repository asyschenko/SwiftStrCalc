//
//  SwiftStrCalc.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 11.07.2024.
//

import Foundation

open class Calc {

    private let expEvaluator: ExpressionEvaluator

    let library: Library

    public init() {
        let calcLibrary = Library()

        try? calcLibrary.add(function: Function(name: "cos"))
        try? calcLibrary.add(function: Function(name: "sin"))
        try? calcLibrary.add(function: Function(name: "tg"))

        self.library = calcLibrary
        self.expEvaluator = ExpressionEvaluator(library: calcLibrary)
    }

    public func evaluate(expression: String) throws {
        try expEvaluator.evaluate(expression)
    }
}
