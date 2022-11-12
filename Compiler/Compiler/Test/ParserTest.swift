//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

func testLetStatements() {
    let input = """
return 5;
return 10;
return 993 322;
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    
    let program = parser.parseProgam()
    parser.outputErrors()
    if program == nil {
        print("FATAL ERRORS!!!!!!!!")
        return
    } else {
        print(program!)
    }
}


func testIdentifierExpression() {
    let input = """
foobar;
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")
}

func testNumberIdentifierExpression() {
    let input = """
5;
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")
}

func testParsePrefixExpression() {
    let input = """
!5;
-15;
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")

}

func testParseInfixExpression() {
    let input = """
1*2+3;
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")
}

func testParseIFExpression() {
    let input = """
if (x < y) { x } else { y }
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")
}

func testParseFunctionalExpression() {
    let input = """
fn(x,y) {x+y;}
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")
}

func testCallFunctionalExpression() {
    let input = """
add(2,3);`
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    
    parser.outputErrors()
    print(program?.debugLog() ?? "")
}
