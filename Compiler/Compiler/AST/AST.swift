//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

protocol Node {
    func tokenLiteral() -> String
    func debugLog() -> String
}

protocol Statement: Node {
    func statementNode()
}

protocol Expression: Node {
    func expressionNode()
}

struct Program: Node {
    var statements: [Statement]

    func tokenLiteral() -> String {
        if statements.isEmpty {
            return ""
        } else {
            return statements.first!.tokenLiteral()
        }
    }
    
    func debugLog() -> String {
        var log = ""
        for statement in statements {
            log += statement.debugLog()
            log += "\n"
        }
        return log
    }
}

struct Identifier: Expression {
    var token: Token
    var value: String

    func expressionNode() {

    }
    
    func tokenLiteral() -> String {
        token.literal
    }
    
    func debugLog() -> String {
        value
    }
}

struct LetStatement: Statement {
    var token: Token?
    var name: Identifier?
    var value: Expression?

    func statementNode() {
        
    }
    
    func tokenLiteral() -> String {
        token!.literal
    }
    
    func debugLog() -> String {
        var log = tokenLiteral() + " " + (name?.debugLog() ?? "") + "="
        
        if let value = value {
            log += value.debugLog()
        }
        log += ";"
        return log
    }
}

struct ReturnStatement: Statement {
    var token: Token?
    var returnValue: Expression?
    
    func statementNode() {
        
    }
    
    func tokenLiteral() -> String {
        token!.literal
    }
    
    func debugLog() -> String {
        var log = tokenLiteral() + " "
        if let returnValue = returnValue {
            log += returnValue.debugLog()
        }
        log += ";"
        return log
    }
}

struct ExpressionStatement: Statement {
    var token: Token?
    var expression: Expression?
    
    func statementNode() {
        
    }
    
    func tokenLiteral() -> String {
        token!.literal
    }
    
    func debugLog() -> String {
        expression?.debugLog() ?? ""
    }
}

struct IntegerLiteral: Expression {
    var token: Token?
    var value: Int?
    
    func expressionNode() {

    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        token?.literal ?? ""
    }
}

struct PrefixExpression: Expression {
    var token: Token?
    var `operator`: String?
    var right: Expression?
    
    func expressionNode() {

    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        "(\(self.operator ?? "")\(right?.debugLog() ?? ""))"
    }
}

struct InfixExpression: Expression {
    var token: Token?
    var `operator`: String?
    var left: Expression?
    var right: Expression?
    
    func expressionNode() {
        
    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        "(\(left?.debugLog() ?? "") \(self.operator ?? "") \(right?.debugLog() ?? ""))"
    }
}


struct Boolean: Expression {
    var token: Token?
    var value: Bool?
    
    func expressionNode() {
        
    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        token?.literal ?? ""
    }
}

struct IfExpression: Expression {
    var token: Token?
    var condition: Expression?
    var consequence: BlockStatement?
    var alternative: BlockStatement?
    
    func expressionNode() {
        
    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        var log = "if \(condition?.debugLog() ?? "") \(consequence?.debugLog() ?? "")"
        if let alter = alternative {
            log += " else \(alter.debugLog())"
        }
        return log
    }
}

struct BlockStatement: Statement {
    var token: Token?
    var statments: [Statement]?
    
    func statementNode() {
        
    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        var log = ""
        if let statments = statments {
            for s in statments {
                log += s.debugLog()
            }
        }
        return log
    }
}

struct FunctionLiteral: Expression {
    var token: Token?
    var parameters: [Identifier]?
    var body: BlockStatement?
    
    func expressionNode() {
        
    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        var params = [String]()
        if let parameters = parameters {
            for p in parameters {
                params.append(p.debugLog())
            }
        }
        
        let log = "\(tokenLiteral())(\(params.joined(separator: ",")))\(body?.debugLog() ?? "")"
        return log
    }
}

struct CallExpression: Expression {
    var token: Token?
    var function: Expression?
    var arguments: [Expression]?
    
    func expressionNode() {
        
    }
    
    func tokenLiteral() -> String {
        token?.literal ?? ""
    }
    
    func debugLog() -> String {
        var args = [String]()
        if let arguments = arguments {
            for a in arguments {
                args.append(a.debugLog())
            }
        }
        
        return "\(function?.debugLog() ?? "")(\(args.joined(separator: ", ")))"
    }
}
