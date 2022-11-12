//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

// 语法分析器，分析单词已经语法
class Parser {
    private let lexer: Lexer
    private var curToken: Token
    private var peekToken: Token
    private var errors = [String]()
    private var prefixParseFns = [TokenType: PrefixParseFn]()
    private var infixParseFns = [TokenType: InfixParseFn]()
    
    private var precedences = [
        TokenType.EQ: ParserOperator.EQUALS,
        TokenType.NOT_EQ: ParserOperator.EQUALS,
        TokenType.LT: ParserOperator.LESSGREATER,
        TokenType.GT: ParserOperator.LESSGREATER,
        TokenType.PLUS: ParserOperator.SUM,
        TokenType.MINUS: ParserOperator.SUM,
        TokenType.SALSH: ParserOperator.PRODUCT,
        TokenType.ASTERISK: ParserOperator.PRODUCT,
        TokenType.LPAREN: ParserOperator.CALL,
    ]
    
    init(lexer: Lexer) {
        self.lexer = lexer
        curToken = lexer.nextToken()
        peekToken = lexer.nextToken()
        
        registerPrefix(tokenType: .IDENT, prefixParse: parseIdentifer)
        registerPrefix(tokenType: .INT, prefixParse: parseIntegerLiteral)
        registerPrefix(tokenType: .MINUS, prefixParse: parsePrefixExpression)
        registerPrefix(tokenType: .BANG, prefixParse: parsePrefixExpression)
        registerPrefix(tokenType: .TRUE, prefixParse: parseBoolean)
        registerPrefix(tokenType: .FALSE, prefixParse: parseBoolean)
        registerPrefix(tokenType: .LPAREN, prefixParse: parseGroupedExpression)
        registerPrefix(tokenType: .IF, prefixParse: parseIfExpression)
        registerPrefix(tokenType: .FUNCTION, prefixParse: parseFunctionLiteral)

        registerInfix(tokenType: .PLUS, infixParse: parseInfixExpression)
        registerInfix(tokenType: .MINUS, infixParse: parseInfixExpression)
        registerInfix(tokenType: .ASTERISK, infixParse: parseInfixExpression)
        registerInfix(tokenType: .SALSH, infixParse: parseInfixExpression)
        registerInfix(tokenType: .GT, infixParse: parseInfixExpression)
        registerInfix(tokenType: .LT, infixParse: parseInfixExpression)
        registerInfix(tokenType: .EQ, infixParse: parseInfixExpression)
        registerInfix(tokenType: .NOT_EQ, infixParse: parseInfixExpression)
        registerInfix(tokenType: .LPAREN, infixParse: parseCallExpression)
    }
        
    func parseProgam() -> Program? {
        var program = Program(statements: [])
        
        while !curToken.isEnd {
            let statement = parseStatement()
            if statement != nil {
                program.statements.append(statement!)
            }
            nextToken()
        }
        
        return program
    }
    
    private func parseStatement() -> Statement? {
        switch curToken.tokenType {
        case .LET:
            return parseLetStatement()
        case .RETRUN:
            return parseReturnStatement()
        default:
            return parseExpressionStatement()
        }
    }
    
    private func parseLetStatement() -> LetStatement? {
        var statement = LetStatement(token: curToken)
        
        if !expectPeek(.IDENT) {
            return nil
        }
        
        statement.name = Identifier(token: curToken, value: curToken.literal)
        
        if !expectPeek(.ASSIGN) {
            return nil
        }
        
        nextToken()
        statement.value = parseExpression(.LOWEST)
        
        if !peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return statement
    }
    
    private func parseReturnStatement() -> ReturnStatement? {
        var statement = ReturnStatement()
        statement.token = curToken
        nextToken()
        
        statement.returnValue = parseExpression(.LOWEST)
        
        if !peekTokenIs(.SEMICOLON) {
            nextToken()
        }
        
        return statement
    }
    
    private func parseExpressionStatement() -> ExpressionStatement? {
        var statement = ExpressionStatement(token: curToken)
        statement.expression = parseExpression(.LOWEST)
        
        if peekTokenIs(.SEMICOLON) {
           nextToken()
        }
        return statement
    }
    
    private func parseExpression(_ precedence: ParserOperator) -> Expression? {
        let prefix = prefixParseFns[curToken.tokenType]
        guard let prefix = prefix else {
            noPrefixParseFnError(curToken.tokenType)
            return nil
        }
        
        var leftExp = prefix()
        
        while !peekTokenIs(.SEMICOLON) && (precedence.rawValue < peekPrecedence().rawValue) {
            let infix = infixParseFns[peekToken.tokenType]
            if infix == nil {
                return leftExp
            }
            
            nextToken()
            leftExp = infix!(leftExp!)
        }
        
        return leftExp
    }
    
    func registerPrefix(tokenType: TokenType, prefixParse: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = prefixParse
    }
    
    func registerInfix(tokenType: TokenType, infixParse: @escaping InfixParseFn) {
        infixParseFns[tokenType] = infixParse
    }
    
    private func noPrefixParseFnError(_ tok: TokenType) {
        errors.append("No prefix parse function for \(tok)")
    }
    
    func outputErrors() {
        if errors.isEmpty {
            print("NO ERRORS!")
        } else {
            for msg in errors {
                print("ERROR: \(msg)")
            }
        }
    }
}

/// Token Operators
extension Parser {
    func nextToken() {
        curToken = peekToken
        peekToken = lexer.nextToken()
    }
    
    private func curTokenIs(_ tok: TokenType) -> Bool {
        curToken.tokenType == tok
    }
    
    private func peekTokenIs(_ tok: TokenType) -> Bool {
        peekToken.tokenType == tok
    }
    
    private func expectPeek(_ tok: TokenType) -> Bool {
        if peekTokenIs(tok) {
            nextToken()
            return true
        } else {
            peekError(tok)
            return false
        }
    }
    
    func peekError(_ tok: TokenType) {
        let msg = "Expected next token to be \(tok), got \(peekToken.tokenType) instead."
        errors.append(msg)
    }
}

/// Pratt Algrithom
/// 前缀解析没有左侧的表达式
typealias PrefixParseFn = () -> Expression?
/// 解析中缀，需要左侧的表达式
typealias InfixParseFn = (Expression) -> Expression?

// The order matters, it define the priority
enum ParserOperator: Int {
    case LOWEST
    case EQUALS // ==
    case LESSGREATER // > or <
    case SUM // +
    case PRODUCT // *
    case PREFIX // -x or !x
    case CALL // foo(a,b)
}

// Parser Tokens
extension Parser {
    private func parseIdentifer() -> Expression {
        Identifier(token: curToken, value: curToken.literal)
    }
    
    private func parseIntegerLiteral() -> Expression {
        var lit = IntegerLiteral(token: curToken)
        lit.value = Int(curToken.literal)
        return lit
    }
    
    private func parsePrefixExpression() -> Expression {
        var expression = PrefixExpression(token: curToken, operator: curToken.literal)
        nextToken()
        expression.right = parseExpression(.PREFIX)
        return expression
    }
    
    private func peekPrecedence() -> ParserOperator {
        if let type = precedences[peekToken.tokenType] {
            return type
        }
        
        return .LOWEST
    }
    
    private func curPrecedence() -> ParserOperator {
        if let type = precedences[curToken.tokenType] {
            return type
        }
        
        return .LOWEST
    }
    
    private func parseInfixExpression(_ left: Expression) -> Expression {
        var expression = InfixExpression()
        expression.left = left
        expression.token = curToken
        expression.operator = curToken.literal
        
        let precedence = curPrecedence()
        nextToken()
        expression.right = parseExpression(precedence)
        return expression
    }
    
    private func parseBoolean() -> Expression {
        Boolean(token: curToken, value: curTokenIs(.TRUE))
    }
    
    private func parseGroupedExpression() -> Expression? {
        nextToken()
        let expression = parseExpression(.LOWEST)
        // (xxx * xxx)
        if !expectPeek(.RPAREN) {
            return nil
        }
        
        return expression
    }
    
    private func parseIfExpression() -> Expression? {
        var expression = IfExpression()
        expression.token = curToken
        
        if !expectPeek(.LPAREN) {
            return nil
        }
        
        nextToken()
        expression.condition = parseExpression(.LOWEST)
        
        if !expectPeek(.RPAREN) {
            return nil
        }
        
        if !expectPeek(.LBRACE) {
            return nil
        }
        
        expression.consequence = parseBlockStatement()
        
        if peekTokenIs(.ELSE) {
            nextToken()
            if !expectPeek(.LBRACE) {
                return nil
            }
            
            expression.alternative = parseBlockStatement()
        }
        
        return expression
    }
    
    private func parseBlockStatement() -> BlockStatement? {
        var block = BlockStatement()
        block.token = curToken
        block.statments = []
        
        nextToken()
        while !curTokenIs(.RBRACE) && !curTokenIs(.EOF) {
            let stmt = parseStatement()
            if let stmt = stmt {
                block.statments?.append(stmt)
            }
            nextToken()
        }
        
        return block
    }
    
    private func parseFunctionLiteral() -> Expression? {
        var lit = FunctionLiteral(token: curToken)
        if !expectPeek(.LPAREN) {
            return nil
        }
        
        lit.parameters = parseFunctionParameters()
        if !expectPeek(.LBRACE) {
            return nil
        }
        lit.body = parseBlockStatement()
        return lit
    }
    
    private func parseFunctionParameters() -> [Identifier]? {
        var identifiers = [Identifier]()
        if peekTokenIs(.RPAREN) {
            nextToken()
            return identifiers
        }
        
        nextToken()
        var ident = Identifier(token: curToken, value: curToken.literal)
        identifiers.append(ident)
        
        while peekTokenIs(.COMMA) {
            nextToken()
            nextToken()
            ident = Identifier(token: curToken, value: curToken.literal)
            identifiers.append(ident)
        }
        
        if !expectPeek(.RPAREN) {
            return nil
        }
        
        return identifiers
    }
    
    private func parseCallExpression(_ function: Expression) -> Expression? {
        var exp = CallExpression(token: curToken, function: function)
        exp.arguments = parseCallArguments()
        return exp
    }
    
    private func parseCallArguments() -> [Expression]? {
        var args = [Expression]()
        if peekTokenIs(.RPAREN) {
            nextToken()
            return args
        }
        
        nextToken()
        args.append(parseExpression(.LOWEST)!)
        
        while peekTokenIs(.COMMA) {
            nextToken()
            nextToken()
            args.append(parseExpression(.LOWEST)!)
        }
        
        if !expectPeek(.RPAREN) {
            return nil
        }
        
        return args
    }
}
