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
            .subscribe(onNext: { (instruction) in
                self.broadcastInstructions.append(instruction)
            }).disposed(by: self.disposeBag)
 
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testInstructionManagerSendingInstructions() {
        
        let expect = expectation(description: #function)
        let expectedCount = 10
        
        generateLineInputs(numberOfLines: expectedCount,
                           pointsPerLine: 10,
                           boardViewModel: BoardViewModel())
        
        expect.fulfill()
        
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedCount, self.newInstructions.count)
            XCTAssertEqual(expectedCount, self.broadcastInstructions.count)
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

        InstructionManager.subscribeToInstructionsFrom(Observable.from(instructionArray))
        
        expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedCount, self.newInstructions.count)
            XCTAssertEqual(expectedCount, self.broadcastInstructions.count)
        }
    }
    
    
}
