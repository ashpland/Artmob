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
    let broadcastInstructions = PublishSubject<InstructionAndHashBundle>()
    private let hashStream = PublishSubject<HashAndSender>()
    let stampsStream = PublishSubject<StampsAndSender>()
    private let disposeBag = DisposeBag()

    // MARK: - Methods

    init() {
        let hashCheckInterval = 1.0
        let stampsCheckInterval = 1.0
        
        _ = hashStream.throttle(hashCheckInterval, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.check($0.hash, from: $0.sender)
            })
        _ = stampsStream.throttle(stampsCheckInterval, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.sync(theirInstructions: $0.stamps, from: $0.sender)
            })

    }
    
    
    
    class func subscribeToInstructionsFrom(_ newObservable: Observable<InstructionAndHashBundle>) {
        newObservable.subscribe(onNext: { bundle in
            InstructionManager.sharedInstance.new(instructionAndHash: bundle)
        }).disposed(by: InstructionManager.sharedInstance.disposeBag)
    }
    
    internal func resetInstructionStore() {
        self.instructionStore = [Instruction]()
    }
    
    private func new(instructionAndHash bundle: InstructionAndHashBundle) {
        self.newInstruction(bundle.instruction)
        
        if let theirHash = bundle.hash {
            self.hashStream.onNext(HashAndSender(hash: theirHash, 
                                                 sender: bundle.instruction.stamp.user))
        }
    }

    private func newInstruction(_ newInstruction: Instruction) {
        if self.instructionStore.isEmpty ||
            newInstruction.stamp > self.instructionStore.last!.stamp {
            self.instructionStore.append(newInstruction)
            self.newInstructions.onNext(newInstruction)
            let newBundle = InstructionAndHashBundle(instruction: newInstruction,
                                                     hash: self.instructionStore.hashValue)
            self.broadcastInstructions.onNext(newBundle)
            return
        } else {
            for (index, currentInstruction) in self.instructionStore.lazy.reversed().enumerated() {
                guard newInstruction.stamp != currentInstruction.stamp else {
                    return
                }
                if newInstruction.stamp > currentInstruction.stamp {
                    self.instructionStore.insert(newInstruction, at: self.instructionStore.count - index)
                    let newInstructionBundle = InstructionAndHashBundle(instruction: newInstruction, hash: self.instructionStore.hashValue)
                    self.broadcastInstructions.onNext(newInstructionBundle)

                    switch newInstruction.element {
                    case .line:
                        self.refreshLines()
                        return
                    case .label:
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
    
    internal func check(_ hash: InstructionStoreHash, from user:String) {
        if self.instructionStore.hashValue != hash {
            MPCHandler.sharedInstance.sendStamps(self.instructionStore.stamps,
                                                 to: user,
                                                 with: self.instructionStore.hashValue)
        }
    }
    
    internal func sync(theirInstructions: Array<Stamp>, from user: String) {
        let myInstructions = self.instructionStore.stamps
        
        for stamp in myInstructions.elementsNotIn(theirInstructions) {
            if let instruction = self.instructionStore.instruction(for: stamp) {
                let bundle = InstructionAndHashBundle(instruction: instruction,
                                                      hash: self.instructionStore.hashValue)
                self.broadcastInstructions.onNext(bundle)
            }
        }
        if theirInstructions.elementsNotIn(myInstructions).count > 0 {
            MPCHandler.sharedInstance.sendStamps(self.instructionStore.stamps,
                                                 to: user,
                                                 with: self.instructionStore.hashValue)
        }
    }
}

// MARK: - Instruction components

typealias InstructionStoreHash = Int

struct InstructionAndHashBundle {
    let instruction: Instruction
    let hash: InstructionStoreHash?
}

struct HashAndSender {
    let hash: InstructionStoreHash
    let sender: String
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
    let sender: String
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
