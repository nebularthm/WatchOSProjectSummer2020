//
//  EditLocationController.swift
//  Handled
//
//  Created by Michael Williams on 6/19/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts
class EditLocationController: UIViewController,UITextFieldDelegate {
    //properties for creating a LocationModel
    var addressText: String?
    var titleText: String?
    var speed: Double?
    var editLoc: LocationModel!
    var oldLoc: LocationModel!
    var velocityStr: String?
    var editDate: Date?
    var validAdd = true
    var coord:CLLocationCoordinate2D?
    //used for converting either address to location or location to address
    let coordToAddress = CLGeocoder()
    let addressDecode = CLGeocoder()
    var didEdit:Bool = true
    
    @IBOutlet weak var addressField: UITextField!
    
    
    
    
    
    @IBOutlet weak var titleField: UITextField!
    
    
    
    @IBOutlet weak var speedField: UITextField!
    
    
    
    @IBOutlet weak var dateField: UIDatePicker!
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    @IBOutlet weak var outLabel: UILabel!
    
    
    //IF the date is changed, update the date to be used to construct
    @IBAction func pickDate(_ sender: Any) {
        editDate = dateField.date
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Save the old LocationModel if we hit cancel
        oldLoc = editLoc
        //Initialize properties, and set values of text fields to those properties from the cell in the tableview
        speed = editLoc.speed
        velocityStr = speed?.description
        speedField.text = speed?.description
        titleText = editLoc.title
        titleField.text = titleText
        editDate = editLoc.date
        dateField.date = editDate!
        //convert the coordinate into an address
        convertCoordToString()
        addressField.text = addressText
        titleField.delegate = self
        speedField.delegate = self
        addressField.delegate = self
        outLabel.text = "Edit any fields for this event"
        coord = editLoc.calculateLocation().coordinate
        // Do any additional setup after loading the view.
    }
    
    //this func is for converting the  location data into a string
    func convertCoordToString(){
        //get coord from LocationModel
        coordToAddress.reverseGeocodeLocation(editLoc.calculateLocation(), completionHandler:
            {//closure for finding the placemarks
                placemarks, error -> Void in

                // Place details
                //got this code from here https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
                //error should not happen because this was already a valid location, but just in case do error protection anyway and get the first placemark
                guard let placeMark = placemarks?.first else { return }
                let postalAddressFormatter = CNPostalAddressFormatter()
                //get regular mailing address format of an address
                postalAddressFormatter.style = .mailingAddress
                //if the postal adress is not nil
                if let postalAddress = placeMark.postalAddress {
                    //because this isa closure, update the text and the string at the same time for the text field
                    self.addressText = postalAddressFormatter.string(from: postalAddress)
                    self.addressField.text = self.addressText!
                }
                
                
               
        })
    }
    

      //meant to update string properties with values of text fields
          func textFieldShouldReturn(_ textField: UITextField) -> Bool {
              switch textField{
              case addressField:
                  addressText = textField.text!
                  addressField.resignFirstResponder()
                  //if we edited the address field, we have to convert the address into a location
                  convertToLoc()
                  return true
              case titleField:
                 titleText = textField.text!
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
              //In the case that the textfields have not been filled out, or the text fields have been erased to have empty Strings, those fields contain data that should not be added to the database
              return !(addressText?.count == 0 || addressText == nil || titleText == nil || titleText?.count == 0)
          }
          //you should either do a return segue if you have not edited anyhting, or you should not do one if editiing is not finished
          override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
              if ((sender as! UIBarButtonItem) == self.cancelButton)  {
                  return true
              }
            if(!checkSpeed()){
                outLabel.text = "Please enter a valid speed"
                outLabel.textColor = .red//make it very glaring that the user made a mitake
                //print("this")
                return false
            }
            if(!validAdd){
                           outLabel.text = "Please provide a valid address"
                outLabel.textColor = .red
                           return false
                       }
              if(!checkFields()){
                  outLabel.text = "Please Fill out all Text Fields Before Saving"
                  outLabel.textColor = .red
                  return false
              }
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
    //segue back to table with a created edited location
          override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              //if we are cancelling, then don't create a new edit object and just use the old one
            if ((sender as! UIBarButtonItem) == self.cancelButton)  {
                self.editLoc = self.oldLoc
                  return
              }
              //Do not edit the pre-existing reference of the model, instead make a new one and return. Regardless of segue, filtering in the tableviewcontroller will handle any duplicates from premature segue
            self.editLoc = LocationModel(loc: coord!, dat: editDate!, descrip: titleText!, veloc: speed!)
              return
          }
      
  //using the StringProtocol extension, we just check to see if what we have in our textField is a valid double vale
      func checkSpeed()->Bool{
          if let doub = velocityStr?.double{
            speed = doub//go ahead and update the speed at the same time
              return true
          }
          return false
      }
    //for converting a address to a locaiton
    func convertToLoc(){
        //if this false then the address is bad
           if(addressText?.count == 0 || addressText == nil){
               validAdd = false
               return
           }
        addressDecode.geocodeAddressString(addressText!, completionHandler: {(placemarks, error) -> Void in
           if((error) != nil){
            //if we have an error, then the address is bad
            print(error?.localizedDescription)
               print("we lowkey have an error")
               self.validAdd = false
           }
               //if we got a placemark, the address is good and we should use the first and most relevant one for the coordinate
           if let placemark = placemarks?.first {
               self.validAdd = true
               self.coord = placemark.location!.coordinate
              }
            })
       }

}
