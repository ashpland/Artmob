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

    var lineSubject = BehaviorSubject<[LineElement]>(value: [LineElement]())
    private var labels = [Stamp: LabelElement]()
    private let disposeBag = DisposeBag()

    init() {
        self.setupSubscriptions()
    }

    private func setupSubscriptions() {
        _ = InstructionManager.sharedInstance.newInstructions
            .subscribe { event in
                switch event {
                case .next(let instruction):
                    switch instruction.element {
                    case .line(let lineToDraw):
                        self.lineSubject.onNext([lineToDraw])
                    case .emoji:
                        self.processLabel(instruction)
                    }

                case .error(let error):
                    fatalError(error.localizedDescription)
                case .completed:
                    print("BoardViewModel Lines Subscription ended")

                }
        }.disposed(by: disposeBag)
    }

    public func refreshLines(from lineInstructions: [Instruction]) {
        let lineElements = lineInstructions.map { return $0.element.lineElement! }
        self.lineSubject.onCompleted()
        self.lineSubject = BehaviorSubject(value: lineElements)
    }

    private func processLabel(_ labelInstruction: Instruction) {

    }
}

// MARK: - Lines

struct LineElement {
    let line: Line
    let width: CGFloat
    let cap: CGLineCap
    let color: UIColor
}

struct Line {
    let segments: [LineSegment]

    init() {self.segments = [LineSegment]()}

    init(with line: Line = Line(), and newSegment: LineSegment) {
        self.segments = line.segments + [newSegment]
    }

    static func + (left: Line, right: LineSegment) -> Line {
        return Line(with: left, and: right)
    }
}

struct LineSegment {
    let firstPoint: CGPoint
    let secondPoint: CGPoint
}

// MARK: - Labels

struct LabelElement {
    let stamp: Stamp
}
