//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

class Environment {
    var store = [String:MonkeyObject]()
    var outer: Environment?
    
    func get(name: String) -> MonkeyObject? {
        if let ret = store[name] {
            return ret
        } else {
            return outer?.get(name: name)
        }
    }
    
    func set(name: String, obj: MonkeyObject) {
        store[name] = obj
    }
}

