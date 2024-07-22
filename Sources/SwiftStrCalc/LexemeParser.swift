//
//  LexemeParser.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 22.07.2024.
//

import Foundation

final class LexemeParser {

    private var prevState: State = .stateInitial
    private var currentLexStr: String = ""
    private var finalStateMachine: FinalStateMachine<State>?

    func parse(exp: String) throws {
        if finalStateMachine == nil {
            finalStateMachine = createFSM()
        }

        try finalStateMachine?.start(exp + "#") { result in
            try self.handleResult(result)
        }
    }
}

// MARK: - Private types
private extension LexemeParser {

    enum State: Hashable {
        case stateInitial
        case stateOB        // Open bracket
        case stateCB        // Close bracket
        case stateOperator
        case stateNumber
        case stateAtom      // Variable, constant, function...
        case stateWS        // Whitespace
        case stateFinal

        var isBracket: Bool { self == .stateCB || self == .stateOB }
    }

    enum Step {
        case stepOB
        case stepCB
        case stepWS
        case stepNumber
        case stepOperator
        case stepAtom       // Without numbers
        case stepAtomFull   // With numbers
        case stepFinal
    }
}

// MARK: - Private
private extension LexemeParser {

    func handleResult(_ result: FinalStateMachine<State>.StateResult) throws {
        var currentState: State = .stateInitial

        switch result {
        case let .initial(state):
            prevState = state
            currentState = state
            currentLexStr.removeAll()
        case let .success(ch, _, state):
            if state != .stateWS {
                currentState = state

                if !currentLexStr.isEmpty && (currentState.isBracket || currentState != prevState) {
                    print(currentLexStr)
                    currentLexStr.removeAll()
                }
                currentLexStr.append(ch)
                prevState = currentState


//                print("S", "Ch:", ch, "Index:", index, "State:", state)
            }
        case let .failure(ch, index, state):
            print("F", "Ch:", ch, "Index:", index, "State:", state)
        }
    }

    func createFSM() -> FinalStateMachine<State> {
        let sourceRoute: [State: [Step: State]] = [
            .stateInitial: [
                .stepWS: .stateWS,
                .stepOB: .stateOB,
                .stepOperator: .stateOperator,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber,
                .stepFinal: .stateFinal
            ],
            .stateOB: [
                .stepWS: .stateWS,
                .stepOB: .stateOB,
                .stepOperator: .stateOperator,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber
            ],
            .stateCB: [
                .stepWS: .stateWS,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepFinal: .stateFinal
            ],
            .stateOperator: [
                .stepWS: .stateWS,
                .stepOB: .stateOB,
                .stepOperator: .stateOperator,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber
            ],
            .stateNumber: [
                .stepWS: .stateWS,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber,
                .stepFinal: .stateFinal
            ],
            .stateAtom: [
                .stepWS: .stateWS,
                .stepOB: .stateOB,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepAtomFull: .stateAtom,
                .stepFinal: .stateFinal
            ],
            .stateWS: [
                .stepWS: .stateWS,
                .stepOB: .stateOB,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber,
                .stepFinal: .stateFinal
            ]
        ]
        var route: [State: [Character: State]] = [:]

        for currentPare in sourceRoute {
            let currentState = currentPare.key
            let currentSteps = currentPare.value
            var routeSteps: [Character: State] = [:]

            currentSteps.forEach { currentStepPare in
                let alphabet = alphabet(at: currentStepPare.key)

                alphabet.forEach { currentChar in
                    routeSteps[currentChar] = currentStepPare.value
                }
            }
            route[currentState] = routeSteps
        }
        return FinalStateMachine(route: route, initialState: .stateInitial, finalStates: [.stateFinal])
    }

    func alphabet(at step: Step) -> Set<Character> {
        switch step {
        case .stepOB:
            return ["("]
        case .stepCB:
            return [")"]
        case .stepWS:
            return ["\u{0020}", "\t", "\n"]
        case .stepNumber:
            return Set<Character>(chSequence(at: "0", to: "9") + ["."])
        case .stepOperator:
            return ["+", "-", "/", "*", "="]
        case .stepAtom:
            return Set<Character>(chSequence(at: "a", to: "z") + chSequence(at: "A", to: "Z") + ["_"])
        case .stepAtomFull:
            return Set<Character>(chSequence(at: "a", to: "z") + chSequence(at: "A", to: "Z") + chSequence(at: "0", to: "9") + ["_"])
        case .stepFinal:
            return ["#"]
        }
    }

    func chSequence(at: Unicode.Scalar, to: Unicode.Scalar) -> [Character] {
        let range = at.value...to.value

        return range.compactMap() {
            if let scalar = Unicode.Scalar($0) {
                return Character(scalar)
            }
            return nil
        }
    }
}
