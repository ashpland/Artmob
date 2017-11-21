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
    let broadcastInstructions = PublishSubject<InstructionAndHash>()
    private let disposeBag = DisposeBag()

    // MARK: - Methods

    class func subscribeToInstructionsFrom(_ newObservable: Observable<InstructionAndHash>) {
        newObservable.subscribe(onNext: { instructionAndHash in
            InstructionManager.sharedInstance.newInstructionAndHash(instructionAndHash)
        }).disposed(by: InstructionManager.sharedInstance.disposeBag)
    }
    
    internal func resetInstructionStore() {
        self.instructionStore = [Instruction]()
    }
    
    private func newInstructionAndHash(_ new: InstructionAndHash) {
        self.newInstruction(new.0)
        
        if let theirHash = new.1 {
            if self.instructionStore.map({ $0.stamp }).hashValue != theirHash {
                // get their stamp array
            }
        }
        
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

typealias InstructionStoreHash = Int
typealias InstructionAndHash = (Instruction, InstructionStoreHash?)

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
    let user: String
    let timestamp: Date

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
}

extension Array where Element:Hashable
{
    var hashValue: Int {
        return self.reduce(16777619) {$0 ^ $1.hashValue}
    }
    
    func elementsNotIn(_ otherArray: Array<Element>) -> Array<Element> {
        return otherArray.filter{!Set(self).contains($0)}
    }
    
    static func == (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

//extension Array where Element:Instruction
//{
//    var
//}





//MARK: Instruction to data

class LineMessage:NSObject, NSCoding{
    var segmentsData:Array<Array<CGFloat>>!
    var colorData:Int!
    var capData:Int!
    var widthData:CGFloat!
    var userData:String!
    var timestampData:String!
    override init() {
        super.init()
    }
    init(instruction: Instruction){
        guard let lineElement = instruction.element.lineElement else {
            //bad things
            return
        }
        segmentsData = Array<Array<CGFloat>>()
        for segment:LineSegment in lineElement.line.segments{
            segmentsData.append([segment.firstPoint.x, segment.firstPoint.y, segment.secondPoint.x, segment.secondPoint.y])
        }
        switch lineElement.color{
        case UIColor.black:
            colorData = 1
            break
        case UIColor.blue:
            colorData = 2
            break
        default:
            colorData = 0
        }
        switch lineElement.cap{
        case .butt:
            capData = 0
        case .round:
            capData = 1
        case .square:
            capData = 2
        }
        widthData = lineElement.width
        userData = instruction.stamp.user
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timestampData = formatter.string(from: instruction.stamp.timestamp)
    }
    func toInstruction() -> Instruction{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: timestampData)
        var line = Line()
        for segment:Array<CGFloat> in segmentsData{
            line = Line(with: line, and: LineSegment(firstPoint:CGPoint(x: segment[0], y: segment[1]), secondPoint: CGPoint(x: segment[2], y: segment[3])))
        }
        var elementColor = UIColor()
        switch colorData{
        case 1:
            elementColor = UIColor.black
            break
        case 2:
            elementColor = UIColor.blue
            break
        default:
            elementColor = UIColor.black
        }
        var elementCap = CGLineCap(rawValue: 0)
        switch capData{
        case 0:
            elementCap = .butt
        case 1:
            elementCap = .round
        case 2:
            elementCap = .square
        default:
            elementCap = .round
        }
        let lineElement = LineElement(line: line, width: widthData, cap: elementCap!, color: elementColor)
        let payload:InstructionPayload = .line(lineElement)
        return Instruction(type: .new, element: payload, stamp: Stamp(user: userData, timestamp: date!))
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.segmentsData, forKey: "segments")
        aCoder.encode(self.colorData, forKey: "color")
        aCoder.encode(self.capData, forKey: "cap")
        aCoder.encode(self.widthData, forKey: "width")
        aCoder.encode(self.userData, forKey: "user")
        aCoder.encode(self.timestampData, forKey: "timestamp")
    }
    required init?(coder aDecoder: NSCoder) {
        segmentsData = aDecoder.decodeObject(forKey: "segments") as! Array<Array<CGFloat>>
        colorData = aDecoder.decodeObject(forKey: "color") as! Int
        capData = aDecoder.decodeObject(forKey: "cap") as! Int
        widthData = aDecoder.decodeObject(forKey: "width") as! CGFloat
        userData = aDecoder.decodeObject(forKey: "user") as! String
        timestampData = aDecoder.decodeObject(forKey: "timestamp") as! String
    }
}
