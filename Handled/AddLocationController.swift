//
//  AddLocationController.swift
//  Handled
//
//  Created by Michael Williams on 6/17/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import UIKit
import CoreLocation
class AddLocationController: UIViewController, UITextFieldDelegate {

    
    
    //properties for added view controller
    var addedLocation: LocationModel?
    
    var addressDecode: CLGeocoder?
    var addressString: String?
    var eventTitle: String?
    //set this to current date coz only updates if value changed
    var selectedDate: Date? = Date()
    var validAdd = true
    var coord: CLLocationCoordinate2D?
    //bool for if we cancelled without creating a LocationModel
    var hasNewLoc: Bool = true
    var velocity: Double?
    var velocityStr: String?
    //subviews
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var outLabel: UILabel!
    
    
    @IBOutlet weak var titleField: UITextField!
    
    
    
    
    @IBOutlet weak var datePick: UIDatePicker!
    
    //Update date when the value on the datePicker changes
    @IBAction func pickDate(_ sender: Any) {
        selectedDate = datePick.date
    }
    
    
    @IBOutlet weak var speedField: UITextField!
    
    
    
    
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //used for converting the address string into an actual location
        addressDecode = CLGeocoder()
        //set delegates of all of the text fields
        titleField.delegate = self
        addressField.delegate = self
        speedField.delegate = self
        // Do any additional setup after loading the view.
    }
    //for converting an address into a location
    func convertToLoc(){
        //if address is empty it is automatically bad
        if(addressString?.count == 0 || addressString == nil){
            validAdd = false
            return
        }
        //start decoding
        addressDecode!.geocodeAddressString(addressString!, completionHandler: {(placemarks, error) -> Void in
            //if an error with no placemarks, then the address was bad
        if((error) != nil){
            print(error?.localizedDescription)
            self.validAdd = false
        }
            //if address has placemarks then it is not bad, use coord of first placemark
        if let placemark = placemarks?.first {
            self.validAdd = true
            self.coord = placemark.location!.coordinate
           }
         })
    }
        
        //meant to update string properties with values of text fields
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            switch textField{
            case addressField:
                addressString = textField.text!
                addressField.resignFirstResponder()
                //convert to location once the string is acquired
                convertToLoc()
                return true
            case titleField:
               eventTitle = textField.text!
                titleField.resignFirstResponder()
                return true
            case speedField:
                velocityStr = textField.text!
                speedField.resignFirstResponder()
                return true
          
            default:
                return true
            }
           }
        //This function returns true if the strings in the text fields are valid, and false if they are empty or nil
        func checkFields()->Bool{
            //In the case that the textfields have not been filled out, or the text fields have been erased to have epty Strings, those fields contain data that should not be added to the database
            return !(addressString?.count == 0 || addressString == nil || eventTitle == nil || eventTitle?.count == 0)
        }
        //you should either do a return segue if you have not edited anyhting, or you should not do one if editiing is not finished
        override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            //if we are cancelling then always segue
            if ((sender as! UIBarButtonItem) == self.cancelButton)  {
                return true
            }
            //if the address provided is not valid, then a segue should not be formed until one is acquired
            if(!validAdd){
                outLabel.text = "Please provide a valid address"
                outLabel.textColor = .red
                return false
            }
            //if speed is not a number then also do not segue
            if(!checkSpeed()){
                outLabel.text = "Please enter a valid speed"
                outLabel.textColor = .red
                return false
            }
            //if the textfields provided empty strings, then do not segue
            if(!checkFields()){
                outLabel.text = "Please Fill out all Text Fields Before Saving"
                outLabel.textColor = .red
                return false
            }
            //just segue anyway at this point
            return true
        }
        /*
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            //if we cancelled then we do not have a new loc
            if ((sender as! UIBarButtonItem) == self.cancelButton)  {
                self.hasNewLoc = false
                return
            }
            //Do not edit the pre-existing reference of the model, instead make a new one and return. Regardless of segue, filtering in the tableviewcontroller will handle any duplicates from premature segue
            self.addedLocation = LocationModel(loc: coord!, dat: selectedDate!, descrip: eventTitle!, veloc: velocity!)
            return
        }
    
//using the StringProtocol extension, we just check to see if what we have in our textField is a valid double vale
    func checkSpeed()->Bool{
        if let doub = velocityStr?.double{
            velocity = doub
            return true
        }
        return false
    }

}
//    The following code is from https://stackoverflow.com/questions/30315723/check-if-string-is-a-valid-double-value-in-swift
//this method basically checks to see if the string provided for speed is a valid Double value that we can use, if not don't let the user do anything
extension StringProtocol {
    var double: Double? { Double(self) }
}
