//
//  WhiteboardTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Whiteboard

class WhiteboardTests: XCTestCase {
    
    var scheduler: TestScheduler!
    var subscription: Disposable!
    var disposeBag = DisposeBag()
    
    var boardViewModel: BoardViewModel!

    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.boardViewModel = BoardViewModel()
        InstructionManager.sharedInstance.resetInstructionStore()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testBoardViewModelCreatesInstructions() {
        let expect = expectation(description: #function)
        let expectedCount = 10
        var result = [Instruction]()
        
        self.boardViewModel.submitInstruction
            .subscribe(onNext: { (instruction) in
                result.append(instruction)
            }).disposed(by: self.disposeBag)
        
        generateLineInputs(numberOfLines: expectedCount,
                                pointsPerLine: 10,
                                boardViewModel: self.boardViewModel)
        
        expect.fulfill()

        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }

            XCTAssertEqual(expectedCount, result.count)
        }  
    }
}
