//
//  SwiftStrCalc.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 11.07.2024.
//

import Foundation

open class Calc {

    private let expParser: ExpressionParser

    let library: Library

    public init() {
        let calcLibrary = Library()

        try? calcLibrary.add(function: Function(name: "cos"))
        try? calcLibrary.add(function: Function(name: "sin"))
        try? calcLibrary.add(function: Function(name: "tg"))

        self.library = calcLibrary
        self.expParser = ExpressionParser(library: calcLibrary)
    }

    public func calculate(_ exp: String) throws {
        let lexemes = try expParser.parse(exp)

        print("Index\tValue\t\tType")
        print("------------------------")
        lexemes.forEach {
            print("\($0.startIndexInExp)\t\t\($0.value)\t\t\t\($0.type)")
        }
    }
}
