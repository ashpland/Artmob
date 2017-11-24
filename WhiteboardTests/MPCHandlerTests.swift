//
//  MPCHandlerTests.swift
//  WhiteboardTests
//
//  Created by Andrew on 2017-11-22.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import XCTest
import MultipeerConnectivity
@testable import Whiteboard


class FakeFriendManager: PeerManager {
    let anotherPeer = MCPeerID(displayName: "Someone Else")
    var instructionRequested = false
    func requestInstructions(from peer: MCPeerID, for stampsArray: [Stamp], with hash: InstructionStoreHash) {
        instructionRequested = true
    }
}


class MPCHandlerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //test peerFromUser
    
    
}
