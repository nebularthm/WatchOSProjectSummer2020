# ECE564_ProjectSummer2020


Hello, and welcome to the Handled app, which allows users to input the date,time, and location of a particular event into their phones and then recieve reminders of when to 
leave for that event on both their phones and Apple Watch Devices

Included in this readme will be sections for basic use of the app, a tutorial for how I set the app up, and a troubleshooting section

# Use Guide


1. Open The app on both a paired apple watch and iPhone
2. On the iOS app, give the app location permissions while in Use, and allow notifications
3. On the iOS app, press the + button in the navigation bar to add an Event 
4. Fill out the title, speed, date, and address of the event then hit save
5. Tap the new event in the tableView to display the detailView on the Watch
6. Alternatively, tap the upcoming events button on the Watch to pull up the detail view of most urgent event
7. Swipe on the event in the table to either edit or delete it
8. 

* Use Warnings
* Current location for events is based on the current location when an event was entered
* Setting an event time to be before the current date Will cause a “negative” timer on the watchOS timer
* If you are too slow to make an event in time, you will automatically receive a notification to leave in 10 seconds


# Tutorial

This section will provide a tutorial for creating this app

1. In Xcode, create a single view iOS project
2. Add a watchOS target with Notification scene included in this project
3. In the iOS group, delete the default view controller on the Main Storyboard
4. Add a tableView Controller to this storyboard, and also add a new  view controller file to the iOS group that extends UITableViewController, then set the tableViewController in the storyboard to use this class as it's class
5. In the tableviewcontroller class, conform to the following protocols - WCSessionDelegate,UISearchResultsUpdating, UNUserNotificationCenterDelegate, CLLocationManagerDelegate
6. Implement any required functions from those protocols- These protocols are needed for utilizing notification, apple watch, search, and location features on an iOS app.
7. From here, implement standard table methods that will enable you to support swipe actions, tapping on cells, searching and filtering the database
8. With that done, that concludes what you need for the tableviewcontroller. To configure a data model/database for this tableviewcontroller, create a Swift class that extends NSObject where this class contains the following properties at minimum - Speed, Latitude, Longitude, Date, Title. These properties are necessary for sheduling notificaitons for events
9. With the database/model created, create 2 view controllers that will support adding and editing events/locations, and have the original TableViewController segue to these view controllers. This part is open ended in its implementation. For examples- See AddLocationController and EditLocationController in the Handled iOS Group
10.  Now implement notification scheduling for these events in the main talbe view controller. This should use the speed and location properties of your location model, and with the current location, calculate how long it would take you to get a location and subtract that from the date of that event, and use that time interval to schedule the notification. This concludes what tyyou have to do for iOS
11. In the watchOS group, go to the storyboard and and at the minimum add a label, a button, and a timer to this view controller.
12. In the extension for the watchOS, connect the subviews added in step 11 to the InterfaceController. Now, set up a WCSession to send a message to the iOS app, which as a reply gets a relevant location/event from the iOS databse. This location/event can be the most urgent one, or a random one, depending on how you implement the reply handler on the iOS portion




# Troubleshooting

* If the location is not working on either your phone or watch, try restarting location services
* In the simulator, if the location is not working, erase the simulator data on both phone and watch
* In the simulator, if the watch is not recieving data from the phone or vise versa, then restart the simulator or erase the simulator data and then restart






























# Resources


For specific code resources, those are cited in the actual project code. Graphic and asset content is cited here


Used this for the app icon 


https://www.google.com/url?sa=i&url=https%3A%2F%2Flogodix.com%2Fblack-h&psig=AOvVaw375h8elAANqmjRAcNdfpEC&ust=1592908614417000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCIC5_ZudleoCFQAAAAAdAAAAABAD
