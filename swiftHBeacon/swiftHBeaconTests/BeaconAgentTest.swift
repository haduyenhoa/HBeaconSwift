//
//  BeaconAgentTest.swift
//  swiftHBeacon
//
//  Created by Duyen Hoa Ha on 16/06/2014.
//  Copyright (c) 2014. All rights reserved.
//

import Foundation
import XCTest

class BeaconAgentTest : XCTestCase {
    override func setUp()  {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func createBroadcastAgent() -> BeaconBroadcastAgent {
        return BeaconBroadcastAgent.shareAgent
    }
    
    func createReceiverAgent() -> BeaconReceiveAgent {
        return BeaconReceiveAgent.shareClassAgent()
    }
    
    func testAgentsCreated() {
        XCTAssertNotNil(createBroadcastAgent(), "Cannot create an instance")
        XCTAssertNotNil(createReceiverAgent(), "Cannot create singleton")
    }
    
    func testAgentsAreTheSame() {
        XCTAssertTrue(createBroadcastAgent() === createBroadcastAgent())
        XCTAssertTrue(createReceiverAgent() === createReceiverAgent())
    }
    
    func testBroadcastRegionCreated() {
        BeaconBroadcastAgent.shareClassAgent().createBoardcastReagion(1)
        XCTAssertNotNil(BeaconBroadcastAgent.shareClassAgent()._broadcastBeacon, "Failed to create beacon")
        XCTAssertEqualObjects(BeaconBroadcastAgent.shareClassAgent()._broadcastBeacon!.proximityUUID.UUIDString, "A77A1B68-49A7-4DBF-914C-760D07FBB87B", "this is not what I want")
    }
    
}
