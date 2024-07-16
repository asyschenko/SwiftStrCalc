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
        let routeFSM: FinalStateMachine<State>.Route = [
            .initialState: [
                "-": .operatorState,
                "+": .operatorState,
                "0": .numberState,
                "1": .numberState,
                "2": .numberState
            ],
            .operatorState: [
                "-": .operatorState,
                "+": .operatorState,
                "0": .numberState,
                "1": .numberState,
                "2": .numberState,
                ".": .finalState
            ],
            .numberState: [
                "-": .operatorState,
                "+": .operatorState,
                "0": .numberState,
                "1": .numberState,
                "2": .numberState,
                ".": .finalState
            ]
        ]
        let FSM = FinalStateMachine(route: routeFSM,
                               initialState: .initialState,
                               finalStates: [.finalState])


        FSM.start("100+2101200-222.") { res in
            switch res {
            case let .initial(state):
                print(state)
            case let .success(char, index, state):
                print("S", char, index, state)
            case let .failure(char, index, state):
                print("F", char, index, state)
            }
        }
    }
}
