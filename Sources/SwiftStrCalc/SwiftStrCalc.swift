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
        self.lexParser = LexemeParser()
        self.library = Library()
    }

    public func calculate(_ exp: String) throws {
        let lexemes = try lexParser.parse(exp)

        print("Index\tValue\tType")
        print("--------------------")
        lexemes.forEach {
            print("\($0.startIndexInExp)\t\t\($0.value)\t\t\($0.type)")
        }
    }
}
