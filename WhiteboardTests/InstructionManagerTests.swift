//
//  InstructionManagerTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-20.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Whiteboard

class InstructionManagerTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    
    var newInstructions: [Instruction]!
    var broadcastInstructions: [Instruction]!
    
    
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        InstructionManager.sharedInstance.resetInstructionStore()
        
        
        self.newInstructions = [Instruction]()
        self.broadcastInstructions = [Instruction]()
        
        
        
        InstructionManager.sharedInstance.newInstructions
            .subscribe(onNext: { (instruction) in
                self.newInstructions.append(instruction)
            }).disposed(by: self.disposeBag)
        
        InstructionManager.sharedInstance.broadcastInstructions
            .subscribe(onNext: { (bundle) in
                self.broadcastInstructions.append(bundle.instruction)
            }).disposed(by: self.disposeBag)
 
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testInstructionManagerRecieveInstructions() {
        let expect = expectation(description: #function)
        let expectedCount = Int(arc4random_uniform(10)+1)
        
        var instructionArray = [Instruction]()
        for _ in 0..<expectedCount {
            let newInstruction = generateLineInstruction()
            instructionArray.append(newInstruction)
            instructionArray.append(newInstruction)
        }
        
        InstructionManager.subscribeToInstructionsFrom(Observable.from(instructionArray.withNilHash))
        
        expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            XCTAssertEqual(expectedCount, self.newInstructions.count,
                           "New instructions should equal number of lines input.")
            XCTAssertEqual(expectedCount, self.broadcastInstructions.count,
                           "Broadcast instructions should equal number of lines input.")
        }
    }
    
    
    func testInstructionManagerWithDuplicateInstructions() {
        let expect = expectation(description: #function)
        let expectedCount = Int(arc4random_uniform(5)+1)
        
        var instructionArray = [Instruction]()
        for _ in 0..<expectedCount {
            let newInstruction = generateLineInstruction()
            instructionArray.append(newInstruction)
            instructionArray.append(newInstruction)
        }

        InstructionManager.subscribeToInstructionsFrom(Observable.from(instructionArray.withNilHash))
        expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedCount, self.newInstructions.count,
                           "New instructions should not recieve duplicate instructions.")
            XCTAssertEqual(expectedCount, self.broadcastInstructions.count,
                           "Broadcast instructions should not recieve duplicate instructions.")
            XCTAssertEqual(instructionArray[0].stamp, self.newInstructions[0].stamp, "Instructions should be sent in order")
        }
    }
  
    
    func testInstructionManagerInsertInstructions() {
        let expect = expectation(description: #function)
        let expectedCount = 5
        
        var instructionArray = [Instruction]()
        for _ in 0..<expectedCount {
            let newInstruction = generateLineInstruction()
            instructionArray.append(newInstruction)
        }
        
        let insertInstruction = instructionArray[2]
        instructionArray.remove(at: 2)
        instructionArray.append(insertInstruction)
        
        InstructionManager.subscribeToInstructionsFrom(Observable.from(instructionArray.withNilHash))
        expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedCount - 1, self.newInstructions.count,
                           "New instructions should not recieve inserted instructions.")
            XCTAssertEqual(expectedCount, self.broadcastInstructions.count,
                           "Broadcast instructions should recieve all instructions.")
        }
    }
    
    
}
