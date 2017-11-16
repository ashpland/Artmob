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
    
    private var instructions = [Instruction]()
    
    func addLine(_ element: LineElement) {
        self.newInstruction(type: .new, element: .line(element))
    }
    
    private func newInstruction(type: InstructionType, element: InstructionPayload) {
        let stamp = Stamp(user: "User", timestamp: Date())
        let newInstruction = Instruction(type: type, element: element, stamp: stamp)
        self.instructions.append(newInstruction)
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

struct Stamp {
    let user : String
    let timestamp : Date
}
