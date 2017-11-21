//
//  ElementModelTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-20.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Whiteboard

class ElementModelTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        InstructionManager.sharedInstance.resetInstructionStore()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testElementModelPassingLines() {
        let expect = expectation(description: #function)
        let expectedCount = Int(arc4random_uniform(10)+1)
        
        var linesToDraw = [[LineElement]]()
        
        ElementModel.sharedInstance.lineSubject
            .subscribe(onNext: { lineElements in
                linesToDraw.append(lineElements)
            }).disposed(by: self.disposeBag)
        
        var instructionArray = [Instruction]()
        for _ in 0..<expectedCount {
            let newInstruction = generateLineInstruction()
            instructionArray.append(newInstruction)
        }
        
        InstructionManager.subscribeToInstructionsFrom(Observable.from(instructionArray))
      expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedCount, linesToDraw.count,
                           "Element model should pass on all lines to be drawn.")
            
        }
    }
    
    
    func testElementModelRefreshLines() {
        let expect = expectation(description: #function)
        let expectedCount = 5
        
        var linesToDraw = [[LineElement]]()
        
        ElementModel.sharedInstance.lineSubject
            .subscribe(onNext: { (lineElements) in
                linesToDraw.append(lineElements)
        }).disposed(by: self.disposeBag)
       
        var instructionArray = [Instruction]()
        for _ in 0..<expectedCount {
            let newInstruction = generateLineInstruction()
            instructionArray.append(newInstruction)
        }
        
        let insertInstruction = instructionArray[2]
        instructionArray.remove(at: 2)
        instructionArray.append(insertInstruction)
        
        InstructionManager.subscribeToInstructionsFrom(Observable.from(instructionArray))
        
        expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }

            XCTAssertEqual(expectedCount, linesToDraw.count,
                           "An array should be sent for each line instruction")
            XCTAssert(linesToDraw.last!.count > 1, "Final array should include all previous lines")
        }
    }
    
    
}
