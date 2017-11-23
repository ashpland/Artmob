//
//  InstructionComponents.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-23.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias InstructionStoreHash = Int

struct InstructionAndHashBundle {
    let instruction: Instruction
    let hash: InstructionStoreHash?
}

struct HashAndSender {
    let hash: InstructionStoreHash
    let sender: MCPeerID
}

struct Instruction {
    let type: InstructionType
    let element: InstructionPayload
    let stamp: Stamp
}

enum InstructionType {
    case new
    case edit(Stamp)
    case delete(Stamp)
    var stamp: Stamp? {
        guard case .edit(let value) = self else {
            return nil
        }
        guard case .delete(value) = self else {
            return nil
        }
        return value
    }
}

enum InstructionPayload {
    case line (LineElement)
    case label (LabelElement)
    
    var lineElement: LineElement? {
        guard case .line(let value) = self else {
            return nil
        }
        return value
    }
    var labelElement: LabelElement? {
        guard case .label(let value) = self else {
            return nil
        }
        return value
    }
}

struct StampsAndSender {
    let stamps: Array<Stamp>
    let sender: MCPeerID
}

struct Stamp: Comparable, Hashable {
    let user: MCPeerID
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
        if lhs.timestamp == rhs.timestamp && lhs.user.displayName < rhs.user.displayName {
            return true
        }
        return false
    }
    
    static func == (lhs: Stamp, rhs: Stamp) -> Bool {
        return ((lhs.user == rhs.user) && (lhs.timestamp == rhs.timestamp))
    }
}


extension Array where Element == Instruction
{
    var hashValue: InstructionStoreHash {
        return self.stamps.hashValue
    }
    
    var stamps: Array<Stamp> {
        return self.map({ $0.stamp })
    }
    
    func instruction(for stamp: Stamp) -> Instruction? {
        return self.filter{$0.stamp == stamp}.first
    }
    
    
    //helper method for testing
    var withNilHash: Array<InstructionAndHashBundle> {
        return self.map{InstructionAndHashBundle(instruction: $0, hash: nil)}
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
