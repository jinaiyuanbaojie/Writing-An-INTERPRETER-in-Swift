//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

let prompt = ">>"

func start() {
    let env = Environment()
    repeat {
        print(prompt)
        let line = readLine()
        guard let line else {
            return
        }
        
        let lexer = Lexer(input: line)
        let parser = Parser(lexer: lexer)
        let program = parser.parseProgam()
        parser.outputErrors()
        
        let evaluated = eval(node: program, env: env)
        if let evaluated = evaluated {
            print(evaluated.inspect())
        }
    } while (true)
}

 
//fn(x,y,z){ 1+2; return x;}` if(x>y) {return x;}
//let add = fn(x,y) {x+y};
// fn(x){return x;}
