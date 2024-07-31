//
//  ExpressionEvaluator.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 31.07.2024.
//

import Foundation

final class ExpressionEvaluator {
    
    private let library: Library
    private let expParser: ExpressionParser

    init(library: Library) {
        self.library = library
        self.expParser = ExpressionParser(library: library)
    }

    func evaluate(_ exp: String) throws {
        let lexemes = try expParser.parse(exp)

        try parse(lexemes)

        print(exp)
        print("Index\tValue\t\tType")
        print("------------------------")
        lexemes.forEach {
            print("\($0.startIndexInExp)\t\t\($0.value)\t\t\t\($0.type)")
        }
    }
}

// MARK: - Private
private extension ExpressionEvaluator {

    func parse(_ lexemes: [ExpressionParser.Lexeme]) throws {
        var openBrackets: [ExpressionParser.Lexeme] = []

        for lexeme in lexemes {
            if lexeme.type == .openBracket {
                openBrackets.append(lexeme)
            } else if lexeme.type == .closeBracket && openBrackets.popLast() == nil {
                throw CalcError.bracketsCountError(char: Character(lexeme.value), index: lexeme.startIndexInExp)
            }
        }

        if let lastLexeme = openBrackets.last {
            throw CalcError.bracketsCountError(char: Character(lastLexeme.value), index: lastLexeme.startIndexInExp)
        }
    }
}
