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
    
    
    
    @IBAction func displayMostUrgent() {
        
        //make sure phone is in reach before sending it a message
        if(wcSession.isReachable){
            
        //send the phone the current date
       let message = ["date":Date()]
        wcSession.sendMessage(message, replyHandler: { (reply) in
            //parse the reply from the phone
            let validLoc = reply["validLocation"] as! Bool
            //If there are any activities available, display them
            if(validLoc){
                 let coordy = CLLocationCoordinate2D(latitude: reply["lat"] as! CLLocationDegrees, longitude: reply["longit"] as! CLLocationDegrees)
                self.eventLocation = LocationModel(loc: coordy, dat: reply["date"] as! Date, descrip: reply["title"] as! String, veloc: reply["speed"] as! Double)
                self.currentLocation = CLLocation(latitude: reply["latCurr"] as! CLLocationDegrees, longitude: reply["longitCurr"] as! CLLocationDegrees)
                self.displayLocation()
            }
            else{
                self.titleLabel.setText("No Upcoming Activities")
            }
            
        }, errorHandler: {(error) in
            print(error.localizedDescription)
        })
            
        }
        
    }
    
    //The phone will send us data in the form of a Dict, parse that data and display it on the screen
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let retDict = message["message"] as! [String: Any]
        let coordy = CLLocationCoordinate2D(latitude: retDict["lat"] as! CLLocationDegrees, longitude: retDict["longit"] as! CLLocationDegrees)
        eventLocation = LocationModel(loc: coordy, dat: retDict["date"] as! Date, descrip: retDict["title"] as! String, veloc: retDict["speed"] as! Double)
        currentLocation = CLLocation(latitude: message["lat"] as! CLLocationDegrees, longitude: message["longit"] as! CLLocationDegrees)
        displayLocation()
       
    }
    //Used to update the detail view after recieving data from apple watch
    func displayLocation(){
        titleLabel.setText(eventLocation.title)
        var dist = self.currentLocation.distance(from: eventLocation.calculateLocation())
        dist = dist/1609 //convert meters to miles
        var distString = String(format: "%.6f", dist)
        distanceLabel.setText("\(distString) miles")
               distanceLabel.setHidden(false)
               timerLabel.setDate(eventLocation.date!)
               timerLabel.setHidden(false)
               timerLabel.start()
    }
    
    var wcSession: WCSession!
    var eventLocation: LocationModel!
    var didRecLoc: Bool = true
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
        timerLabel.setHidden(true)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //wheneever the watch is going to activiate, engage the wcSession
        wcSession = WCSession.default
        wcSession.delegate = self
        wcSession.activate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
  

}
