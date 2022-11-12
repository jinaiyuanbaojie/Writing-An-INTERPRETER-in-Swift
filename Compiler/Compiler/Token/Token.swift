//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

// Indicates the unit or word in source codes
struct Token {
    let tokenType: TokenType
    let literal: String
    
    var isEnd: Bool {
        tokenType == TokenType.EOF
    }
}

enum TokenType: String {
    case ILLEGAL = "ILLEGAL"
    case EOF = "EOF"
    
    case IDENT = "IDENT"
    case INT = "INT"
    
    case ASSIGN = "="
    case PLUS = "+"
    case MINUS = "-"
    case BANG = "!"
    case ASTERISK = "*"
    case SALSH = "/"
    case EQ = "=="
    case NOT_EQ = "!="
    
    case COMMA = ","
    case SEMICOLON = ";"
    
    case LPAREN = "("
    case RPAREN = ")"
    case LBRACE = "{"
    case RBRACE = "}"
    
    case LT = "<"
    case GT = ">"
    
    case FUNCTION = "FUNCTION"
    case LET = "LET"
    case TRUE = "TRUE"
    case FALSE = "FALSE"
    case IF = "IF"
    case ELSE = "ELES"
    case RETRUN = "RETURN"
}

let keywords = [
    "fn": TokenType.FUNCTION,
    "let": TokenType.LET,
    "true": TokenType.TRUE,
    "false": TokenType.FALSE,
    "if": TokenType.IF,
    "else": TokenType.ELSE,
    "return": TokenType.RETRUN,
]

func lookupIdentifier(identifier: String) -> TokenType {
    if let tokenType = keywords[identifier] {
        return tokenType
    }
    
    return TokenType.IDENT
}


