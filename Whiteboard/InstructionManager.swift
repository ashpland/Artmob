//
//  InstructionManager.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-16.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import Foundation
import RxSwift
import MultipeerConnectivity


class InstructionManager {
    
    static let sharedInstance = InstructionManager()
    
    private var instructionStore = [Instruction]()
    let newInstructions = PublishSubject<Instruction>()
    let broadcastInstructions = PublishSubject<InstructionAndHashBundle>()
    private let hashStream = PublishSubject<HashAndSender>()
    let stampsStream = PublishSubject<StampsAndSender>()
    let instructionRequests = PublishSubject<Stamp>()
    private let disposeBag = DisposeBag()
    private let peerManager: PeerManager = MPCHandler.sharedInstance
    
    // MARK: - Methods
    
    init() {
        let hashCheckInterval = 10.0
        
        hashStream.throttle(hashCheckInterval, scheduler: MainScheduler.instance)
            .subscribe(onNext: { self.check(hash: $0.hash,
                                            from: $0.sender,
                                            with: self.peerManager) })
            .disposed(by: self.disposeBag)
        
        stampsStream
            .subscribe(onNext: { self.sync(theirInstructions: $0.stamps,
                                           from: $0.sender,
                                           with: self.peerManager)})
            .disposed(by: self.disposeBag)
        
        
        instructionRequests.buffer(timeSpan: 2.0, count: 50, scheduler: MainScheduler.instance)
            .subscribe(onNext: {self.processInstructionRequests($0)})
            .disposed(by: self.disposeBag)
        
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
        print("New Instruction")
        self.newInstruction(bundle.instruction)
        
        if let theirHash = bundle.hash {
            if bundle.instruction.stamp.user != MPCHandler.sharedInstance.peerID {
                print("Recieved Hash")

                self.hashStream.onNext(HashAndSender(hash: theirHash,
                                                     sender: bundle.instruction.stamp.user))
            }
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
            insertInstruction(newInstruction)
        }
    }
    
    fileprivate func insertInstruction(_ newInstruction: Instruction) {
        for (index, currentInstruction) in self.instructionStore.lazy.reversed().enumerated() {
            guard newInstruction.stamp != currentInstruction.stamp else {
                return
            }
            if newInstruction.stamp > currentInstruction.stamp {
                self.instructionStore.insert(newInstruction, at: self.instructionStore.count - index)
            }
            if index == instructionStore.count - 1 {
                self.instructionStore.insert(newInstruction, at: 0)
            }
        }
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
    
    internal func refreshLines() {
        let lineInstructions = self.instructionStore.filter { if case .line = $0.element { return true }; return false}
        ElementModel.sharedInstance.refreshLines(from: lineInstructions)
    }
    
    internal func check(hash: InstructionStoreHash, from peer:MCPeerID, with peerManager: PeerManager) {
        print("Checked Hash")
        if self.instructionStore.hashValue != hash {
            print("Hash conflict")
            peerManager.requestInstructions(from: peer,
                                            for: self.instructionStore.stamps,
                                            with: self.instructionStore.hashValue)
        }
    }
    
    internal func sync(theirInstructions: Array<Stamp>, from peer: MCPeerID, with peerManager: PeerManager) {
        
        let myInstructions = self.instructionStore.stamps        
        
        for instruction in theirInstructions.elementsMissingFrom(myInstructions) {
            self.instructionRequests.onNext(instruction)
        }
        
        if myInstructions.elementsMissingFrom(theirInstructions).count > 0 {
            peerManager.requestInstructions(from: peer,
                                            for: self.instructionStore.stamps,
                                            with: self.instructionStore.hashValue)
        }
    }
    
    internal func processInstructionRequests(_ requests: Array<Stamp>) {
        
        guard !requests.isEmpty else {return}
        
        let instructionStamps = Array(Set(requests))
        
        for stamp in instructionStamps {
            if let instruction = self.instructionStore.instruction(for: stamp) {
                let bundle = InstructionAndHashBundle(instruction: instruction,
                                                      hash: self.instructionStore.hashValue)
                self.broadcastInstructions.onNext(bundle)
            }
        }
    }
}

protocol PeerManager {
    func requestInstructions(from peer:MCPeerID, for stampsArray: [Stamp], with hash: InstructionStoreHash)
}
