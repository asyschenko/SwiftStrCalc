//
//  Library.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 23.07.2024.
//

import Foundation

public final class Library {

    let operators: [Operator]

    public init() {
        self.operators = [
            Addition(),
            Subtraction(),
            Multiplication(),
            Division(),
            UnaryPlus(),
            UnaryMinus()
        ]
    }
}
