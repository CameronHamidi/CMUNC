//
//  LostDelegatesViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 4/2/19.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import Mailgun_In_Swift
import CoreLocation

class LostDelegatesViewController: UIViewController, UITextViewDelegate {
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var committeeTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    let notesTextViewPlaceholder = "The app can determine your approximate location, but additional information (such as the building and room you are currently in, nearby landmarks, etc) will help us reach you faster."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
        notesTextView.delegate = self
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor(white: 2/3.0, alpha: 1.0).cgColor
        notesTextView.layer.cornerRadius = 5
        
        submitButton.layer.cornerRadius = 5
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.lightGray.cgColor
        
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        rightSwipe.direction = .right
//        view.addGestureRecognizer(rightSwipe)
        
        locationManager = CLLocationManager()
        // Ask for Authorisation from the User.
//        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            if locationManager.location?.coordinate == nil {
                noLocationServicesAlert()
            }
        } else {
            noLocationServicesAlert()
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        var initialPoint: CGPoint = .zero
        switch sender.state {
        case .began:
            initialPoint = sender.translation(in: self.view)
            break
        case .changed:
            let panned = sender.translation(in: self.view)
            if panned.x > initialPoint.x { //right swipe
                dismiss(animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
    
    //    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
    //        if sender.direction == .right {
    //            dismiss(animated: true, completion: nil)
    //        }
    //    }
    
    func noLocationServicesAlert() {
        var alert = UIAlertController(title: "Enable Location Services", message: "In order to determine your location so that we may send a staffer to assist you, the app needs to know your GPS coordinates. In Settings, please enable location services and allow the CMUNC app to view your location.", preferredStyle: .alert)
        var action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.notesTextView {
            if textView.text == self.notesTextViewPlaceholder {
                textView.text = ""
                textView.textColor = .black
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        if nameTextField.text == "" || phoneTextField.text == "" || committeeTextField.text == "" || schoolTextField.text == "" || destinationTextField.text == "" || notesTextView.text == "" || notesTextView.text == notesTextViewPlaceholder {
            displayIncompleteAlert()
        } else {
            var name = nameTextField.text!
            var phone = phoneTextField.text!
            var committee = committeeTextField.text!
            var school = schoolTextField.text!
            var destination = destinationTextField.text!
            var notes = notesTextView.text!
            
            var coordinates = locationManager.location?.coordinate
            if coordinates == nil {
                locationManager.requestWhenInUseAuthorization()
                noLocationServicesAlert()
                return
            }
            var latitude = coordinates!.latitude
            var longitude = coordinates!.longitude
            
            print(latitude)
            print(longitude)
            
            
//            let mailgun = MailgunAPI(apiKey: appDataResponse.apiKey, clientDomain: appDataResponse.clientDomain)


            var bodyIntro = "<body><b>Delegate Information:</b></body>"
            var bodyName = "<body>Name: \(name)</body>"
            var bodyPhone = "<body>Phone: \(phone)</body>"
            var bodyCommittee = "<body>Committee: \(committee)</body>"
            var bodySchool = "<body>School: \(school)</body>"
            var bodyDestination = "<body>Destination: \(destination)</body>"
            var bodyNotes = "<body>Notes: \(notes)</body>"
            var locationNotes = "<body><a href=\"https://www.google.com/maps\">Location (copy and paste into google maps):</a> \(latitude), \(longitude)</body>"

            var emailBody = bodyIntro + bodyName + bodyPhone + bodyCommittee + bodySchool + bodyDestination + bodyNotes

            print(appDataResponse!)
            print(appDataResponse.apiKey)
//            mailgun.sendEmail(to: appDataResponse.toEmail, from: appDataResponse.fromEmail, subject: "Lost Delegate", bodyHTML: emailBody) { mailgunResult in


                if mailgunResult.success{
                    print("Email was sent")
                }

            }
            var alert = UIAlertController(title: "Message Sent", message: "We have received your message. A staffer will arrive at your location shortly. Please do not move.", preferredStyle: .alert)
            var action = UIAlertAction(title: "Ok", style: .default, handler: { alert in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    func displayIncompleteAlert() {
        var alert = UIAlertController(title: "Incomplete Submission", message: "Please fill out all fields.", preferredStyle: .alert)
        var action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
