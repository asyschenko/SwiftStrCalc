//
//  FinalStateMachine.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 15.07.2024.
//

import Foundation

final class FinalStateMachine<StateType: Hashable> {

    public typealias Route = [StateType: [Character: StateType]]

    private let route: Route
    private let initialState: StateType
    private let finalStates: Set<StateType>

    public init(route: Route, initialState: StateType, finalStates: Set<StateType>) {
        self.route = route
        self.initialState = initialState
        self.finalStates = finalStates
    }

    public func start(_ string: String, statesHandler: (StateResult) -> Void) {
        var currentState = initialState
        var counter: UInt = 0

        for currentChar in string {
            if let currentStateRote = route[currentState], let nextState = currentStateRote[currentChar] {
                currentState = nextState
                statesHandler(.success(char: currentChar, index: counter, state: nextState))
            } else {
                statesHandler(.failure(char: currentChar, index: counter, state: currentState))
                break
            }
            counter += 1
        }
    }
}

// MARK: - Public types
extension FinalStateMachine {

    enum StateResult {
        case success(char: Character, index: UInt, state: StateType)
        case failure(char: Character, index: UInt, state: StateType)
    }
}
