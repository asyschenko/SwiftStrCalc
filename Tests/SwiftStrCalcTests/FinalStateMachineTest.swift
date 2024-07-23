//
//  FinalStateMachineTest.swift
//  FinalStateMachineTest
//
//  Created by Alex Syschenko on 11.07.2024.
//

import XCTest
@testable import SwiftStrCalc

class FinalStateMachineTest: XCTestCase {

    private enum State: Hashable {
        case sInitial
        case sOperator
        case sNumber
        case sFinal
    }

    private let routeFSM: FinalStateMachine<State>.Route = [
        .sInitial: [
            "-": .sOperator,
            "+": .sOperator,
            "0": .sNumber,
            "1": .sNumber,
            "2": .sNumber
        ],
        .sOperator: [
            "-": .sOperator,
            "+": .sOperator,
            "0": .sNumber,
            "1": .sNumber,
            "2": .sNumber,
            ".": .sFinal
        ],
        .sNumber: [
            "-": .sOperator,
            "+": .sOperator,
            "0": .sNumber,
            "1": .sNumber,
            "2": .sNumber,
            ".": .sFinal
        ]
    ]

    func testSuccessFSM() {
        let FSM = FinalStateMachine(route: routeFSM,
                               initialState: .sInitial,
                               finalStates: [.sFinal])
        let str = "000+111+222+012."

        FSM.start(str) { res in
            switch res {
            case let .success(char, index, state):
                print("Success:", char, index, state)
            case .failure(_, _, _):
                XCTFail("Invalid FSM")
            default:
                break
            }
        }
    }

    func testFailureFSM() {
        let FSM = FinalStateMachine(route: routeFSM,
                               initialState: .sInitial,
                               finalStates: [.sFinal])
        let str = "000+111_+222+012."
        var failure = false

        FSM.start(str) { res in
            switch res {
            case let .success(char, index, state):
                print("Success:", char, index, state)
            case let .failure(char, index, state):
                print("Failure:", char, index, state)
                failure = true
            default:
                break
            }
        }
        XCTAssert(failure, "Invalid FSM")
    }
}
