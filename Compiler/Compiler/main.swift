//
//
// Copyright © 2021 Standard Chartered. All rights reserved.
//
	

import Foundation

print("Let us Rock! This is Monkey Programming Language.")

testEva()

start()

func testGroup() {
    testLetStatements()
    testNextToken()
    testASTParser()
    testIdentifierExpression()
    testNumberIdentifierExpression()
    testParsePrefixExpression()
    testParseInfixExpression()
    testParseIFExpression()
    testParseFunctionalExpression()
    testCallFunctionalExpression()
    testEva()
}

// if(1<2){10} if(5*5+10>34){ 99} else {100}if(5*5+10>34){ 99} else {100}
// let addTwo = fn(x) {x+2;};
// let multiply = fn(x, y) { x*y }; multiply(50/2, 1*2)
// fn(x) { x== 10 }(5)
// let newAdder = fn(x) { fn(y) {x+y}};
// let add = newAdder(2);
// add(3)
