//
//  MPCHandler.swift
//  BattleShip
//
//  Created by Aaron Johnson on 2017-10-30.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import RxSwift

class MPCHandler: NSObject, MCSessionDelegate{
    static let sharedInstance = MPCHandler()
    //MARK: Properties
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant? = nil

    var state:MCSessionState!
    
    let recievedInstruction = PublishSubject<Instruction>()
    
    //MARK: Setup
    func setupSubscribe(){
        InstructionManager.subscribeToInstructionsFrom(self.recievedInstruction)
        
        _ = InstructionManager.sharedInstance.newInstructions
            .subscribe(onNext: { (instruction) in
                if self.state == MCSessionState.connected {
                    self.sendLine(lineMessage: LineMessage(instruction: instruction))
                }
        })
    }
    
    func setupPeerWithDisplayName (displayName:String){
        peerID = MCPeerID(displayName: displayName)
    }
    func setupSession(){
        session = MCSession(peer:peerID)
        session.delegate = self
    }
    func setupBrowser(){
        browser = MCBrowserViewController(serviceType:"draw", session: session)
    }
    func advertiseSelf(advertise:Bool){
        if advertise{
            advertiser = MCAdvertiserAssistant(serviceType:"draw", discoveryInfo: nil, session: session)
            advertiser!.start()
        } else {
            advertiser!.stop()
            advertiser = nil
        }
    }

    //MARK: Send message
//    func sendInstruction(instruction:Instruction){
//        let messageDict = ["message":message, "player":UIDevice.current.name] as [String : Any]
//        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
//        try! session.send(messageData, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
//    }
    func sendLine(lineMessage: LineMessage){
        let messageData = NSKeyedArchiver.archivedData(withRootObject: lineMessage)
        try! session.send(messageData, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
    }

    //MARK: MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.state = state
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let lineMessage = NSKeyedUnarchiver.unarchiveObject(with: data) as! LineMessage
        let newInstruction = lineMessage.toInstruction()
        self.recievedInstruction.onNext(newInstruction)
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

}

