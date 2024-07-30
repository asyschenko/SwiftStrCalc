//
//  Library.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 23.07.2024.
//

import Foundation

public final class Library {

    private var functions: [String: Function]

    public init() {
        self.functions = [:]
    }

    func function(at name: String) -> Function? {
        return functions[name]
    }

    func hasFunction(at name: String) -> Bool {
        return function(at: name) != nil
    }
}


// MARK: - Public
public extension Library {

    func add(function: Function) throws {
        if functions[function.name] != nil {
            throw CalcError.existFunctionError
        }
        functions[function.name] = function
    }
}
