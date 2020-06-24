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
//This is the main iOS view controller, is responsible for watchSession, Search, Location, and Notification functions of this app
class LocationsViewController: UITableViewController,WCSessionDelegate,UISearchResultsUpdating, UNUserNotificationCenterDelegate, CLLocationManagerDelegate{
    //Don't need the next 3 delegate methods, just there for conformance to protocol so they return
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    //When the watch sends us a message, reply with info for the most urgent/upcoming event/activity
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //find most urgent location
        let urgentLocation = mostUrgentLoc(message["date"] as! Date)
        //convert to message dict
        var retDict = self.convertLocToDict(urgentLocation)
        //give the dict our lat and longit
        retDict["latCurr"] = currentLocation.coordinate.latitude
        retDict["longitCurr"] = currentLocation.coordinate.longitude
        //reply to the watch
        replyHandler(retDict)
    }
    //this function returns the most upcoming event based on an imputted date
    func mostUrgentLoc(_ date:Date)->LocationModel?{
        
        var urgLoc:LocationModel? = nil//optional in case nothing is found
        
        for location in database{
            //we are only interested in locations in the future not the past
            //initalize urgLoc to the first location that is in the future
            if(urgLoc == nil && location.date! >= date){
                urgLoc = location
            }
            //after intialization, find the location that has the shortest timerInterval as that is the one most upcoming
            if(urgLoc != nil && location.date! <= (urgLoc?.date)!){
                urgLoc = location
            }
        }
        
        return urgLoc
    }
    //for connecting to watch
    var wcSession: WCSession! = nil
    var database = [LocationModel]()
    //LocationModel passed to editLocationController
    var loc: LocationModel? = nil
    //Current location of iOS
       var currentLocation = CLLocation()
    //for searching
    var filteredDatabase = [LocationModel]()
    var resultSearchController = UISearchController()
    let userNotificationCenter = UNUserNotificationCenter.current()
    let locationManager:CLLocationManager = CLLocationManager()
    //set delegates for search, watch connectivity sesssion, notifications, and location
    //also intialize the database and remove old data in the database
    override func viewDidLoad() {
        super.viewDidLoad()
        //Only if the session is supported between watch and phone should session be activated
        if WCSession.isSupported(){
               wcSession = WCSession.default
                     wcSession.delegate = self
                     wcSession.activate()
              
              }
        //load intial data and remove old data
         loadInitialData()
        removeOldEvents()
        //initalize locationmanager and current location
        setUpLocation()
        //intializes search bar controller
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            tableView.tableHeaderView = controller.searchBar
            definesPresentationContext = true
            return controller
        })()
        //set up notificaiton delegate and notification options, as well as req authorization
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert,.sound)
      self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
        //If we get authoriation, we are gonna set a categroy/action for reminding the user in 30 seconds
        if success{
            //the action itself for remdning the user
            let remindAction = UNNotificationAction(
            identifier: "remind",
            title: "Remind in 30 Sec",
            options: [])
            //category that contains the remind action
            let remindCategory = UNNotificationCategory(
            identifier: "remind.category",
            actions: [remindAction],
            intentIdentifiers: [],
            options: [])
            //push the category to the userNotificationCenter
            self.userNotificationCenter.setNotificationCategories([remindCategory])
        }
          if let error = error {
            print(error.localizedDescription)
          }
      }
        self.userNotificationCenter.delegate = self
        
        tableView.reloadData()
    }
    //intialize current location, as well as location manager
    func setUpLocation(){
        self.locationManager.delegate = self
                     self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                     
               self.locationManager.requestLocation()
                    self.locationManager.requestAlwaysAuthorization()
                     self.locationManager.startUpdatingLocation()
    }
    
    
    
    
    //update current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if there are not any locations for update, exit
        if locations.count == 0
        {
        return
        }
        
        //get first location and set it as our current and most recent location
        self.currentLocation = locations.first!
        }
    
    //for if we failed to find/load any locations, just report that error
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Fail to load location")
        print(error.localizedDescription)
        }
    
    
    
    //intialize the database
    func loadInitialData(){
        //load the database from memory
        if let tempLocs = LocationModel.loadToDoInfo(){
            database = tempLocs
        }
            //or create the database with 1 default random location
        else{
            
        
        //This location will correspond to 839 Edgewood Drive New York, NY 10031, a randomly generated location in NYC
            let firstDate:Date = Date(timeInterval: 150000, since: Date())
        let firstCoord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.748540, longitude: -73.568280)
            let firstLoc = LocationModel(loc: firstCoord, dat: firstDate, descrip: "Random Point", veloc: 3.5)
        database.append(firstLoc)
            let _ = LocationModel.saveLocationData(database)
        }
    }
    
    
    
    
    //For a given query LocationModel, matches this location to a location with the exact same date. If that location exists, return true and that locaiton. Otherwise return false
    func searchForMatch(_ query: LocationModel)->(exists: Bool, target: LocationModel){
          for loc in database{
            if(loc.date == query.date){
                return (true,loc)
            }
          }
        return (false, LocationModel(loc: CLLocationCoordinate2D(), dat: Date(), descrip: "", veloc: 0))
          
      }
    
    
    //automatically cleans old events from the database
    func removeOldEvents(){
        
        var oldDates = [Int]()
        //iterate through database
        for loc in self.database{
            //if a location is older than the current date, mark it for deletion by adding it's index to the array of old dates
            if loc.date! < Date(){
                let dex = database.firstIndex(of: loc)!
                oldDates.append(dex)
            }
        }
        //iterate through the old dates and remove them from the database
        for i in oldDates{
            database.remove(at: i)
        }
    }
    //This function removes a location from the database at the first index of that location
    func removeLocationFromDataBase(_ location: LocationModel){
        let dex = self.database.firstIndex(of: location)!
        self.database.remove(at: dex)
    }
    
    //This method adds location to the database
      func addLocation(_ location: LocationModel){
        //check if event already exists
          let inDatabase = searchForMatch(location)
        //if event already exists, remove preexisting event  from the database
          if(inDatabase.0){
            removeLocationFromDataBase(inDatabase.1)
                }
        //append the event to the database
        database.append(location)
      }
    //edits a location already in the database
    func editLocation(_ location:LocationModel, oldLocation:LocationModel){
        //remove the old event
        removeLocationFromDataBase(oldLocation)
        //add the new event
        database.append(location)
    }
    // MARK: - Table view data source
    //This table only needs 1 section
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //use cells in the filtered database from searching
        if(inSearchMode()){
            return filteredDatabase.count
               }
        //use default cells from database
        return database.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell is either from the regular database or the filtered database for searching
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location", for: indexPath)
            var tempLocation: LocationModel!
        if(inSearchMode()){
            tempLocation = self.filteredDatabase[indexPath.row]
        }
        else{
            
        
        tempLocation = self.database[indexPath.row]
        }
        //set cell labels to be the title and date of the cell
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
    
    
    //This method is used to convert Location Data to a dict for WCSession messaging
    func convertLocToDict(_ location: LocationModel?) -> [String: Any]{
        //for replies, if no location was found then say  loc not valid
        if(location == nil){
            return ["validLocation":false]
        }
        return ["lat": location!.lat, "longit": location!.longit, "date":location!.date, "title":location!.title, "speed":location!.speed,"validLocation":true]
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               //Choose Loc based on index ineither search database mode or regular databse mode
        if(inSearchMode()){
                   loc = self.filteredDatabase[indexPath.row]
               }
               else{
                   
               
               loc = self.database[indexPath.row]
               }
        //in the simulator, our location is 200 West 47th Street, New York, NY 10036
        //convert a LocationModel into a dict for messaging
        let retDict = convertLocToDict(loc!)
        //format message with this dict, and with current location data
        let message = ["message":retDict, "lat":currentLocation.coordinate.latitude, "longit":currentLocation.coordinate.longitude] as [String : Any]
            //Only send a message now if the watchSession is supported
        if WCSession.isSupported(){
            //send message to watch
        wcSession.sendMessage(message, replyHandler: nil) { (error) in
            
            print(error.localizedDescription)
            
        }
        }
        tableView.reloadData()
    }
    
    //exit segue for adding and editing
    @IBAction func returnFromNewItem(segue: UIStoryboardSegue) {
        
        self.removeOldEvents()
        //when we return, remove old events
        //switch based on the source of the suegue
        switch segue.source {
            //for adding
        case is AddLocationController:
            let locContr = segue.source as! AddLocationController
            //if there is a new location, add it to the database and save as well as schedule a notification
            if(locContr.hasNewLoc){
                
            
            let addedLoc = locContr.addedLocation!
            addLocation(addedLoc)
                self.scheduleNotification(addedLoc)
            }
            
            let _ = LocationModel.saveLocationData(database)
            tableView.reloadData()
            //for editing
        case is EditLocationController:
            //edit the enry in the database, save, and schedule a notificaiton
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
        //adding an event does not need data from us
        if segue.identifier == "add"{
            return
        }
            //editing needs to have the location
        else{
            //segue goes immediatly to navcontroler
            let nav = segue.destination as! UINavigationController
            //top controller is an EditLocation Controller
            let editVC = nav.topViewController as! EditLocationController
            //pass this data to the editController
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
      filteredDatabase = database.filter { (location:LocationModel) -> Bool in
        
          //filters the database by the name of the event while searching
            
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
    //https://makeapppie.com/2016/12/05/add-actions-and-categories-to-notification-in-swift/
    func scheduleNotification(_ location:LocationModel) {
        let notificationContent = UNMutableNotificationContent()
        // Add the content to the notification content
        notificationContent.title = location.title!//the title of the notifcaiton will be same as event title
           notificationContent.body = "Leave now to get to this event"
        notificationContent.sound = UNNotificationSound.defaultCritical
        notificationContent.categoryIdentifier = "remind.category"
        //calculate distance between the event location and the current location
        let dist: Double = location.calculateLocation().distance(from: currentLocation)
        let timeTo:Double = (location.date?.timeIntervalSince(Date()))!//this tells how long until the date of the activity from the current date in seconds
        //calculate how long it will take us to reach the event based on our current location
        let intervalForSchedule = location.calculateTimeInterval(dist)
        var trigger: UNTimeIntervalNotificationTrigger!
        //shecudle a notfication ASAP if the user is too slow too slow to get to a location, or 0 was returned for the time it takes to get to a location
        if(intervalForSchedule == 0 || timeTo <= intervalForSchedule){
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }
            //otherwise schedule a notifcation fora time from now
        else{
            let triggerTime = timeTo - intervalForSchedule
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        }
           //the identifer for this is made with the unique date identfier for each location
        let request = UNNotificationRequest(identifier: "\(location.date?.description)",
                                               content: notificationContent,
                                               trigger: trigger)
           
           userNotificationCenter.add(request) { (error) in
               if let error = error {
                print(error.localizedDescription)
               }
           }
    }

    //Next 2 methods are used for displaying a notificaiton in theforegorund of theapp, this completion handler is for recieving a notifcation
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        //this part is for the remind action
        let request = response.notification.request//get the request and identifier for this action
        if response.actionIdentifier == "remind"{
            let newContent = request.content.mutableCopy() as! UNMutableNotificationContent
            //copy the content from the prev notification
            let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)//Set up a new trigger
            let newrequest = UNNotificationRequest(identifier: request.identifier,
                                                          content: newContent,
                                                          trigger: newTrigger)//push a new request to the notificaiton center
                      
                      userNotificationCenter.add(newrequest) { (error) in
                          if let error = error {
                           print(error.localizedDescription)
                          }
                      }
        }
    }
    //this completion hanlder is for presenting the alert and sound on screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    
    
    
    //allows for the ediitng of all cells in the tableView
       override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
       
       
       //this is the fucntion for swiping, does a different action based on the swipe
       override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
           
           
           
           //this action deletes a DukePerson in a given location
           let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler:{ (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
              if(self.inSearchMode()){
                //in search mode we want to delete it in both fileted database and the current database, and save
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
           //this action is for editing a LocaitonModel at a certain location
           let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler:{ (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.loc = self.database[indexPath.row]
               self.performSegue(withIdentifier: "edit", sender: self)
           })
           editAction.backgroundColor = .blue
           
        //This gives users the ability to set repeat events on a weekly basis
        let weekInSeconds: Double = 604800//this is how many seconds are in a week
        let repeatAction = UITableViewRowAction(style: .normal, title: "Repeat", handler:{ (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let repeatedLocation:LocationModel = self.database[indexPath.row].copyLocation()
            repeatedLocation.date = Date(timeInterval: weekInSeconds, since: repeatedLocation.date!)
            self.database.append(repeatedLocation)
            self.scheduleNotification(repeatedLocation)
            let _ = LocationModel.saveLocationData(self.database)
            self.tableView.reloadData()
                  })
        repeatAction.backgroundColor = .green
           return [deleteAction,editAction, repeatAction]
       }
       
    
    

}
