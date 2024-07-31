//
//  ExpressionParser.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 22.07.2024.
//

import Foundation

final class ExpressionParser {

    private let library: Library
    private var finalStateMachine: FinalStateMachine<State>?

    init(library: Library) {
        self.library = library
    }

    func parse(_ exp: String) throws -> [Lexeme] {
        var prevState: State = .stateInitial
        var prevIndex: UInt = 0
        var currentLexStr: String = ""
        var error: CalcError?
        var lexemes: [Lexeme] = []

        if finalStateMachine == nil {
            finalStateMachine = createFSM()
        }

        finalStateMachine?.start(exp + "#") { result in
            switch result {
            case let .success(char, index, state):
                if !state.isWhitespace {
                    if !currentLexStr.isEmpty && (state.isBracket || state != prevState) {
                        lexemes.append(Lexeme(type: prevState.lexemeType,
                                              value: currentLexStr,
                                              startIndexInExp: prevIndex))
                        currentLexStr.removeAll()
                        prevIndex = index
                    }
                    currentLexStr.append(char)
                    prevState = state
                }
            case let .failure(char, index, _):
                error = .FSMRouteError(char: char, index: index)
            }
        }

        if let error = error {
            throw error
        }
        return lexemes
    }
}

// MARK: - Types
extension ExpressionParser {

    enum LexemeType {
        case number
        case atom
        case `operator`
        case openBracket
        case closeBracket
        case unowned
    }

    struct Lexeme {
        let type: LexemeType
        let value: String
        let startIndexInExp: UInt
    }
}

// MARK: - Private types
private extension ExpressionParser {

    enum State: Hashable {
        case stateInitial
        case stateOB            // Open bracket
        case stateCB            // Close bracket
        case stateOperator
        case stateNumber
        case stateAtom          // Variable, constant, function...
        case stateWS            // Whitespace after close bracket
        case stateWSCB          // Whitespace after
        case stateWSOperator    // Whitespace after operator
        case stateWSNumber      // Whitespace after number
        case stateWSAtom        // Whitespace after atom
        case stateFinal

        var isBracket: Bool { self == .stateCB || self == .stateOB }
        var isWhitespace: Bool { self == .stateWS || self == .stateWSCB || self == .stateWSOperator || self == .stateWSNumber || self == .stateWSAtom }

        var lexemeType: LexemeType {
            switch self {
            case .stateNumber: return .number
            case .stateAtom: return .atom
            case .stateOperator: return .operator
            case .stateOB: return .openBracket
            case .stateCB: return .closeBracket
            default: return .unowned
            }
        }
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
private extension ExpressionParser {

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
                .stepWS: .stateWSCB,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepFinal: .stateFinal
            ],
            .stateWSCB: [
                .stepWS: .stateWSCB,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepFinal: .stateFinal
            ],
            .stateOperator: [
                .stepWS: .stateWSOperator,
                .stepOB: .stateOB,
                .stepOperator: .stateOperator,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber
            ],
            .stateWSOperator: [
                .stepWS: .stateWSOperator,
                .stepOB: .stateOB,
                .stepAtom: .stateAtom,
                .stepNumber: .stateNumber
            ],
            .stateNumber: [
                .stepWS: .stateWSNumber,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
                .stepNumber: .stateNumber,
                .stepFinal: .stateFinal
            ],
            .stateWSNumber: [
                .stepWS: .stateWSNumber,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
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
            .stateWSAtom: [
                .stepWS: .stateWSAtom,
                .stepOB: .stateOB,
                .stepCB: .stateCB,
                .stepOperator: .stateOperator,
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
