//
//  BoardViewModelTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Whiteboard

class BoardViewModelTests: XCTestCase {
    
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
        let expectedCount = Int(arc4random_uniform(50)+1)
        
        var result = [Instruction]()
        
        self.boardViewModel.submitInstruction
            .subscribe(onNext: { (instructionWithHash) in
                result.append(instructionWithHash.0)
            }).disposed(by: self.disposeBag)
        
        
        //generate lines
        for _ in 1...expectedCount {
            let lineStream = PublishSubject<LineSegment>()
            self.boardViewModel.recieveLine(lineStream)
            
            //generate random line segments
            for _ in 1...Int(arc4random_uniform(50)+1) {
                lineStream.onNext(generateLineSegment())
            }
            lineStream.onCompleted()
        }

        expect.fulfill()

        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }

            XCTAssertEqual(expectedCount, result.count, "BoardViewModel should create instructions for each line inputed")
        }  
    }
    
    
    func testBoardViewModelDidUpdateLineImage() {
        let expect = expectation(description: #function)
        
        let firstImage = self.boardViewModel.lineImage.value
        
        InstructionManager.subscribeToInstructionsFrom(Observable
            .from(optional: (generateLineInstruction(), nil)))

        let secondImage = self.boardViewModel.lineImage.value
        
        expect.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertNotEqual(firstImage, secondImage, "BoardViewModel should update LineImage")
        }
    }
    
    
    
}
