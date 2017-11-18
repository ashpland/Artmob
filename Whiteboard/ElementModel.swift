//
//  ElementModel.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ElementModel {
    
    static let sharedInstance = ElementModel()
    
    // TODO: remove this later probably
    public var viewModel : BoardViewModel?
    
    private var lines = [LineElement]()
    let lineSubject = PublishSubject<[LineElement]>()
    
    private var labels = [Stamp : LabelElement]()
    
    public func recieveInstruction(_ instruction: Instruction) {
        switch instruction.element {
        case .line (let lineToDraw):
            self.lineSubject.onNext([lineToDraw])
            self.addLine(lineToDraw)
        case .emoji:
            self.processLabel(instruction)
        }
    }
    private func addLine(_ newLine: LineElement) {
        
        
        self.lines.append(newLine)
        // TODO: remove drawLines call and have LineElements sent by sequence
//        self.viewModel?.drawLines([newLine])
    }
    
    private func processLabel(_ labelInstruction: Instruction) {
        
    }
    
        
        
    
}

// MARK: - Lines


struct LineElement {
    let line : Line
    let width : CGFloat
    let cap : CGLineCap
    let color : UIColor
}

struct Line {
    var segments = [LineSegment]()
    mutating func addSegment(_ newSegment: LineSegment){
        self.segments.append(newSegment)
    }
}

struct LineSegment {
    let firstPoint : CGPoint
    let secondPoint : CGPoint
}

// MARK: - Labels


struct LabelElement {
    let stamp : Stamp
    
}
