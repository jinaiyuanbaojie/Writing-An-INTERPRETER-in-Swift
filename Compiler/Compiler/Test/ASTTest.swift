//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

let input = """
let myVar = anotherVar;
"""

func testASTParser() {
    let statements = [LetStatement(token: Token(tokenType: TokenType.LET, literal: "let"),
                 name: Identifier(token: Token(tokenType: TokenType.IDENT, literal: "myVar"), value: "myVar"),
                 value: Identifier(token: Token(tokenType: TokenType.IDENT, literal: "anotherVar"), value: "anotherVar")),]
    let program = Program(statements: statements)
    print(program.debugLog())
}
