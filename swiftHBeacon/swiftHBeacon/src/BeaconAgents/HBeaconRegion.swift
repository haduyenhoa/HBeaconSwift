//
//  HBeaconRegion.swift
//  swiftHBeacon
//  My special beacon reagion
//  This class keep track of
//  Created by Duyen Hoa Ha on 17/06/2014.
//  Copyright (c) 2014 Duyen Hoa Ha. All rights reserved.
//

import Foundation
import CoreLocation

class HBeaconRegion {
    var beaconsInRegion : CLBeacon[]?
    var beaconRegion : CLBeaconRegion?
    
    func getNearestBeacon() -> CLBeacon? {
        var _nearestBeacon : CLBeacon?
        
        if let listBeacons = beaconsInRegion {
            for aBeacon in beaconsInRegion! {
                if let aB = _nearestBeacon {
                    if aB.accuracy > aBeacon.accuracy {
                        _nearestBeacon = aBeacon
                    }
                } else {
                    _nearestBeacon = aBeacon
                }
            }
        }
        
        return _nearestBeacon
    }
}