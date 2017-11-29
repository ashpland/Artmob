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
    
    fileprivate var instructionStore = [Stamp: Instruction]()
    let newInstructions = PublishSubject<Instruction>()
    let broadcastInstructions = PublishSubject<InstructionAndHashBundle>()
    fileprivate let hashStream = PublishSubject<HashAndSender>()
    let stampsStream = PublishSubject<StampsAndSender>()
    let instructionRequests = PublishSubject<Stamp>()
    fileprivate let fullRefresh = PublishSubject<Bool>()
    fileprivate let helloPing = PublishSubject<InstructionAndHashBundle>()
    fileprivate let disposeBag = DisposeBag()
    fileprivate let peerManager: PeerManager = MPCHandler.sharedInstance
    
    // MARK: - Methods
    
    init() {
        let hashCheckInterval = 2.0
        
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
            .subscribe(onNext: { self.processInstructionRequests($0) })
            .disposed(by: self.disposeBag)
        
        fullRefresh.throttle(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in self.refreshLines() })
            .disposed(by: self.disposeBag)
        
        helloPing.debounce(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { mostRecentBundle in
                self.helloPing.onNext(mostRecentBundle)
                self.broadcastInstructions.onNext(mostRecentBundle)})
            .disposed(by: self.disposeBag)
    }
    
    
    
    class func subscribeToInstructionsFrom(_ newObservable: Observable<InstructionAndHashBundle>) {
        newObservable.subscribe(onNext:
            { InstructionManager.sharedInstance.new(instructionAndHash: $0) })
            .disposed(by: InstructionManager.sharedInstance.disposeBag)
    }
    
    internal func resetInstructionStore() {
        self.instructionStore = [Stamp: Instruction]()
    }
    
    private func new(instructionAndHash bundle: InstructionAndHashBundle) {
        self.newInstruction(bundle.instruction)
        
        if let theirHash = bundle.hash {
            if bundle.instruction.stamp.user != MPCHandler.sharedInstance.peerID {
                self.hashStream.onNext(HashAndSender(hash: theirHash,
                                                     sender: bundle.instruction.stamp.user))
            }
        }
    }

    private func newInstruction(_ newInstruction: Instruction) {
        if self.instructionStore.contains(where:
            {$0.key == newInstruction.stamp})
            { return }
        
        self.instructionStore[newInstruction.stamp] = newInstruction
        self.newInstructions.onNext(newInstruction)
        let newBundle = InstructionAndHashBundle(instruction: newInstruction,
                                                 hash: self.instructionStore.hashValue)

        self.helloPing.onNext(newBundle)

        if newInstruction.isFromSelf() {
            self.broadcastInstructions.onNext(newBundle)
        }
        else { self.fullRefresh.onNext(true) }
    }
    
    
    
    internal func refreshLines() {
        var lineInstructions = self.instructionStore.inOrder
            .filter { if case .line = $0.element { return true }; return false}
        if lineInstructions.count > 0 {
            //full redraw is triggered by the last instruction being duplicated
            lineInstructions.append(lineInstructions.last!)
            ElementModel.sharedInstance.drawMultipleLines(from: lineInstructions)
        }
    }
    
    internal func check(hash: InstructionStoreHash, from peer:MCPeerID, with peerManager: PeerManager) {
        if self.instructionStore.hashValue != hash {
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
            if let instruction = self.instructionStore[stamp] {
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



