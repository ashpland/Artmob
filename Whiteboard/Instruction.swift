//
//  Instruction.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation

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
    case line
    case emoji
}

struct Stamp {
    let user : String
    let timestamp : Date
}
