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

    class func subscribeToInstructionsFrom(_ newObservable: Observable<Instruction>) {
        newObservable.subscribe(onNext: { instruction in
            InstructionManager.sharedInstance.newInstruction(instruction)
        }).disposed(by: InstructionManager.sharedInstance.disposeBag)
    }
    
    internal func resetInstructionStore() {
        self.instructionStore = [Instruction]()
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

