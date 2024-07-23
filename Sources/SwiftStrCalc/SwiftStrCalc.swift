//
//  SwiftStrCalc.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 11.07.2024.
//

import Foundation

enum State: Hashable {
    case initialState
    case operatorState
    case numberState
    case finalState
}

public final class Calc {

    public static func foo() {
        let lexParser = LexemeParser()

//        try? lexParser.parse(exp: "1 * 22 + var + (1+2)")
//        try? lexParser.parse(exp: "1 * 22 + (3.2 + 2) / cos_sin(_va_r2)")
//        try? lexParser.parse(exp: "((sin(cos(tg(1 + 2) + var10) + var11) - pi) + variable) * 234.2233 / 3 * (2 + (3 + (2323 * var2 + 333 * 5343.4)))")
        try? lexParser.parse(exp: "var = 1 + 1 + var")
    }
}
