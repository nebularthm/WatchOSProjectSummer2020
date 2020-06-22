//
//  EditLocationController.swift
//  Handled
//
//  Created by Michael Williams on 6/21/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts
class EditLocationController: UIViewController,UITextFieldDelegate {

    var addressText: String?
    var titleText: String?
    var speed: Double?
    var editLoc: LocationModel!
    var oldLoc: LocationModel!
    var velocityStr: String?
    var editDate: Date?
    var validAdd = true
    var coord:CLLocationCoordinate2D?
    let coordToAddress = CLGeocoder()
    let addressDecode = CLGeocoder()
    
    @IBOutlet weak var addressField: UITextField!
    
    
    
    
    
    @IBOutlet weak var titleField: UITextField!
    
    
    
    @IBOutlet weak var speedField: UITextField!
    
    
    
    @IBOutlet weak var dateField: UIDatePicker!
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    @IBOutlet weak var outLabel: UILabel!
    
    
    
    @IBAction func pickDate(_ sender: Any) {
        editDate = dateField.date
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldLoc = editLoc
        speed = editLoc.speed
        speedField.text = speed?.description
        titleText = editLoc.title
        titleField.text = titleText
        editDate = editLoc.date
        dateField.date = editDate!
        convertCoordToString()
        addressField.text = addressText
        titleField.delegate = self
        speedField.delegate = self
        addressField.delegate = self
        outLabel.text = "Edit any fields for this event"
        // Do any additional setup after loading the view.
    }
    
    //this func is for converting the  location data into a string
    func convertCoordToString(){
        coordToAddress.reverseGeocodeLocation(editLoc.calculateLocation(), completionHandler:
            {
                placemarks, error -> Void in

                // Place details
                //got this code from here https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
                guard let placeMark = placemarks?.first else { return }
                let postalAddressFormatter = CNPostalAddressFormatter()
                postalAddressFormatter.style = .mailingAddress
                if let postalAddress = placeMark.postalAddress {
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
              //In the case that the textfields have not been filled out, or the text fields have been erased to have epty Strings, those fields contain data that should not be added to the database
              return !(addressText?.count == 0 || addressText == nil || titleText == nil || titleText?.count == 0)
          }
          //you should either do a return segue if you have not edited anyhting, or you should not do one if editiing is not finished
          override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
              if ((sender as! UIBarButtonItem) == self.cancelButton)  {
                  return true
              }
            if(!checkSpeed()){
                outLabel.text = "Please enter a valid speed"
                return false
            }
            if(!validAdd){
                           outLabel.text = "Please provide a valid address"
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
          
          override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
              speed = doub
              return true
          }
          return false
      }
    
    func convertToLoc(){
           if(addressText?.count == 0 || addressText == nil){
               validAdd = false
               return
           }
        addressDecode.geocodeAddressString(addressText!, completionHandler: {(placemarks, error) -> Void in
           if((error) != nil){
              print("Error", error)
               print("we lowkey have an error")
               self.validAdd = false
           }
               
           if let placemark = placemarks?.first {
               self.validAdd = true
               self.coord = placemark.location!.coordinate
              }
            })
       }

}
