////
////  MPCHandler.swift
////  BattleShip
////
////  Created by Aaron Johnson on 2017-10-30.
////  Copyright © 2017 Aaron Johnson. All rights reserved.
////
//
//import UIKit
//import MultipeerConnectivity
//
//class MPCHandler: NSObject, MCSessionDelegate{
//    //MARK: Properties
//    var peerID:MCPeerID!
//    var session:MCSession!
//    var browser:MCBrowserViewController!
//    var advertiser:MCAdvertiserAssistant? = nil
//
//    var state:MCSessionState!
//    
//    lazy var instructionIn : Instruction = {
//        let stamp = Stamp(user: "User", timestamp: Date())
//        let lineSegment = LineSegment(firstPoint: CGPoint(x: 0, y: 0), secondPoint: CGPoint(x: 100, y: 100))
//        let line = Line(segments: [lineSegment])
//        let element = LineElement(line: line, width: 0.5, cap: .round, color: UIColor.black)
//        let madeInstruction = Instruction(type: .new, element: .line(element), stamp: stamp)
//        return madeInstruction
//    }()
//
//    var instructionOut : Instruction!
//
//    //MARK: Setup
//    func setupPeerWithDisplayName (displayName:String){
//        peerID = MCPeerID(displayName: displayName)
//    }
//    func setupSession(){
//        session = MCSession(peer:peerID)
//        session.delegate = self
//    }
//    func setupBrowser(){
//        browser = MCBrowserViewController(serviceType:"Collaborative-Canvas", session: session)
//    }
//    func advertiseSelf(advertise:Bool){
//        if advertise{
//            advertiser = MCAdvertiserAssistant(serviceType:"Collaborative-Canvas", discoveryInfo: nil, session: session)
//            advertiser!.start()
//        } else {
//            advertiser!.stop()
//            advertiser = nil
//        }
//    }
//
//    //MARK: Send message
//    func sendInstruction(instruction:Instruction){
//        let messageDict = ["message":message, "player":UIDevice.current.name] as [String : Any]
//        let messageData = try! JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
//        try! session.send(messageData, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
//    }
//
//    //MARK: MCSessionDelegate
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        self.state = state
//    }
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        let userInfo = ["data":data,"peerID":peerID] as [String : Any]
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: NSNotification.Name("MPC_DidReceiveDataNotification"), object: nil, userInfo: userInfo)
//            print("data")
//        }
//    }
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
//    }
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
//    }
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//    }
//
//}

