//
//  SwiftStrCalc.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 11.07.2024.
//

import Foundation

open class Calc {

    private let lexParser: LexemeParser

    public init() {
        self.lexParser = LexemeParser()
    }

    public func calculate(_ exp: String) throws {
        try lexParser.parse(exp)
    }
}
