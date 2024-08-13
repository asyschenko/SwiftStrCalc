//
//  ExpressionParserTest.swift
//  SwiftStrCalcTests
//
//  Created by Alex Syschenko on 13.08.2024.
//

import XCTest
@testable import SwiftStrCalc

class ExpressionParserTest: XCTestCase {

    private struct MocAlphabets: Alphabets {
        var openBracket: Set<Character>
        var closeBracket: Set<Character>
        var whiteSpace: Set<Character>
        var number: Set<Character>
        var `operator`: Set<Character>
        var atom: Set<Character>
        var atomFull: Set<Character>
        var final: Set<Character>
    }

    func testLexemeError() {
        let alphabets = MocAlphabets(
            openBracket: [],
            closeBracket: [],
            whiteSpace: [],
            number: [],
            operator: [],
            atom: ["a"],
            atomFull: ["a"],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)

        do {
            _ = try parser.parse("aaa+aaa")
            XCTFail("Does not catch error")
        } catch CalcError.FSMRouteError {

        } catch {
            XCTFail("Does not catch FSMRouteError")
        }
    }

    func testLexemeAtom() throws {
        let alphabets = MocAlphabets(
            openBracket: [],
            closeBracket: [],
            whiteSpace: [],
            number: [],
            operator: [],
            atom: ["a"],
            atomFull: ["a"],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("aaa")

        XCTAssertEqual(lexemes.count, 1, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "aaa", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .atom, "Invalid lexeme type")
    }

    func testLexemeNumber() throws {
        let alphabets = MocAlphabets(
            openBracket: [],
            closeBracket: [],
            whiteSpace: [],
            number: ["1"],
            operator: [],
            atom: [],
            atomFull: [],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("111")

        XCTAssertEqual(lexemes.count, 1, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "111", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .number, "Invalid lexeme type")
    }

    func testLexemeOperator() throws {
        let alphabets = MocAlphabets(
            openBracket: [],
            closeBracket: [],
            whiteSpace: [],
            number: [],
            operator: ["+"],
            atom: ["a"],
            atomFull: ["a"],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("aaa+aa")

        XCTAssertEqual(lexemes.count, 3, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "aaa", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .atom, "Invalid lexeme type")

        XCTAssertEqual(lexemes[1].value, "+", "Invalid lexeme value")
        XCTAssertEqual(lexemes[1].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[2].value, "aa", "Invalid lexeme value")
        XCTAssertEqual(lexemes[2].type, .atom, "Invalid lexeme type")
    }

    func testLexemeBrackets() throws {
        let alphabets = MocAlphabets(
            openBracket: ["("],
            closeBracket: [")"],
            whiteSpace: [],
            number: [],
            operator: [],
            atom: ["a"],
            atomFull: ["a"],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("(aaa)")

        XCTAssertEqual(lexemes.count, 3, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "(", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .openBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[1].value, "aaa", "Invalid lexeme value")
        XCTAssertEqual(lexemes[1].type, .atom, "Invalid lexeme type")

        XCTAssertEqual(lexemes[2].value, ")", "Invalid lexeme value")
        XCTAssertEqual(lexemes[2].type, .closeBracket, "Invalid lexeme type")
    }

    func testLexemeWhitespaces() throws {
        let alphabets = MocAlphabets(
            openBracket: [],
            closeBracket: [],
            whiteSpace: [" "],
            number: ["1"],
            operator: ["+"],
            atom: [],
            atomFull: [],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("1 + 11    + 111")

        XCTAssertEqual(lexemes.count, 5, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "1", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[1].value, "+", "Invalid lexeme value")
        XCTAssertEqual(lexemes[1].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[2].value, "11", "Invalid lexeme value")
        XCTAssertEqual(lexemes[2].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[3].value, "+", "Invalid lexeme value")
        XCTAssertEqual(lexemes[3].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[4].value, "111", "Invalid lexeme value")
        XCTAssertEqual(lexemes[4].type, .number, "Invalid lexeme type")
    }

    func testLexemeUnaryOperators() throws {
        let alphabets = MocAlphabets(
            openBracket: ["("],
            closeBracket: [")"],
            whiteSpace: [],
            number: ["1", "2"],
            operator: ["-", "+"],
            atom: [],
            atomFull: [],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("-1+(-1)+2")

        XCTAssertEqual(lexemes.count, 9, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "-", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[1].value, "1", "Invalid lexeme value")
        XCTAssertEqual(lexemes[1].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[2].value, "+", "Invalid lexeme value")
        XCTAssertEqual(lexemes[2].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[3].value, "(", "Invalid lexeme value")
        XCTAssertEqual(lexemes[3].type, .openBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[4].value, "-", "Invalid lexeme value")
        XCTAssertEqual(lexemes[4].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[5].value, "1", "Invalid lexeme value")
        XCTAssertEqual(lexemes[5].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[6].value, ")", "Invalid lexeme value")
        XCTAssertEqual(lexemes[6].type, .closeBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[7].value, "+", "Invalid lexeme value")
        XCTAssertEqual(lexemes[7].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[8].value, "2", "Invalid lexeme value")
        XCTAssertEqual(lexemes[8].type, .number, "Invalid lexeme type")
    }

    func testBigLexeme() throws {
        let alphabets = MocAlphabets(
            openBracket: ["("],
            closeBracket: [")"],
            whiteSpace: [" "],
            number: ["1", "2", "3"],
            operator: ["-", "+", "*", "/"],
            atom: ["a", "b", "c", "p", "i"],
            atomFull: ["a", "b", "c", "p", "i", "1", "2", "3"],
            final: ["#"])
        let parser = ExpressionParser(alphabets: alphabets)
        let lexemes = try parser.parse("(1 + 2 / pi) * ((-1) - abcc123 /  (abbc))")

        XCTAssertEqual(lexemes.count, 20, "Invalid lexemes count")
        XCTAssertEqual(lexemes[0].value, "(", "Invalid lexeme value")
        XCTAssertEqual(lexemes[0].type, .openBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[1].value, "1", "Invalid lexeme value")
        XCTAssertEqual(lexemes[1].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[2].value, "+", "Invalid lexeme value")
        XCTAssertEqual(lexemes[2].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[3].value, "2", "Invalid lexeme value")
        XCTAssertEqual(lexemes[3].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[4].value, "/", "Invalid lexeme value")
        XCTAssertEqual(lexemes[4].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[5].value, "pi", "Invalid lexeme value")
        XCTAssertEqual(lexemes[5].type, .atom, "Invalid lexeme type")

        XCTAssertEqual(lexemes[6].value, ")", "Invalid lexeme value")
        XCTAssertEqual(lexemes[6].type, .closeBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[7].value, "*", "Invalid lexeme value")
        XCTAssertEqual(lexemes[7].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[8].value, "(", "Invalid lexeme value")
        XCTAssertEqual(lexemes[8].type, .openBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[9].value, "(", "Invalid lexeme value")
        XCTAssertEqual(lexemes[9].type, .openBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[10].value, "-", "Invalid lexeme value")
        XCTAssertEqual(lexemes[10].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[11].value, "1", "Invalid lexeme value")
        XCTAssertEqual(lexemes[11].type, .number, "Invalid lexeme type")

        XCTAssertEqual(lexemes[12].value, ")", "Invalid lexeme value")
        XCTAssertEqual(lexemes[12].type, .closeBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[13].value, "-", "Invalid lexeme value")
        XCTAssertEqual(lexemes[13].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[14].value, "abcc123", "Invalid lexeme value")
        XCTAssertEqual(lexemes[14].type, .atom, "Invalid lexeme type")

        XCTAssertEqual(lexemes[15].value, "/", "Invalid lexeme value")
        XCTAssertEqual(lexemes[15].type, .operator, "Invalid lexeme type")

        XCTAssertEqual(lexemes[16].value, "(", "Invalid lexeme value")
        XCTAssertEqual(lexemes[16].type, .openBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[17].value, "abbc", "Invalid lexeme value")
        XCTAssertEqual(lexemes[17].type, .atom, "Invalid lexeme type")

        XCTAssertEqual(lexemes[18].value, ")", "Invalid lexeme value")
        XCTAssertEqual(lexemes[18].type, .closeBracket, "Invalid lexeme type")

        XCTAssertEqual(lexemes[19].value, ")", "Invalid lexeme value")
        XCTAssertEqual(lexemes[19].type, .closeBracket, "Invalid lexeme type")
    }
}
