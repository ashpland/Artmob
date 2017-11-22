//
//  Messages.swift
//  Whiteboard
//
//  Created by Aaron Johnson on 2017-11-21.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit

//MARK: Line

class LineMessage:NSObject, NSCoding{
    var segmentsData:Array<Array<CGFloat>>!
    var colorData:Int!
    var capData:Int!
    var widthData:CGFloat!
    var userData:String!
    var timestampData:String!
    var currentHash:Int!
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
        currentHash = 0
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
        aCoder.encode(self.currentHash, forKey: "hash")
    }
    required init?(coder aDecoder: NSCoder) {
        segmentsData = aDecoder.decodeObject(forKey: "segments") as! Array<Array<CGFloat>>
        colorData = aDecoder.decodeObject(forKey: "color") as! Int
        capData = aDecoder.decodeObject(forKey: "cap") as! Int
        widthData = aDecoder.decodeObject(forKey: "width") as! CGFloat
        userData = aDecoder.decodeObject(forKey: "user") as! String
        timestampData = aDecoder.decodeObject(forKey: "timestamp") as! String
        currentHash = aDecoder.decodeObject(forKey: "hash") as! Int
    }
}


//MARK: Label
class LabelMessage:NSObject, NSCoding{
    var pos: CGPoint!
    var text: String!
    var size: CGRect!
    var rotation:Float!
    var userData:String!
    var timestampData:String!
    var userRef:String!
    var timestampRef:String!
    var currentHash:Int!
    
    override init() {
        super.init()
    }
    init(instruction: Instruction){
        guard let labelElement = instruction.element.labelElement else {
            //bad things
            return
        }
        pos = labelElement.pos
        text = labelElement.text
        size = labelElement.size
        rotation = labelElement.rotation
        userData = instruction.stamp.user
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timestampData = formatter.string(from: instruction.stamp.timestamp)
        timestampRef = formatter.string(from: (instruction.type.stamp?.timestamp)!)
        userRef = instruction.type.stamp?.user
        currentHash = 0
    }
    func toInstruction() -> Instruction{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: timestampData) as! Date
        var type:InstructionType!
        if timestampRef == ""{
            type = .new
        } else if text == ""{
            type = .delete(Stamp(user: userRef, timestamp: formatter.date(from: timestampRef)!))
        } else {
            type = .edit(Stamp(user: userRef, timestamp: formatter.date(from: timestampRef)!))
        }
        
        let labelElement = LabelElement(pos: pos, text: text, size: size, rotation: rotation)
        let payload:InstructionPayload = .label(labelElement)
        return Instruction(type: type, element: payload, stamp: Stamp(user: userData, timestamp: date))
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.pos, forKey: "pos")
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.size, forKey: "size")
        aCoder.encode(self.rotation, forKey: "rotation")
        aCoder.encode(self.userData, forKey: "user")
        aCoder.encode(self.timestampData, forKey: "timestamp")
        aCoder.encode(self.userRef, forKey: "userRef")
        aCoder.encode(self.timestampRef, forKey: "timestampRef")
        aCoder.encode(self.currentHash, forKey: "hash")
    }
    required init?(coder aDecoder: NSCoder) {
        pos = aDecoder.decodeObject(forKey: "pos") as! CGPoint
        text = aDecoder.decodeObject(forKey: "text") as! String
        size = aDecoder.decodeObject(forKey: "size") as! CGRect
        rotation = aDecoder.decodeObject(forKey: "rotation") as! Float
        userData = aDecoder.decodeObject(forKey: "user") as! String
        timestampData = aDecoder.decodeObject(forKey: "timestamp") as! String
        userRef = aDecoder.decodeObject(forKey: "userRef") as! String
        timestampRef = aDecoder.decodeObject(forKey: "timestampRef") as! String
        currentHash = aDecoder.decodeObject(forKey: "hash") as! Int
    }
}
