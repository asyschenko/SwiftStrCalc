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

// MARK: - Alphabets
extension Library: Alphabets {

    var openBracket: Set<Character> {
        ["("]
    }
    var closeBracket: Set<Character> {
        [")"]
    }
    var whiteSpace: Set<Character> {
        ["\u{0020}", "\t", "\n"]
    }
    var number: Set<Character> {
        Set<Character>(charSequence(at: "0", to: "9") + ["."])
    }
    var `operator`: Set<Character> {
        var returnSet = Set<Character>()

        operators.forEach { currentOperator in
            currentOperator.name.forEach {
                returnSet.insert($0)
            }
        }
        return returnSet
    }
    var atom: Set<Character> {
        Set<Character>(charSequence(at: "a", to: "z") + charSequence(at: "A", to: "Z") + ["_"])
    }
    var atomFull: Set<Character> {
        Set<Character>(charSequence(at: "a", to: "z") + charSequence(at: "A", to: "Z") + charSequence(at: "0", to: "9") + ["_"])
    }
    var final: Set<Character> {
        ["#"]
    }

    private func charSequence(at: Unicode.Scalar, to: Unicode.Scalar) -> [Character] {
        let range = at.value...to.value

        return range.compactMap() {
            if let scalar = Unicode.Scalar($0) {
                return Character(scalar)
            }
            return nil
        }
    }
}
