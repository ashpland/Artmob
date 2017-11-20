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
    
    var boardViewModel: BoardViewModel!
    var instructionManager: InstructionManager!
    var elementModel: ElementModel!
    
    var lineStream: PublishSubject<LineSegment>!
 
    
    
    fileprivate func generateLines(numberOfLines: Int, pointsPerLine: Int) {
        self.lineStream = PublishSubject<LineSegment>()
        
        //generate lines
        for _ in 1...numberOfLines {
            
            self.boardViewModel.recieveLine(self.lineStream)
            
            //generate random line segments
            for _ in 1...pointsPerLine {
                let firstX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
                let firstY = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.height)))
                let firstPoint = CGPoint(x: firstX, y: firstY)
                let secondX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
                let secondY = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.height)))
                let secondPoint = CGPoint(x: secondX, y: secondY)
                
                let lineSegment = LineSegment(firstPoint: firstPoint, secondPoint: secondPoint)
                self.lineStream.onNext(lineSegment)
            }
            
            self.lineStream.onCompleted()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        boardViewModel = BoardViewModel()
        instructionManager = InstructionManager()
        elementModel = ElementModel()
        scheduler = TestScheduler(initialClock: 0)
        
    }
    
    override func tearDown() {
        scheduler.scheduleAt(1000) {
            self.subscription.dispose()
        }
        
        super.tearDown()
    }
    
    
    func testBoardViewModelCreatesInstructions() {
        let disposeBag = DisposeBag()
        
        let expect = expectation(description: #function)

        let expectedCount = 10

        var result = [Instruction]()
        
        self.boardViewModel.submitInstruction
            .subscribe(onNext: { (instruction) in
                result.append(instruction)
            }, onCompleted: {
                expect.fulfill()
            }).disposed(by: disposeBag)
        
        self.generateLines(numberOfLines: expectedCount, pointsPerLine: 10)
        
        self.boardViewModel.submitInstruction.onCompleted()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }

            XCTAssertEqual(expectedCount, result.count)
        }
    }
    
    
    
    
    func instructionManagerTests() {
        
        //subscribe to IM.new and IM.broadcast
        // put stuff in and check results
        
        
        
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
