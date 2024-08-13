//
//  ExpressionParser.swift
//  SwiftStrCalc
//
//  Created by Alex Syschenko on 22.07.2024.
//

import Foundation

protocol Alphabets {

    var openBracket: Set<Character> { get }
    var closeBracket: Set<Character> { get }
    var whiteSpace: Set<Character> { get }
    var number: Set<Character> { get }
    var `operator`: Set<Character> { get }
    var atom: Set<Character> { get }
    var atomFull: Set<Character> { get }
    var final: Set<Character> { get }
}

final class ExpressionParser {

    private let alphabets: Alphabets
    private var finalStateMachine: FinalStateMachine<State>?

    init(alphabets: Alphabets) {
        self.alphabets = alphabets
    }

    func parse(_ exp: String) throws -> [Lexeme] {
        var prevState: State = .stateInitial
        var prevIndex: UInt = 0
        var currentLexStr: String = ""
        var error: CalcError?
        var lexemes: [Lexeme] = []
        let final = String(alphabets.final.first ?? Character(""))

        if finalStateMachine == nil {
            finalStateMachine = createFSM()
        }

        finalStateMachine?.start(exp + final) { result in
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
        case stateWS            // Whitespace
        case stateWSCB          // Whitespace after close bracket
        case stateWSOperator    // Whitespace after operator
        case stateWSNumber      // Whitespace after number
        case stateWSAtom        // Whitespace after atom
        case stateFinal

        var isBracket: Bool { self == .stateCB || self == .stateOB }
        var isWhitespace: Bool {
            self == .stateWS || self == .stateWSCB || self == .stateWSOperator || self == .stateWSNumber || self == .stateWSAtom
        }

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
        let alphabets: [Step: Set<Character>] = [
            .stepOB: alphabets.openBracket,
            .stepCB: alphabets.closeBracket,
            .stepWS: alphabets.whiteSpace,
            .stepNumber: alphabets.number,
            .stepOperator: alphabets.operator,
            .stepAtom: alphabets.atom,
            .stepAtomFull: alphabets.atomFull,
            .stepFinal: alphabets.final
        ]
        var route: [State: [Character: State]] = [:]

        for currentPare in sourceRoute {
            let currentState = currentPare.key
            let currentSteps = currentPare.value
            var routeSteps: [Character: State] = [:]

            currentSteps.forEach { currentStepPare in
                let alphabet = alphabets[currentStepPare.key]

                alphabet?.forEach { currentChar in
                    routeSteps[currentChar] = currentStepPare.value
                }
            }
            route[currentState] = routeSteps
        }
        return FinalStateMachine(route: route, initialState: .stateInitial, finalStates: [.stateFinal])
    }
}
