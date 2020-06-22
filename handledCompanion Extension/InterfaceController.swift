//
//  InterfaceController.swift
//  handledCompanion Extension
//
//  Created by Michael Williams on 6/12/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate, CLLocationManagerDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let retDict = message["message"] as! [String: Any]
        let coordy = CLLocationCoordinate2D(latitude: retDict["lat"] as! CLLocationDegrees, longitude: retDict["longit"] as! CLLocationDegrees)
        eventLocation = LocationModel(loc: coordy, dat: retDict["date"] as! Date, descrip: retDict["title"] as! String, veloc: retDict["speed"] as! Double)
        currentLocation = CLLocation(latitude: message["lat"] as! CLLocationDegrees, longitude: message["longit"] as! CLLocationDegrees)
        print(currentLocation.coordinate.latitude)
        print(currentLocation.coordinate.longitude)
        
        titleLabel.setText(eventLocation.title)
        let dist = currentLocation.distance(from: CLLocation(latitude: eventLocation.lat, longitude: eventLocation.longit))
        distanceLabel.setText(String(dist.description))
        timerLabel.setDate(eventLocation.date!)
    }
    
    var wcSession: WCSession!
    var eventLocation: LocationModel!
    
     var currentLocation = CLLocation()
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    
    
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    
    
    @IBOutlet weak var timerLabel: WKInterfaceTimer!
    
    
    
    
    
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
       
//       wcSession = WCSession.default
//       wcSession.delegate = self
//       wcSession.activate()
        titleLabel.setText("Please select a Location on the iOS App")
       
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
  

}
