//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
    

import Foundation

func testNextToken() {
    let input = """
let five = 5;
let ten = 10;

let add = fn(x, y) {
    x + y;
}

let result = add(five, ten);
!-/*5;
5 < 6 > 5;

if (5<10) {
    return true;
} else {
    return false;
}

100 == 10;
1 != 3;
"""
    
    let lexer = Lexer(input: input)
    var tokenList = [Token]()
    
    var loop = true
    repeat {
        let tok = lexer.nextToken()
        tokenList.append(tok)
        loop = tok.tokenType != TokenType.EOF
        print(tok)
        assert(tok.tokenType != TokenType.ILLEGAL)
    } while (loop)
}

let test = """
let add = fn(x,y) { x+y;};

let x = 5;
let y = 10;
let foobar = add(5,5);
let barfoo = 5*5/10+18 - add(5,5) + multipy(124);
let anotherName = barfoo;
"""
