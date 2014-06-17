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
    
    func createAnInstance() -> BeaconBroadcastAgent {
        return BeaconBroadcastAgent();
    }
    
    func createSingleton() -> BeaconBroadcastAgent {
        return BeaconBroadcastAgent.shareAgent
    }
    
    func testSingletonCreated() {
        XCTAssertNotNil(createAnInstance(), "Cannot create an instance")
        XCTAssertNotNil(createSingleton(), "Cannot create singleton")
    }
    
    func testSingletonsAreTheSame() {
        var s1 = BeaconBroadcastAgent.shareAgent
        var s2 = BeaconBroadcastAgent.shareAgent
        XCTAssertTrue(s1 === s2)
    }
    
    func testSingletonsAreTheSame2() {
        var s1 = BeaconBroadcastAgent.shareClassAgent()
        var s2 = BeaconBroadcastAgent.shareClassAgent()
        XCTAssertTrue(s1 === s2)
    }
    
}
