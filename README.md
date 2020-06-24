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
6. Alternatively, tap the upcoming events button on the Watch to pull up the detail view of most urgent event(The one that is most upcoming)
7. Swipe on the event in the table to either edit, delete, or repeat it. Repeating event causes it to reoccur 7 days from that event
8. When a notification comes, a user can tap on the "Remind me in 30 secs" action on that notification to recieve a duplicate notification in 30 seconds. That duplicated notification can be repeated any number of times

* Use Warnings
* Current location for events is based on the current location when an event was entered
* Setting an event time to be before the current date Will cause a “negative” timer on the watchOS timer
* If you are too slow to make an event in time, you will automatically receive a notification to leave in 10 seconds
* For addresses entered for events, be as specific as possible, as it is currently unclear what the priority for PlaceMarks is. It is recommended to use as much of a postal address as possible, with Street Name, City Name, and Zipcode in the address. If there is a discrepancy in the distance to a location, try making the address more specific by including the full postal address. The current postal address can be seen in the Address Textfield on the edit Screen for a particular LocationModel
* You cannot save 2 events with the exact same date, because logically you cannot be in 2 places at once. IF you attempt to create 2 events with the exact same date the last one will be replaced by the new one. You can test this by creating a recurrence of an event with the swipe, then trying to do it again. 



# Tutorial

This section will provide a tutorial for creating this app

1. In Xcode, create a single view iOS project
2. Add a watchOS target with Notification scene included in this project
3. In the iOS group, delete the default view controller on the Main Storyboard
4. Add a tableView Controller to this storyboard and set it to be the initial view controller, and also add a new  view controller file to the iOS group that extends UITableViewController, then set the tableViewController in the storyboard to use this class as it's class
5. In the tableviewcontroller class, conform to the following protocols - WCSessionDelegate,UISearchResultsUpdating, UNUserNotificationCenterDelegate, CLLocationManagerDelegate
6. Implement any required functions from those protocols- These protocols are needed for utilizing notification, apple watch, search, and location features on an iOS app. To see examples of how to implement these functions, see the LocationsViewController.swift file in the Handled group. There you can find in depth details on how to implement necesary delegate methods
7. From here, implement standard tableview methods that will enable you to support swipe actions, tapping on cells, searching and filtering the database, as well as loading in data from a database. 
8. With that done, that concludes what you need for the tableviewcontroller. To configure a data model/database for this tableviewcontroller, create a Swift class that extends NSObject where this class contains the following properties at minimum - Speed, Latitude, Longitude, Date, Title. These properties are necessary for sheduling notificaitons for events
9. With the database/model created, create 2 view controllers that will support adding and editing events/locations, and have the original TableViewController segue to these view controllers. This part is open ended in its implementation. For examples- See AddLocationController and EditLocationController in the Handled iOS Group
10.  Now implement notification scheduling for these events in the main table view controller. This should use the speed and location properties of your location model, and with the current location, calculate how long it would take you to get a location and subtract that from the date of that event, and use that time interval to schedule the notification. This concludes what tyyou have to do for iOS
11. In addition to the directions in Step 10, make sure that set up notification actions and categories that correspond to each notification. In this app, we used a Remind categroy so that each notification has the option of reminding the user in 30 seconds again. For more information, see the viewDidLoad(), scheduleNotificaiton(),  and the userNotifiationDelegate() functions in the LocationsViewController.Swift file 
12. In the watchOS group, go to the storyboard and and at the minimum add a label, a button, and a timer to this view controller.
13. In the extension file for the watchOS, connect the subviews added in step 11 to the InterfaceController. Now, set up a WCSession to send a message to the iOS app, which as a reply gets a relevant location/event from the iOS databse. This location/event can be the most urgent one, or a random one, depending on how you implement the reply handler on the iOS portion




# Troubleshooting

* If the location is not working on either your phone or watch, try restarting location services
* In the simulator, if the location is not working, erase the simulator data on both phone and watch
* In the simulator, if the watch is not recieving data from the phone or vise versa, then restart the simulator or erase the simulator data and then restart






























# Resources


For specific code resources, those are cited in the actual project code. Graphic and asset content is cited here


For the App Icons, I used this image then created various appIcons with it

https://www.google.com/url?sa=i&url=https%3A%2F%2Flogodix.com%2Fblack-h&psig=AOvVaw375h8elAANqmjRAcNdfpEC&ust=1592908614417000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCIC5_ZudleoCFQAAAAAdAAAAABAD
