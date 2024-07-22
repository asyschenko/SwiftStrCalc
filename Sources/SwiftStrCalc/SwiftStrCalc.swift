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

        try? lexParser.parse(exp: "1 * 22 + (3.2 + 2) / cos_sin(_va_r2)")
    }
}
