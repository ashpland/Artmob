//
//  MessagesTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-22.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
@testable import Whiteboard



class MessagesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStampsConversion() {
        let instructions = [generateLineInstruction(), generateLineInstruction(), generateLineInstruction()]
        let stamps = instructions.stamps
        let stampsMessage = StampMessage(stamps: stamps)
        let decodedStamps = stampsMessage.toStamps()
        
        XCTAssert(stamps == decodedStamps, "Stamps array should be the same after conversion to message")
    }
    
    func testLineConversion() {
        let instructions = [generateLineInstruction(), generateLineInstruction(), generateLineInstruction()]
        let lineMessages = instructions.map{ LineMessage(instruction: $0) }
        let decodedLineMessages = lineMessages.map { $0.toInstruction() }
        
        XCTAssert(instructions.stamps == decodedLineMessages.stamps, "Instructions should be the same after conversion to message")
    }
    
    func testLabelConversion() {
        
    }
    
    
    
}
