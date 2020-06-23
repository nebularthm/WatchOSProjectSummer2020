//
//  LocationsViewController.swift
//  Handled
//
//  Created by Michael Williams on 6/15/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity
import UserNotifications
class LocationsViewController: UITableViewController,WCSessionDelegate,UISearchResultsUpdating, UNUserNotificationCenterDelegate, CLLocationManagerDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let urgentLocation = mostUrgentLoc(message["date"] as! Date)
        var retDict = self.convertLocToDict(urgentLocation)
        retDict["latCurr"] = currentLocation.coordinate.latitude
        retDict["longitCurr"] = currentLocation.coordinate.longitude
        replyHandler(retDict)
    }
    func mostUrgentLoc(_ date:Date)->LocationModel?{
        var urgLoc:LocationModel? = nil
        
        for location in database{
            //we are only interested in locations in the future not the past
            if(urgLoc == nil && location.date! >= date){
                urgLoc = location
            }
            if(urgLoc != nil && location.date! <= (urgLoc?.date)!){
                urgLoc = location
            }
        }
        
        return urgLoc
    }
    
    var wcSession: WCSession! = nil
    var database = [LocationModel]()
    var loc: LocationModel? = nil
       var currentLocation = CLLocation()
    
    var filteredDatabase = [LocationModel]()
    var resultSearchController = UISearchController()
    let userNotificationCenter = UNUserNotificationCenter.current()
    let locationManager:CLLocationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        //updateLocation()
        if WCSession.isSupported(){
               wcSession = WCSession.default
                     wcSession.delegate = self
                     wcSession.activate()
              
              }
         loadInitialData()
        setUpLocation()
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            tableView.tableHeaderView = controller.searchBar
            definesPresentationContext = true
            return controller
        })()
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert,.sound)
      self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
          if let error = error {
            print(error.localizedDescription)
          }
      }
        self.userNotificationCenter.delegate = self
        
        tableView.reloadData()
    }
    
    func setUpLocation(){
        self.locationManager.delegate = self
                     self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                     
               self.locationManager.requestLocation()
                    self.locationManager.requestAlwaysAuthorization()
                     self.locationManager.startUpdatingLocation()
    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0
        {
        return
        }
        self.currentLocation = locations.first!
       
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Fail to load location")
        print(error.localizedDescription)
        }
    
    
    
    
    func loadInitialData(){
        if let tempLocs = LocationModel.loadToDoInfo(){
            database = tempLocs
        }
        else{
            
        
        //This location will correspond to 839 Edgewood Drive New York, NY 10031, a randomly generated location in NYC
        var firstDate:Date = Date(timeInterval: 150000, since: Date())
        let firstCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.748540, longitude: -73.568280)
            let firstLoc = LocationModel(loc: firstCoord, dat: firstDate, descrip: "Random Point", veloc: 3.5)
        database.append(firstLoc)
            let _ = LocationModel.saveLocationData(database)
        }
    }
    func searchForMatch(_ query: LocationModel)->(exists: Bool, target: LocationModel){
          for loc in database{
            if(loc.lat == query.lat && loc.longit == query.longit){
                return (true,loc)
            }
          }
        return (false, LocationModel(loc: CLLocationCoordinate2D(), dat: Date(), descrip: "", veloc: 0))
          
      }
    
      func addLocation(_ location: LocationModel){
          let inDatabase = searchForMatch(location)
          if(inDatabase.0){
                  let dex = database.firstIndex(of: inDatabase.1)!
                  database.remove(at: dex)
                }
        database.append(location)
      }
    
    func editLocation(_ location:LocationModel, oldLocation:LocationModel){
        let dex = database.firstIndex(of: oldLocation)!
        database.remove(at: dex)
        database.append(location)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(inSearchMode()){
            return filteredDatabase.count
               }
        return database.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location", for: indexPath)
            var tempLocation: LocationModel!
        if(inSearchMode()){
            tempLocation = self.filteredDatabase[indexPath.row]
        }
        else{
            
        
        tempLocation = self.database[indexPath.row]
        }

        cell.textLabel?.text = tempLocation.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        cell.detailTextLabel?.text = dateFormatter.string(from: tempLocation.date!)
            cell.detailTextLabel?.font = UIFont(name: "AmericanTypewriter", size: 15)
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.numberOfLines = 0
            
            return cell
    }
    func convertLocToDict(_ location: LocationModel?) -> [String: Any]{
        if(location == nil){
            return ["validLocation":false]
        }
        return ["lat": location!.lat, "longit": location!.longit, "date":location!.date, "title":location!.title, "speed":location!.speed,"validLocation":true]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               if(inSearchMode()){
                   loc = self.filteredDatabase[indexPath.row]
               }
               else{
                   
               
               loc = self.database[indexPath.row]
               }
        //in the simulator, our location is 200 West 47th Street, New York, NY 10036
        var retDict = convertLocToDict(loc!)
        let message = ["message":retDict, "lat":currentLocation.coordinate.latitude, "longit":currentLocation.coordinate.longitude] as [String : Any]

        if WCSession.isSupported(){
            
            print(currentLocation.coordinate.latitude)
        wcSession.sendMessage(message, replyHandler: nil) { (error) in
            
            print(error.localizedDescription)
            
        }
        }
        tableView.reloadData()
    }
    
    
    @IBAction func returnFromNewItem(segue: UIStoryboardSegue) {
        
        
        switch segue.source {
        case is AddLocationController:
            let locContr = segue.source as! AddLocationController
            if(locContr.hasNewLoc){
                
            
            let addedLoc = locContr.addedLocation!
            addLocation(addedLoc)
                self.scheduleNotification(addedLoc)
            }
            
            let _ = LocationModel.saveLocationData(database)
            tableView.reloadData()
        case is EditLocationController:
            let source = segue.source as! EditLocationController
            editLocation(source.editLoc, oldLocation: source.oldLoc)
            self.scheduleNotification(source.editLoc)
            let _ = LocationModel.saveLocationData(database)
            self.tableView.reloadData()
        default:
            self.tableView.reloadData()
        }
        tableView.reloadData()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "add"{
            return
        }
        else{
            let nav = segue.destination as! UINavigationController
            let editVC = nav.topViewController as! EditLocationController
            editVC.editLoc = self.loc
            return
            
        }
    }
    
    //as the user keeps typing, continually update the filtered database with all of the relevant data, also based on select scope
    func updateSearchResults(for searchController: UISearchController) {
        filteredDatabase.removeAll(keepingCapacity: false)

        let sBar = resultSearchController.searchBar
        searchAllFields(sBar.text!)
        self.tableView.reloadData()
    }
    
    //search all of the String properties of a dukePerson
    func searchAllFields(_ searchText: String) {
       //have to do 2 filters, one for the 1st dimension, another for the second dimension
      filteredDatabase = database.filter { (location:LocationModel) -> Bool in
        
            //if we are looking at all scopes, or this person matches our specific scope, then we are in the right place
            
            //If the user has emptied the field and only wants tos ee the category, put everyhting that matches the category here
            
        return (location.title?.lowercased().contains(searchText.lowercased()))!
        }
        
      
      
      tableView.reloadData()
    }
    
    
    //this func controls whether we are currently searching the database, or whether the user is just scrolling/browsing
    func inSearchMode()->Bool{
        
         
        return resultSearchController.isActive && ( !(resultSearchController.searchBar.text?.isEmpty ?? true))
    }
    
    
    

    //Ise this method to schedule a notifcation for a location object
    //code for thsi was inspired by https://programmingwithswift.com/how-to-send-local-notification-with-swift-5/
    func scheduleNotification(_ location:LocationModel) {
        let notificationContent = UNMutableNotificationContent()
        // Add the content to the notification content
        notificationContent.title = location.title!
           notificationContent.body = "Leave now to get to this event"
           notificationContent.badge = NSNumber(value: 3)
        let dist: Double = location.calculateLocation().distance(from: currentLocation)
        let timeTo:Double = (location.date?.timeIntervalSince(Date()))!//this tells how long until the date of the activity from the current date in seconds
        let intervalForSchedule = location.calculateTimeInterval(dist)
        var trigger: UNTimeIntervalNotificationTrigger!
        if(intervalForSchedule == 0 || timeTo <= intervalForSchedule){
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        }
        else{
            let triggerTime = timeTo - intervalForSchedule
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        }
           //the identifer for this is made with the unique latitidue and longitude info for each location
        let request = UNNotificationRequest(identifier: "\(location.lat) \(location.longit)",
                                               content: notificationContent,
                                               trigger: trigger)
           
           userNotificationCenter.add(request) { (error) in
               if let error = error {
                   print("Notification Error: ", error)
               }
           }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    
    
    
    //allows for the ediitng of all cells in the tableView
       override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
       
       
       //this is the fucntion for swiping, does a different action based on the swipe
       override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
           
           //figured this out form https://useyourloaf.com/blog/table-swipe-actions/
           //this action chagnes the color of ALL cells in the table, cycles through a list of colors
           
           //this action deletes a DukePerson in a given location
           let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler:{ (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
              if(self.inSearchMode()){
                                        let removedPerson: LocationModel = self.filteredDatabase[indexPath.row]
                             self.filteredDatabase.remove(at: indexPath.row)
                                            let dex = self.database.firstIndex(of: removedPerson)!
                                            self.database.remove(at: dex)
                                        
                             let _ = LocationModel.saveLocationData(self.database)
                                    }
                                    else{
                                self.database.remove(at: indexPath.row)
                             let _ = LocationModel.saveLocationData(self.database)
                                    
                 }
                              self.tableView.reloadData()
           })
           //this action is another way to create another dukePErosn, and then insert them into the database
           let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler:{ (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.loc = self.database[indexPath.row]
               self.performSegue(withIdentifier: "edit", sender: self)
           })
           editAction.backgroundColor = .blue
           
           return [deleteAction,editAction]
       }
       
    
    

}
