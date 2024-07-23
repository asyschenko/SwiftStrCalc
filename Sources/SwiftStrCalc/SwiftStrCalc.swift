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
        self.library = Library()
        self.lexParser = LexemeParser(library: library)
    }

    public func calculate(_ exp: String) throws {
        try lexParser.parse(exp)
    }
}
