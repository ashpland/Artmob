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
    
    let lineSubject = PublishSubject<[LineElement]>()
    private var labels = [Stamp : LabelElement]()
    private let disposeBag = DisposeBag()
    
    init() {
        self.setupSubscriptions()
    }
    
    func setupSubscriptions() {
        let _ = InstructionManager.sharedInstance.instructionBroadcast
            .subscribe { event in
                switch event{
                case .next(let instruction):
                    switch instruction.element {
                    case .line(let lineToDraw):
                        self.lineSubject.onNext([lineToDraw])
                    case .emoji(_):
                        self.processLabel(instruction)
                    }
                    
                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed:
                    print("BoardViewModel Lines Subscription ended")

                }
        }.disposed(by: disposeBag)
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
