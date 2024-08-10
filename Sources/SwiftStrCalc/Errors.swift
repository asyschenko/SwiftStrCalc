//
//  Errors.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 22.07.2024.
//

import Foundation

public enum CalcError: Error {
    case FSMRouteError(char: Character, index: UInt)
    case bracketsCountError(char: Character, index: UInt)
    case existFunctionError
    case invalidOperatorArgument(operator: String, index: UInt)
    case divisionByZero(operator: String, index: UInt)
}
