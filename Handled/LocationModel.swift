//
//  locationModel.swift
//  Handled
//
//  Created by Michael Williams on 6/15/20.
//  Copyright © 2020 ECE564. All rights reserved.
//


//This class is for handling the locations that will be entered into the app
import UIKit
import CoreLocation
class LocationModel: NSObject, Codable {
    //Used for determining index of this instance when inside of the database
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.lat == rhs.lat && lhs.longit == rhs.longit && lhs.date == rhs.date && lhs.title == rhs.title && lhs.speed == rhs.speed
        }
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("HandledJSONFile")
    
    
    //this constant is for converting a miles per hour measure into a meters per second speed for a particular event
    let miles2meters: Double = 2.237
    var lat: Double = 0
    var longit: Double = 0
    var date: Date?
    var title: String?
    var speed: Double = 0
    
    init(loc: CLLocationCoordinate2D, dat: Date, descrip: String, veloc: Double){
        super.init()
        lat = loc.latitude
        longit = loc.longitude
        date = dat
        title = descrip
        speed = veloc
    }
    //Saves database to memory
      static func saveLocationData(_ locDataBase: [LocationModel]) -> Bool {
            var outputData = Data()
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(locDataBase) {
                if let json = String(data: encoded, encoding: .utf8) {
                    outputData = encoded
                }
                else { return false }
                
                do {
                        try outputData.write(to: ArchiveURL)
                } catch let error as NSError {
                    print (error.localizedDescription)
                    return false
                }
                return true
            }
            else { return false }
        }
        //Loads database from memory using JSON decoder
        static func loadToDoInfo() -> [LocationModel]? {
            let decoder = JSONDecoder()
            var locDataBase = [LocationModel]()
            let tempData: Data
            
            do {
                tempData = try Data(contentsOf: ArchiveURL)
            } catch let error as NSError {
                print(error.localizedDescription)
                return nil
            }
            if let decoded = try? decoder.decode([LocationModel].self, from: tempData) {
                 locDataBase = decoded
            }
    
            return locDataBase
        }
    //create CLL location from lat and longitude of this instance
    func calculateLocation()-> CLLocation{
        return CLLocation(latitude: self.lat, longitude: self.longit)
    }
    //this func is for calculating the amount of seconds between points, provided you have the distance
    func calculateTimeInterval(_ distance:Double)-> Double{
        //if speed is less than or equal to then let shceudler know to send notifcation ASAP
        if speed <= 0{
            return 0
        }
            //LEt notfication sheduler to know to how long itg will take us to get to a location
        else{
            let meterSpeed = speed/miles2meters
            return distance * (1/meterSpeed)
        }
    }
    //Hopefully this func lets us return a copy of this instance
    func copyLocation()->LocationModel{
        return LocationModel(loc: self.calculateLocation().coordinate, dat: self.date!, descrip: self.title!, veloc: self.speed)
    }
}
