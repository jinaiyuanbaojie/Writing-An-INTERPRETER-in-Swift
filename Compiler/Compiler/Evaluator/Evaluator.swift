//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

let monkeyTrue = MonkeyBoolean(value: true)
let monkeyFalse = MonkeyBoolean(value: false)
let monkeyNULL = MonkeyNull()

func eval(node: Node?, env: Environment) -> MonkeyObject? {
    if node is Program {
        let p = (node as! Program)
        return evalProgram(stmts: p.statements, env: env)
    }
    
    if node is ExpressionStatement {
        let exp = (node as! ExpressionStatement)
        return eval(node: exp.expression, env: env)
    }
    
    if node is IntegerLiteral {
        let value = (node as! IntegerLiteral).value ?? 0
        return MonkeyInteger(value: value)
    }
    
    if node is Boolean {
        let b: Bool = (node as! Boolean).value ?? false
        return b ? monkeyTrue : monkeyFalse
    }
    
    if node is PrefixExpression {
        let p = (node as! PrefixExpression)
        let right = eval(node: p.right, env: env)
        if right is MonkeyError {
            return right
        }
        return evalPrefixExpression(opt: p.operator, right: right)
    }
    
    if node is InfixExpression {
        let n = node as! InfixExpression
        let left = eval(node: n.left, env: env)
        if left is MonkeyError {
            return left
        }
        let right = eval(node: n.right, env: env)
        if right is MonkeyError {
            return right
        }
        return evalInfixExpression(n.operator, left, right)
    }
    
    if node is BlockStatement {
        let n = node as! BlockStatement
        return evalBlockStatement(block: n, env: env)
    }
    
    if node is IfExpression {
        return evalIfExpression(ie: node as? IfExpression, env: env)
    }
    
    if node is ReturnStatement {
        let n = node as! ReturnStatement
        let value = eval(node: n.returnValue, env: env)
        if value is MonkeyError {
            return value
        }
        return MonkeyReturnValue(value: value)
    }
    
    if node is LetStatement {
        let n = node as! LetStatement
        let val = eval(node: n.value, env: env)
        if val is MonkeyError {
            return val
        }
        env.set(name: n.name?.value ?? "", obj: val!)
    }
    
    if node is Identifier {
        return evalIdentifier(node: node as! Identifier, env: env)
    }
    
    if node is FunctionLiteral {
        let n = node as! FunctionLiteral
        let params = n.parameters
        let body = n.body
        return Function(parameters: params, body: body, env: env)
    }
    
    if node is CallExpression {
        let n = node as! CallExpression
        let function = eval(node: n.function, env: env)
        if function is MonkeyError {
            return function
        }
        let args = evalExpressions(exps: n.arguments ?? [], env: env)
        if args.first is MonkeyError {
            return args.first
        }
        
        return applyFunction(function, args)
    }
    
    return nil
}

func evalProgram(stmts: [Statement], env: Environment) -> MonkeyObject? {
    var result: MonkeyObject?
    
    for statement in stmts {
        result = eval(node: statement, env: env)
        
        if result is MonkeyReturnValue {
            let ret = result as! MonkeyReturnValue
            return ret.value
        }
        
        if result is MonkeyError {
            return result
        }
    }
    
    return result
}

func evalPrefixExpression(opt: String?, right: MonkeyObject?) -> MonkeyObject? {
    switch opt {
    case "!":
        return evalBangOperationExpression(r: right)
    case "-":
        return evalMinusPrefixOperatorExpression(r: right)
    default:
        return createError(msg: "unknown operator: \(opt ?? "") \(right?.inspect() ?? "")")
    }
}

func evalBangOperationExpression(r: MonkeyObject?) -> MonkeyObject? {
    if let r = (r as? MonkeyBoolean) {
        return r.value ? monkeyFalse : monkeyTrue;
    }

    if let _ = (r as? MonkeyNull) {
        return monkeyTrue;
    }
        
    return monkeyFalse
}

func evalMinusPrefixOperatorExpression(r: MonkeyObject?) -> MonkeyObject? {
    guard let r = r as? MonkeyInteger else {
        return createError(msg: "unknown operator: \(r?.inspect() ?? "")")
    }
    
    return MonkeyInteger(value: -r.value)
}

func evalInfixExpression(_ opt: String?, _ left: MonkeyObject?, _ right: MonkeyObject?) -> MonkeyObject? {
    if left is MonkeyInteger && right is MonkeyInteger {
        return evalIntegerInfixExpression(opt, left, right)
    }
    
    if left is MonkeyBoolean && right is MonkeyBoolean {
        let leftValue = (left as! MonkeyBoolean).value
        let rightValue = (right as! MonkeyBoolean).value
        if opt == "==" {
            return nativeBoolToBoolObject(value: leftValue==rightValue)
        }
        if opt == "!=" {
            return nativeBoolToBoolObject(value: leftValue != rightValue)
        }
        
        return createError(msg: "unknown operator: \(leftValue) \(opt ?? "") \(rightValue)")
    }
    
    return createError(msg: "type mismatch: \(left?.inspect() ?? "") \(opt ?? "") \(right?.inspect() ?? "")")
}

func evalIntegerInfixExpression(_ opt: String?, _ left: MonkeyObject?, _ right: MonkeyObject?) -> MonkeyObject? {
    guard let opt = opt else {
        return monkeyNULL
    }
    
    let leftValue = (left as! MonkeyInteger).value
    let rightValue = (right as! MonkeyInteger).value
    
    switch opt {
    case "+":
        return MonkeyInteger(value: leftValue+rightValue)
    case "-":
        return MonkeyInteger(value: leftValue-rightValue)
    case "*":
        return MonkeyInteger(value: leftValue*rightValue)
    case "/":
        return MonkeyInteger(value: leftValue/rightValue)
    case "<":
        return nativeBoolToBoolObject(value: leftValue<rightValue)
    case ">":
        return nativeBoolToBoolObject(value: leftValue>rightValue)
    case "==":
        return nativeBoolToBoolObject(value: leftValue==rightValue)
    case "!=":
        return nativeBoolToBoolObject(value: leftValue != rightValue)
    default:
        return createError(msg: "unknown operator: \(leftValue) \(opt) \(rightValue)")
    }
}

func nativeBoolToBoolObject(value: Bool) -> MonkeyBoolean {
    value ? monkeyTrue : monkeyFalse
}

func evalIfExpression(ie: IfExpression?, env: Environment) -> MonkeyObject? {
    let condition = eval(node: ie?.condition, env: env)
    if condition is MonkeyError {
        return condition
    }
    if isTruthy(obj: condition) {
        return eval(node: ie?.consequence, env: env)
    } else if ie?.alternative != nil {
        return eval(node: ie?.alternative, env: env)
    } else {
        return monkeyNULL
    }
}

func isTruthy(obj: MonkeyObject?) -> Bool {
    if obj is MonkeyNull {
        return false
    }
    
    if obj is MonkeyBoolean {
        return (obj as! MonkeyBoolean).value
    }
    
    return true
}

func evalBlockStatement(block: BlockStatement?, env: Environment) -> MonkeyObject? {
    var result: MonkeyObject?
    
    if let statements = block?.statments {
        for stmt in statements {
            result = eval(node: stmt, env: env)
            
            if result is MonkeyReturnValue {
                let ret = result as! MonkeyReturnValue
                return ret
            }
            
            if result is MonkeyError {
                return result
            }
        }
    }
    
    return result
}

func createError(msg: String) -> MonkeyError {
    MonkeyError(messgae: msg)
}

func evalIdentifier(node: Identifier, env: Environment) -> MonkeyObject {
    if let val = env.get(name: node.value) {
        return val
    }
    
    return createError(msg: "identifier not found: \(node.value)")
}

func evalExpressions(exps: [Expression], env: Environment) -> [MonkeyObject] {
    var ret = [MonkeyObject]()
    for e in exps {
        let evalauted = eval(node: e, env: env)
        if evalauted is MonkeyError {
            return [evalauted!]
        }
        ret.append(evalauted!)
    }
    return ret
}

func applyFunction(_ fn: MonkeyObject?, _ args: [MonkeyObject]) -> MonkeyObject? {
    if let fn = fn as? Function {
        let extendedEnv = extendFunctionEnv(fn, args: args)
        let evalauted = eval(node: fn.body, env: extendedEnv)
        return unwrapReturnValue(obj: evalauted)
    } else {
        return createError(msg: "not a function: \(fn?.inspect() ?? "")")
    }
}

func extendFunctionEnv(_ fn: Function, args: [MonkeyObject]) -> Environment {
    let env = Environment()
    env.outer = fn.env
    
    if !(fn.parameters?.isEmpty ?? true) {
        for (index, item) in fn.parameters!.enumerated() {
            env.set(name: item.value, obj: args[index])
        }
    }
    return env
}

func unwrapReturnValue(obj: MonkeyObject?) -> MonkeyObject? {
    if obj is MonkeyReturnValue {
        let ret = obj as! MonkeyReturnValue
        return ret.value
    }
    
    return obj
}
