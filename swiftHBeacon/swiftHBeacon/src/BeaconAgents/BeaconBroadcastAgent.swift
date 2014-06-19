//
//  BeaconBroadcastAgent.swift
//  swiftHBeacon
//
//  Created by Duyen Hoa Ha on 16/06/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

let _singletonAgent  = BeaconBroadcastAgent();

class BeaconBroadcastAgent : NSObject, CBPeripheralManagerDelegate {
    //private use
    var canBroadcast : Bool = false
    var isBroadcasting : Bool = false
    
    var _broadcastBeacon : CLBeaconRegion? = nil
    var _broadcastBeaconDict : Dictionary<String, String>? = nil
    
    var myBTManager : CBPeripheralManager? = nil
    
    class var shareAgent : BeaconBroadcastAgent {
        return _singletonAgent;
    }
    
    class func shareClassAgent() -> BeaconBroadcastAgent {
        struct Static {
            static var instance: BeaconBroadcastAgent? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken, {
            Static.instance = BeaconBroadcastAgent()
            })
        
        return Static.instance!
    }
    
    init() {
        //create boardcast reagion &
        super.init()
        self.createBoardcastReagion(1)
    }
    
    func createBoardcastReagion(var idx:Int) {
        println("Test <" + __FUNCTION__ + ">")
        if let aBroadcast = _broadcastBeacon {
            println("Beacon has already created")
            return
        } else {
            var broadcastUUID : String = "A77A1B68-49A7-4DBF-914C-760D07FBB87B"
            let broadcastMajor:UInt16 = 1
            
            if idx == 1 {
                broadcastUUID = "A77A1B68-49A7-4DBF-914C-760D07FBB87B"
                _broadcastBeacon = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: broadcastUUID), major: broadcastMajor, minor: 1, identifier: kBeaconId1)
            } else {
                broadcastUUID = "054fe7b1-a48f-41ae-8b92-0c151863236c"
                _broadcastBeacon = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: broadcastUUID), major: broadcastMajor, minor: 1, identifier: "com.hbeacon.test2")
            }
        }
    }
    
    func createCBPeripheralManager() {
        println(__FUNCTION__)
        if let aBT = myBTManager {
            println("BT Peripheral has already created")
        } else {
            if let aBT = _broadcastBeacon {
                //do nothing
            } else {
                createBoardcastReagion(1)
            }
        }
    }
    
    //BT Manager
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println(__FUNCTION__)
        if peripheral.state == CBPeripheralManagerState.PoweredOn {
            println("Broadcasting...")
            
            //start broadcasting
            myBTManager!.startAdvertising(_broadcastBeaconDict)
        } else if peripheral.state == CBPeripheralManagerState.PoweredOff {
            println("Stopped")
            
            myBTManager!.stopAdvertising()
        } else if peripheral.state == CBPeripheralManagerState.Unsupported {
            println("Unsupported")
        } else if peripheral.state == CBPeripheralManagerState.Unauthorized {
            println("This option is not allowed by your application")
        }
     }
    
    //public function
    func enableBroadcast(shouldEnabled:Bool) {
        if shouldEnabled {
            if let aBT = myBTManager {
                //set delegate to this class
                myBTManager!.delegate = self
                if myBTManager!.state == CBPeripheralManagerState.PoweredOn {
                    //re-broadcast
                    myBTManager!.startAdvertising(_broadcastBeaconDict)
                } else {
                    NSLog("cannot re-broadcast", nil)
                }
            } else {
                //enable broadcast by starting the Bluetooth
                myBTManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
            }
        } else {
            //disable broadcast
            if let aBT = myBTManager {
                myBTManager!.stopAdvertising()
                myBTManager!.delegate = nil
            }
        }
    }
}

