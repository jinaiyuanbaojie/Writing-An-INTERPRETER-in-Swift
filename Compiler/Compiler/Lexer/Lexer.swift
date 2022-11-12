//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

// 词法分析器
class Lexer {
    private let input: String
    // Current index of charactar is reading
    private var position: Int
    // Next index of charactar is reading
    private var readPosition: Int
    // Assume that source code is Encoded by ASCII
    private var ch: UInt8
    
    
    init(input: String, position: Int = 0, readPosition: Int = 0, ch: UInt8 = 0) {
        self.input = input
        self.position = position
        self.readPosition = readPosition
        self.ch = ch
        try! readChar()
    }
    
    private func readChar() throws {
        if readPosition >= input.count {
            ch = 0
        } else {
            let startIndex = input.startIndex
            let currentIndex = input.index(startIndex, offsetBy: readPosition)
            let asciiChar = input[currentIndex]
            if asciiChar.isASCII {
                ch = asciiChar.asciiValue!
            } else {
                print("ERROR: ==== \(position) : \(asciiChar) ======")
                throw LexerError.UnSupportedChar
            }
        }
        
        position = readPosition
        readPosition += 1
    }
    
    func nextToken() -> Token {
        skipWhiteSpace()
        var tok: Token?
        let char = String(bytes: [ch], encoding: .ascii)!
        switch char {
        case "=":
            let nextChar = try! peekChar()
            // next char is =
            if nextChar == 61 {
                try! readChar()
                tok = Token(tokenType: .EQ, literal: "==")
            } else {
                tok = Token(tokenType: .ASSIGN, literal: char)
            }
        case "+":
            tok = Token(tokenType: .PLUS, literal: char)
        case "-":
            tok = Token(tokenType: .MINUS, literal: char)
        case "!":
            let nextChar = try! peekChar()
            // next char is =
            if nextChar == 61 {
                try! readChar()
                tok = Token(tokenType: .NOT_EQ, literal: "!=")
            } else {
                tok = Token(tokenType: .BANG, literal: char)
            }
        case "/":
            tok = Token(tokenType: .SALSH, literal: char)
        case "<":
            tok = Token(tokenType: .LT, literal: char)
        case ">":
            tok = Token(tokenType: .GT, literal: char)
        case "*":
            tok = Token(tokenType: .ASTERISK, literal: char)
        case "(":
            tok = Token(tokenType: .LPAREN, literal: char)
        case ")":
            tok = Token(tokenType: .RPAREN, literal: char)
        case ";":
            tok = Token(tokenType: .SEMICOLON, literal: char)
        case ",":
            tok = Token(tokenType: .COMMA, literal: char)
        case "{":
            tok = Token(tokenType: .LBRACE, literal: char)
        case "}":
            tok = Token(tokenType: .RBRACE, literal: char)
        default:
            if ch == 0 {
                tok = Token(tokenType: .EOF, literal: "")
                break
            }

            if isLetter {
                let identifier = readIdentifier()
                // If the token is keywords or indentifier
                let tokenType = lookupIdentifier(identifier: identifier)
                return Token(tokenType: tokenType, literal: identifier)
            } else if isDigit {
                return Token(tokenType: .INT, literal: readNumber())
            } else {
                // We could not handle the Token
                tok = Token(tokenType: .ILLEGAL, literal: char)
            }
        }
        
        try! readChar()
        
        return tok!
    }
    
    private func skipWhiteSpace() {
        // space \r \n \t
        while ch == 32 || ch == 10 || ch == 13 || ch == 9 {
            try! readChar()
        }
    }
    
    // Only read the next char
    private func peekChar() throws -> UInt8 {
        if readPosition > input.count {
            return 0
        } else {
            let startIndex = input.startIndex
            let currentIndex = input.index(startIndex, offsetBy: readPosition)
            let asciiChar = input[currentIndex]
            if asciiChar.isASCII {
                return asciiChar.asciiValue!
            } else {
                throw LexerError.UnSupportedChar
            }
        }
    }
    
    
    private func readIdentifier() -> String {
        let pos = position
        while isLetter {
            try! readChar()
        }
        
        let start = input.index(input.startIndex, offsetBy: pos)
        let end = input.index(input.startIndex, offsetBy: position)
        
        return String(input[start..<end])
    }
    
    private var isLetter: Bool {
        // a-z or A-Z or _
        return (ch >= 97 && ch <= 122) || (ch >= 65 && ch <= 90) || (ch == 95)
    }
        
    private func readNumber() -> String {
        let pos = position
        while isDigit {
            try! readChar()
        }
        
        let start = input.index(input.startIndex, offsetBy: pos)
        let end = input.index(input.startIndex, offsetBy: position)
        
        return String(input[start..<end])
    }
    
    
    private var isDigit: Bool {
        return ch >= 48 && ch <= 57
    }
}
        
enum LexerError: Error {
    case UnSupportedChar
}
