//
//  Errors.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 22.07.2024.
//

import Foundation

public enum CalcError: Error {
    case FSMRouteError(char: Character, index: UInt)
}
