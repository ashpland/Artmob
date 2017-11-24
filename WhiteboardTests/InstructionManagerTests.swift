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
    
    func testArrayComparison() {
        
        let myArray = ["element1", "element2", "element3", "element4"]
        let theirArray1 = ["element1", "element3", "element4"]
        
        let output = theirArray1.elementsMissingFrom(myArray)
        
        XCTAssertEqual(output, ["element2"], "element2 should be missing")
        
    }
    
    
    
    func testInstructionRequestQueueing() {
        let expect = expectation(description: #function)
        
        var myInstructions = [Instruction]()
        for _ in 0..<2 {
            let newInstruction = generateLineInstruction()
            myInstructions.append(newInstruction)
        }
        
        var theirInstructions = myInstructions
        theirInstructions.remove(at: 0)
        
        InstructionManager.subscribeToInstructionsFrom(Observable.from(myInstructions.withNilHash))
        
        InstructionManager.sharedInstance.sync(theirInstructions: theirInstructions.stamps,
                                               from: MPCHandler.sharedInstance.session.myPeerID)
        InstructionManager.sharedInstance.sync(theirInstructions: theirInstructions.stamps,
                                               from: MPCHandler.sharedInstance.session.myPeerID)
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in expect.fulfill() }
        
        waitForExpectations(timeout: 4.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssert(self.broadcastInstructions.count == 3,
                      "Only one instruction should be rebroadcasted")
            XCTAssertEqual(self.broadcastInstructions[0].stamp, self.broadcastInstructions[2].stamp,
                      "The instruction missing from the second and third arrays should be rebroadcast")
        }
    }
    
    
    func testRequestMissingLocalInstruction() {
        let expect = expectation(description: #function)
        
        var theirInstructions = [Instruction]()
        for _ in 0..<2 {
            let newInstruction = generateLineInstruction()
            theirInstructions.append(newInstruction)
        }
        
        var myInstructions = theirInstructions
        myInstructions.remove(at: 0)
        
        InstructionManager.subscribeToInstructionsFrom(Observable.from(myInstructions.withNilHash))
        
        InstructionManager.sharedInstance.sync(theirInstructions: theirInstructions.stamps,
                                               from: MPCHandler.sharedInstance.session.myPeerID)
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) {
            _ in
            expect.fulfill()
            
        }
        
        waitForExpectations(timeout: 4.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssert(self.broadcastInstructions.count == 3,
                      "Only one instruction should be rebroadcasted")
            XCTAssertEqual(self.broadcastInstructions[0].stamp, self.broadcastInstructions[2].stamp,
                           "The instruction missing from the second and third arrays should be rebroadcast")
        }
        
        
    }
    
    
}
