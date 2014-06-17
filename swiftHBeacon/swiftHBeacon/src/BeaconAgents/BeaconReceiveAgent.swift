//
//  BeaconReceiveAgent.swift
//  swiftHBeacon
//
//  Created by Duyen Hoa Ha on 17/06/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation


let kBeaconId = "com.hbeacon.test"

protocol BeaconReceiverAgentDelegate {
    mutating func newMessage (msg:String)
    mutating func beaconUpdated()
}

class BeaconReceiveAgent : NSObject, CLLocationManagerDelegate {
    let locationManager : CLLocationManager = CLLocationManager()
    var delegate : BeaconReceiverAgentDelegate? //notify my delegate -> TODO: use an array of delegate
    
    var dictBeaconsToListen : Dictionary<String, CLBeaconRegion> //uuid & beacon to listen
    var dictBeaconsInRange : Dictionary<String, CLBeaconRegion> //uuid & beacon currently in range
    var dictLastVisitedBeacons : Dictionary<String, NSDate> //uuid & last visited time (moment when beacon was out of range

    var isReceiving : Bool = false
    
    init()  {
        //these inits must be called before super.init()
        self.dictBeaconsToListen = Dictionary()
        self.dictBeaconsInRange = Dictionary()
        self.dictLastVisitedBeacons = Dictionary()
        super.init()
        
        self.locationManager.delegate = self //this must be called after super init //start received notifiation from here
    }
    
    class func shareClassAgent() -> BeaconReceiveAgent {
        struct Static {
            static var instance: BeaconReceiveAgent? = nil
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken, {
            Static.instance = BeaconReceiveAgent()
            })
        
        return Static.instance!
    }
    
    func startListening(beaconUUIDs : Array<NSUUID>) {
        //verify if can receive
        if CLLocationManager.isMonitoringAvailableForClass(NSClassFromString("CLBeaconRegion")) {
            //we can listen now
        } else {
            isReceiving = false
            return
        }
        
        //
        stopListening()
        
        for beaconUUID in beaconUUIDs {
            //create a beacon
            var aBeacon = CLBeaconRegion(proximityUUID: beaconUUID, identifier: kBeaconId)
            
            //start monitoring
            self.locationManager.startMonitoringForRegion(aBeacon)
            self.locationManager.startRangingBeaconsInRegion(aBeacon)
            
            //add to dict
            self.dictBeaconsToListen[beaconUUID.UUIDString] = aBeacon
        }
    }
    
    func stopListening() {
        for (anUUID) in self.dictBeaconsToListen.keys {
            //first, stop monitoring. it's not neccessary to add to last visisted range. this is done by another function
            stopListening(anUUID);
        }
        
        self.dictBeaconsToListen.removeAll(keepCapacity: false)
    }
    
    func stopListening(anUUID : String?) {
        if let uuid = anUUID {
            if let aBeaconRegion = self.dictBeaconsToListen[uuid] {
                self.locationManager.stopRangingBeaconsInRegion(aBeaconRegion)
                self.locationManager.stopMonitoringForRegion(aBeaconRegion)
                
                //notice delegate
                if let aDelegate = delegate {
                    println("Stop listening to \(uuid)")
//                    aDelegate.newMessage("Stop listening to \(uuid)")
                }
            } else {
                //this beacon is not exist in current dict
            }
        }
    }
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println(__FUNCTION__)
        println("Entering region \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: AnyObject[]!, inRegion region: CLBeaconRegion!) {
        
    }
}

