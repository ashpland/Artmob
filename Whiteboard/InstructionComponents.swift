//
//  InstructionComponents.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-23.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// MARK: Instruction

struct Instruction {
    let type: InstructionType
    let element: InstructionPayload
    let stamp: Stamp
}

extension Instruction {
    func isFromSelf() -> Bool {
        return self.stamp.user == MPCHandler.sharedInstance.session.myPeerID
    }
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

// MARK: - Instruction Collections

extension Dictionary where Value == Instruction {
    var hashValue: InstructionStoreHash { return self.stamps.hashValue }

    var stamps: [Stamp] { return self.inOrder.map({ $0.stamp }) }

    var inOrder: [Instruction] {
        return self.map({ $1 })
            .sorted(by: { $0.stamp < $1.stamp })
    }
}

extension Array where Element == Instruction {
    var hashValue: InstructionStoreHash {
        return self.stamps.hashValue
    }

    var stamps: [Stamp] {
        return self.map({ $0.stamp })
    }

    func instruction(for stamp: Stamp) -> Instruction? {
        return self.filter {$0.stamp == stamp}.first
    }
}

extension Array where Element:Hashable {
    var hashValue: Int {
        return self.reduce(16777619) {$0 ^ $1.hashValue}
    }

    func elementsMissingFrom(_ otherArray: [Element]) -> [Element] {
        return otherArray.filter {!Set(self).contains($0)}
    }

    static func == (lhs: [Element], rhs: [Element]) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Stamp

struct Stamp {
    let user: MCPeerID
    let timestamp: Date
}

extension Stamp: Equatable {
    static func == (lhs: Stamp, rhs: Stamp) -> Bool {
        return ((lhs.user == rhs.user) && (lhs.timestamp == rhs.timestamp))
    }
}

extension Stamp: Comparable {
    static func < (lhs: Stamp, rhs: Stamp) -> Bool {
        if lhs.timestamp < rhs.timestamp {
            return true
        }
        if lhs.timestamp == rhs.timestamp && lhs.user.displayName < rhs.user.displayName {
            return true
        }
        return false
    }
}

extension Stamp: Hashable {
    var hashValue: Int {
        let timeHash = self.timestamp.hashValue
        let userHash = self.user.hashValue
        return timeHash ^ userHash &* 16777619
    }
}

// MARK: - Bundles

typealias InstructionStoreHash = Int

struct InstructionAndHashBundle {
    let instruction: Instruction
    let hash: InstructionStoreHash?
}

struct HashAndSender {
    let hash: InstructionStoreHash
    let sender: MCPeerID
}

struct StampsAndSender {
    let stamps: [Stamp]
    let sender: MCPeerID
}
