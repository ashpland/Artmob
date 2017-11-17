//
//  InstructionManager.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation

class InstructionManager {
    
    static let sharedInstance = InstructionManager()
    let elementModel = ElementModel.sharedInstance
    
    private var instructions = [Instruction]()
    //make this a subject later
    
    
    func addLine(_ element: LineElement) {
        self.newInstruction(type: .new, element: .line(element))
    }
    
    private func newInstruction(type: InstructionType, element: InstructionPayload) {
        let stamp = Stamp(user: "User", timestamp: Date())
        let newInstruction = Instruction(type: type, element: element, stamp: stamp)
        self.instructions.append(newInstruction)
        
        elementModel.recieveInstruction(newInstruction)
        
    }
    
}

struct Instruction {
    let type : InstructionType
    let element : InstructionPayload
    let stamp : Stamp
}

enum InstructionType {
    case new
    case edit(Stamp)
    case delete(Stamp)
}

enum InstructionPayload {
    case line (LineElement)
    case emoji (LabelElement)
}

struct Stamp: Comparable, Hashable {
    var hashValue: Int {
        get {
            let timeHash = self.timestamp.hashValue
            let userHash = self.user.hashValue
            return timeHash ^ userHash &* 16777619
        }
    }
    
    static func <(lhs: Stamp, rhs: Stamp) -> Bool {
        if (lhs.timestamp < rhs.timestamp) {
            return true
        }
        if (lhs.timestamp == rhs.timestamp && lhs.user < rhs.user) {
            return true
        }
        return false
    }
    
    static func ==(lhs: Stamp, rhs: Stamp) -> Bool {
        return ((lhs.user == rhs.user) && (lhs.timestamp == rhs.timestamp))
    }
    
    
    
    let user : String
    let timestamp : Date
    
    
}
