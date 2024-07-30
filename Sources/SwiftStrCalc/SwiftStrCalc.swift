//
//  SwiftStrCalc.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 11.07.2024.
//

import Foundation

open class Calc {

    private let lexParser: LexemeParser

    let library: Library

    public init() {
        let library = Library()

        try? library.add(function: Function(name: "cos"))
        try? library.add(function: Function(name: "sin"))
        try? library.add(function: Function(name: "tg"))

        self.library = library
        self.lexParser = LexemeParser()
    }

    public func calculate(_ exp: String) throws {
        let lexemes = try lexParser.parse(exp)

        print("Index\tValue\t\tType")
        print("------------------------")
        lexemes.forEach {
            print("\($0.startIndexInExp)\t\t\($0.value)\t\t\t\($0.type)")
        }
    }
}
