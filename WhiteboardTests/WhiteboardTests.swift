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

    override func setUp() {
        super.setUp()
        self.boardViewModel = BoardViewModel()
    }
    
    override func tearDown() {
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
        
        generateLineInputs(numberOfLines: expectedCount,
                                pointsPerLine: 10,
                                boardViewModel: self.boardViewModel)
        
        self.boardViewModel.submitInstruction.onCompleted()
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }

            XCTAssertEqual(expectedCount, result.count)
        }
    }
    
    
    
    
    func testInstructionManagerInstructions() {
        
        let disposeBag = DisposeBag()
        let expect = expectation(description: #function)
        let expectedCount = 10
        
        let completeCount = PublishSubject<Bool>()
        
        var newInstructions = [Instruction]()
        var broadcastInstructions = [Instruction]()
        
        
        
        InstructionManager.sharedInstance.newInstructions
            .subscribe(onNext: { (instruction) in
                newInstructions.append(instruction)
            }, onCompleted: {
                completeCount.onNext(true)
            }).disposed(by: disposeBag)
        
        InstructionManager.sharedInstance.broadcastInstructions
            .subscribe(onNext: { (instruction) in
                broadcastInstructions.append(instruction)
            }, onCompleted: {
                completeCount.onNext(true)
            }).disposed(by: disposeBag)
        
        
        generateLineInputs(numberOfLines: expectedCount,
                           pointsPerLine: 10,
                           boardViewModel: self.boardViewModel )
        
        InstructionManager.sharedInstance.newInstructions.onCompleted()
        InstructionManager.sharedInstance.broadcastInstructions.onCompleted()

        
        
        completeCount.buffer(timeSpan: 1.0, count: 2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in expect.fulfill() } )
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedCount, newInstructions.count)
            XCTAssertEqual(expectedCount, broadcastInstructions.count)
        }
    }

    func testInstructionManagerDuplicateInstructions() {

        let disposeBag = DisposeBag()
        let expect = expectation(description: #function)
        let expectedCount = 10

        let completeCount = PublishSubject<Bool>()

        var newInstructions = [Instruction]()
        var broadcastInstructions = [Instruction]()

        let testInstructionSubject = PublishSubject<Instruction>()

        
        InstructionManager.sharedInstance.newInstructions
            .subscribe(onNext: { (instruction) in
                newInstructions.append(instruction)
            }, onCompleted: {
                completeCount.onNext(true)
            }).disposed(by: disposeBag)
        
        InstructionManager.sharedInstance.broadcastInstructions
            .subscribe(onNext: { (instruction) in
                broadcastInstructions.append(instruction)
            }, onCompleted: {
                completeCount.onNext(true)
            }).disposed(by: disposeBag)

        
        
        
        
        
        InstructionManager.subscribeToInstructionsFrom(testInstructionSubject)

        
//
//        InstructionManager.sharedInstance.newInstructions.onCompleted()
//        InstructionManager.sharedInstance.broadcastInstructions.onCompleted()
//


        completeCount.buffer(timeSpan: 1.0, count: 2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in expect.fulfill() } )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: 2.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }

            XCTAssertEqual(expectedCount, newInstructions.count)
            XCTAssertEqual(expectedCount, broadcastInstructions.count)
        }
    }
    
    
}
