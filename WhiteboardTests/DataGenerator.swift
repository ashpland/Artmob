//
//  DataGenerator.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-20.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import Whiteboard


internal func generateLineSegment() -> LineSegment {
    let firstX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
    let firstY = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.height)))
    let firstPoint = CGPoint(x: firstX, y: firstY)
    let secondX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
    let secondY = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.height)))
    let secondPoint = CGPoint(x: secondX, y: secondY)
    
    return LineSegment(firstPoint: firstPoint, secondPoint: secondPoint)
}

internal func generateLine() -> Line {
    var newLine = Line()
    for _ in 0...arc4random_uniform(50) {
        newLine = newLine + generateLineSegment()
    }
    return newLine
}

internal func generateLineInstruction() -> Instruction {
    let settings = LineFormatSettings.sharedInstance
    let newLineElement = LineElement(line: generateLine(), width: settings.width, cap: settings.cap, color: settings.color)
    let newInstruction = buildInstruction(type: .new, from: .line(newLineElement))
    return newInstruction
}

fileprivate func buildInstruction(type: InstructionType,
                                  from payload: InstructionPayload) -> Instruction {
    let stamp = Stamp(user: "User", timestamp: Date())
    return Instruction(type: type, element: payload, stamp: stamp)
}









internal func generateLineInputs(numberOfLines: Int, pointsPerLine: Int, boardViewModel: BoardViewModel) {
    let lineStream = PublishSubject<LineSegment>()
    
    //generate lines
    for _ in 1...numberOfLines {
        
        boardViewModel.recieveLine(lineStream)
        
        //generate random line segments
        for _ in 1...pointsPerLine {
            lineStream.onNext(generateLineSegment())
        }
        
        lineStream.onCompleted()
    }
}
