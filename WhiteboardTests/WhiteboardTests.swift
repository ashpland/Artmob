//
//  WhiteboardTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
@testable import Whiteboard

class WhiteboardTests: XCTestCase {
    
    let viewModel = BoardViewModel()
    let instructionManager = InstructionManager()
    let elementModel = ElementModel()
    
    var lineStream : PublishSubject<LineSegment>!
 
    
    fileprivate func generateLines(numberOfLines: Int, pointsPerLine: Int) {
        self.lineStream = PublishSubject<LineSegment>()
        
        //generate lines
        for _ in 0...numberOfLines {
            
            self.viewModel.recieveLine(self.lineStream)
            
            //generate random line segments
            for _ in 0...pointsPerLine {
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
        
        
        let numberOfLines = 10
        let pointsPerLine = 10
        
        generateLines(numberOfLines: numberOfLines, pointsPerLine: pointsPerLine)
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        
        
        
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
