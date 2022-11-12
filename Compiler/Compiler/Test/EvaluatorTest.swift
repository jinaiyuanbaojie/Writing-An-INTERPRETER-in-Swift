//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

func testEva() {
    let input = """
if (2>1) {
  if (10>1) {
    return 10;
  }
  return 1;
}
"""
    let lexer = Lexer(input: input)
    let parser = Parser(lexer: lexer)
    let program = parser.parseProgam()
    let ret = eval(node: program, env: Environment())
    print(ret ?? "NULL")
}
