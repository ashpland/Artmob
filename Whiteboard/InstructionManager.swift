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
    let instructionBroadcast = PublishSubject<Instruction>()
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Methods
    
    class func subscribeToInstructionsFrom(_ newPublishSubject: PublishSubject<Instruction>) {
        newPublishSubject.subscribe(onNext: { instruction in
            InstructionManager.sharedInstance.newInstruction(instruction)
        }).disposed(by: InstructionManager.sharedInstance.disposeBag)
    }
    
    private func newInstruction(_ newInstruction: Instruction) {
        // TODO: Instruction sequence processing happens here
        self.instructionStore.append(newInstruction)
        self.instructionBroadcast.onNext(newInstruction)
    }
}


// MARK: - Instruction components

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
