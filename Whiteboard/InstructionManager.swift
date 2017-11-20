//
//  InstructionManager.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import RxSwift

class InstructionManager {

    static let sharedInstance = InstructionManager()

    private var instructionStore = [Instruction]()
    let newInstructions = PublishSubject<Instruction>()
    let broadcastInstructions = PublishSubject<Instruction>()
    private let disposeBag = DisposeBag()

    // MARK: - Methods

    class func subscribeToInstructionsFrom(_ newPublishSubject: PublishSubject<Instruction>) {
        newPublishSubject.subscribe(onNext: { instruction in
            InstructionManager.sharedInstance.newInstruction(instruction)
        }).disposed(by: InstructionManager.sharedInstance.disposeBag)
    }

    private func newInstruction(_ newInstruction: Instruction) {
        if self.instructionStore.isEmpty ||
            newInstruction.stamp > self.instructionStore.last!.stamp {
            self.instructionStore.append(newInstruction)
            self.newInstructions.onNext(newInstruction)
            self.broadcastInstructions.onNext(newInstruction)
            return
        } else {
            for (index, currentInstruction) in self.instructionStore.lazy.reversed().enumerated() {
                guard newInstruction.stamp != currentInstruction.stamp else {
                    return
                }
                if newInstruction.stamp > currentInstruction.stamp {
                    self.instructionStore.insert(newInstruction, at: self.instructionStore.count - index)
                    self.broadcastInstructions.onNext(newInstruction)

                    switch newInstruction.element {
                    case .line:
                        self.refreshLines()
                        return
                    case .emoji:
                        return
                    }
                }
            }
        }
    }

    private func refreshLines() {
        let lineInstructions = self.instructionStore.filter { if case .line = $0.element { return true }; return false}
        ElementModel.sharedInstance.refreshLines(from: lineInstructions)
    }
}

// MARK: - Instruction components

struct Instruction {
    let type: InstructionType
    let element: InstructionPayload
    let stamp: Stamp
}

enum InstructionType {
    case new
    case edit(Stamp)
    case delete(Stamp)
}

enum InstructionPayload {
    case line (LineElement)
    case emoji (LabelElement)

    var lineElement: LineElement? {
        guard case .line(let value) = self else {
            return nil
        }
        return value
    }
}

struct Stamp: Comparable, Hashable {
    var hashValue: Int {
            let timeHash = self.timestamp.hashValue
            let userHash = self.user.hashValue
            return timeHash ^ userHash &* 16777619
    }

    static func < (lhs: Stamp, rhs: Stamp) -> Bool {
        if lhs.timestamp < rhs.timestamp {
            return true
        }
        if lhs.timestamp == rhs.timestamp && lhs.user < rhs.user {
            return true
        }
        return false
    }

    static func == (lhs: Stamp, rhs: Stamp) -> Bool {
        return ((lhs.user == rhs.user) && (lhs.timestamp == rhs.timestamp))
    }

    let user: String
    let timestamp: Date
}

//MARK: Instruction to data

class lineMessage:NSObject, NSCoding{
    var segmentsData = Array<Array<CGPoint>>()
    var color = Int()
    var cap = Int()
    var width = CGFloat()
    var user = String()
    var timestamp = String()
    
    func fromInstruction(instruction: Instruction){
        guard let lineElement = instruction.element.lineElement else {
            //bad things
        }
        for segment:LineSegment in lineElement.line.segments{
            segmentsData.append([segment.firstPoint, segment.secondPoint])
        }
        switch lineElement.color{
        case UIColor.black:
            color = 1
            break
        case UIColor.blue:
            color = 2
            break
        default:
            color = 0
        }
        switch lineElement.cap{
        case .butt:
            cap = 0
        case .round:
            cap = 1
        case .square:
            cap = 2
        }
        width = lineElement.width
        user = instruction.stamp.user
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timestamp = formatter.string(from: instruction.stamp.timestamp)
    }
    func toInstruction() -> Instruction{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: timestamp)
        var line = Line()
        for segment:Array<CGPoint> in segmentsData{
            line = Line(and: LineSegment(firstPoint: segment.first!, secondPoint: segment.last!))
        }
        var elementColor = UIColor()
        switch color{
        case 1:
            elementColor = UIColor.black
            break
        case 2:
            elementColor = UIColor.blue
            break
        default:
            elementColor = UIColor.white
        }
        var elementCap = CGLineCap(rawValue: 0)
        switch cap{
        case 0:
            elementCap = .butt
        case 1:
            elementCap = .round
        case 2:
            elementCap = .square
        default:
            elementCap = .round
        }
        let lineElement = LineElement(line: line, width: width, cap: elementCap!, color: elementColor)
        let payload:InstructionPayload = .line(lineElement)
        return Instruction(type: .new, element: payload, stamp: Stamp(user: user, timestamp: date!))
    }
    func encode(with aCoder: NSCoder) {
        <#code#>
    }
    
    required init?(coder aDecoder: NSCoder) {
        <#code#>
    }
    
    
}
