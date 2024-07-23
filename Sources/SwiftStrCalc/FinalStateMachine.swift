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
        var counter: Int = 0

        for currentChar in string {
            if let currentStateRote = route[currentState], let nextState = currentStateRote[currentChar] {
                currentState = nextState
                statesHandler(.success(currentChar, counter, nextState))
            } else {
                statesHandler(.failure(currentChar, counter, currentState))
                break
            }
            counter += 1
        }
    }
}

// MARK: - Public types
extension FinalStateMachine {

    enum StateResult {
        case success(Character, Int, StateType)
        case failure(Character, Int, StateType)
    }
}
