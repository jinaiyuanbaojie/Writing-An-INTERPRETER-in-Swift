//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

typealias ObjectType = String

enum MonkeyType: String {
    case INTEGRE_OBJ = "INTEGRE"
    case BOOLEAN_OBJ = "BOOLEAN"
    case NULL_OBJ = "NULL"
    case RETURN_VALUE_OBJ = "RETURN_VALUE"
    case ERROR_OBJ = "ERROR"
    case FUNCTION_OBJ = "FUNCTION"
}

protocol MonkeyObject {
    func monkeyType() -> ObjectType
    func inspect() -> String
}

struct MonkeyInteger: MonkeyObject {
    func monkeyType() -> ObjectType {
        MonkeyType.INTEGRE_OBJ.rawValue
    }
    
    func inspect() -> String {
        String(value)
    }
    
    var value: Int
}

struct MonkeyBoolean: MonkeyObject {
    func monkeyType() -> ObjectType {
        MonkeyType.BOOLEAN_OBJ.rawValue
    }
    
    func inspect() -> String {
        String(value)
    }
    
    var value: Bool
}

struct MonkeyNull: MonkeyObject {
    func monkeyType() -> ObjectType {
        MonkeyType.NULL_OBJ.rawValue
    }
    
    func inspect() -> String {
        "null"
    }
}

struct MonkeyReturnValue: MonkeyObject {
    func monkeyType() -> ObjectType {
        MonkeyType.RETURN_VALUE_OBJ.rawValue
    }
    
    func inspect() -> String {
        value?.inspect() ?? ""
    }
    
    var value: MonkeyObject?
}

struct MonkeyError: MonkeyObject {
    func monkeyType() -> ObjectType {
        MonkeyType.ERROR_OBJ.rawValue
    }
    
    func inspect() -> String {
        "ERROR: \(messgae)"
    }
    
    var messgae: String
}

struct Function: MonkeyObject {
    func monkeyType() -> ObjectType {
        MonkeyType.FUNCTION_OBJ.rawValue
    }
    
    func inspect() -> String {
        var params = [String]()
        if let parameters = parameters {
            for p in parameters {
                params.append(p.debugLog())
            }
        }
        
        return "fn(\(params.joined(separator: ","))){\n\(body?.debugLog() ?? "")\n}"
    }
    
    var parameters: [Identifier]?
    var body: BlockStatement?
    var env: Environment?
}
