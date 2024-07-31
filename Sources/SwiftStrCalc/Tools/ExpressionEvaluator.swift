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

        print("Index\tValue\t\tType")
        print("------------------------")
        lexemes.forEach {
            print("\($0.startIndexInExp)\t\t\($0.value)\t\t\t\($0.type)")
        }
    }
}
