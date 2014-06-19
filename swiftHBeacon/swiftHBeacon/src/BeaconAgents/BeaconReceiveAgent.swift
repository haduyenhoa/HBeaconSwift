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

let kBeaconId1 = "com.hbeacon.test1"
let kBeaconId2 = "com.hbeacon.test2"

protocol BeaconReceiverAgentDelegate {
    func newMessage (msg:String)
    func beaconUpdated()
}

class BeaconReceiveAgent : NSObject, CLLocationManagerDelegate {
    let locationManager : CLLocationManager = CLLocationManager()
    var delegate : BeaconReceiverAgentDelegate? //notify my delegate -> TODO: use an array of delegate
    
    var dictBeaconsToListen : Dictionary<String, CLBeaconRegion> //uuid & beacon to listen
    var dictBeaconsInRange : Dictionary<String, AnyObject[]> //uuid & CLBeacon[] currently in range
    var dictLastVisitedBeacons : Dictionary<String, NSDate> //uuid & last visited time (moment when beacon was out of range

    var isReceiving : Bool = false
    var receiverOn : Bool = false
    
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
            var aBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: kBeaconId1)
            
            //start monitoring
            self.locationManager.startMonitoringForRegion(aBeaconRegion)
            self.locationManager.startRangingBeaconsInRegion(aBeaconRegion)
            self.locationManager.startMonitoringVisits() //is it necessary?
            
            //add to dict
            self.dictBeaconsToListen[beaconUUID.UUIDString] = aBeaconRegion
        }
        
        receiverOn = true
    }
    
    func pauseListening() {
        for (anUUID, aBeaconRegion) in self.dictBeaconsToListen {
            self.locationManager.stopRangingBeaconsInRegion(aBeaconRegion)
            self.locationManager.stopMonitoringForRegion(aBeaconRegion)
        }
    }

    func resumeListening() {
        for (anUUID, aBeaconRegion) in self.dictBeaconsToListen {
            self.locationManager.startRangingBeaconsInRegion(aBeaconRegion)
            self.locationManager.startMonitoringForRegion(aBeaconRegion)
        }
    }
    
    func stopListening() {
        for (anUUID) in self.dictBeaconsToListen.keys {
            //first, stop monitoring. it's not neccessary to add to last visisted range. this is done by another function
            stopListening(anUUID);
        }
        
        self.dictBeaconsToListen.removeAll(keepCapacity: false)
        self.dictBeaconsInRange.removeAll(keepCapacity: false)

        receiverOn = false
    }
    
    func stopListening(anUUID : String?) {
        if let uuid = anUUID {
            if let aBeaconRegion = self.dictBeaconsToListen[uuid] {
                self.locationManager.stopRangingBeaconsInRegion(aBeaconRegion)
                self.locationManager.stopMonitoringForRegion(aBeaconRegion)
                
                //notice delegate
                delegate?.newMessage("Stop listening to \(uuid)")
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
        println(__FUNCTION__)
        //update
        self.dictBeaconsInRange[region.proximityUUID.UUIDString] = beacons
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println(__FUNCTION__)
        //check if location service is enabled or not
        if !CLLocationManager.locationServicesEnabled() {
            if receiverOn {
                println("Cannot search for beacon. Please enable location service")
            }
            
            self.dictBeaconsInRange.removeAll(keepCapacity: false)
            
            //notify my delegate
            delegate?.beaconUpdated()
            return;
        }
        
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Authorized {
            if receiverOn {
                println("Cannot search for beacon. Location service does not authorize this application")
            }
            
            self.dictBeaconsInRange.removeAll(keepCapacity: false)
            
            //notify my delegate
            delegate?.beaconUpdated()
            return;
        }
        
        if receiverOn {
            //start searching
            delegate?.newMessage("Searching for beacon in region")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if receiverOn {
            //start ranging
            if let aBeaconRegion:CLBeaconRegion = region as? CLBeaconRegion {
                //search for beacon region in my listening dict
                if let regionEntered : CLBeaconRegion = self.dictBeaconsToListen[aBeaconRegion.proximityUUID.UUIDString] {
                    locationManager.startRangingBeaconsInRegion(regionEntered)
                }
            }
            
            //notify
            delegate?.beaconUpdated()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if self.receiverOn {
            if region is CLBeaconRegion {
                //remove from dictBeaconsInrange
                self.dictBeaconsInRange[(region as CLBeaconRegion).proximityUUID.UUIDString] = nil
                
                //notify update
                delegate?.beaconUpdated()
            } else {
                println("ignore cause this is not a CLBeaconRegion or we are not listening")
            }
        } else {
            println("ignore cause the receiver agent is off")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
        if region is CLBeaconRegion {
            //do nothing.
        } else {
            println("\(object_getClassName(region)) is not supported!")
            return
        }
        
        var stateString : String
        
        switch state {
        case CLRegionState.Inside :
            self.locationManager.startRangingBeaconsInRegion(region as CLBeaconRegion)
            stateString = "Inside"
        case CLRegionState.Outside:
            self.locationManager.stopMonitoringForRegion(region as CLBeaconRegion)
            stateString = "Outside"
        default :
            //do nothing
            stateString = "Unknown"
            break
        }
        
        println("State changed to '\(stateString)' for region \((region as CLBeaconRegion).proximityUUID)")
    }

    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        println(__FUNCTION__)
        println("Error: \(error.localizedDescription)")
    }

}

