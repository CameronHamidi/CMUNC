//
//  PasswordEnterViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 9/7/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit

protocol EnterPassword: class {
    func enterPassword(enterPassword: String, correctPassword: Bool, passwordType: PasswordType)
}

enum PasswordType {
    case advisor
    case staff
}

class PasswordEnterViewController: UIViewController {

    var viewControllerDelegate: ViewController?
    var correctPassword: String?
    var passwordType: PasswordType!
    var committeeTimes: [CommitteeTime]!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordEnterField: UITextField!
    
//    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
//        if sender.direction == .right {
//            dismiss(animated: true, completion: nil)
//        }
//    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func done(_ sender: Any) {
        if passwordEnterField.text == correctPassword! {
            if viewControllerDelegate != nil {
                viewControllerDelegate!.enterPassword(enterPassword: passwordEnterField.text!, correctPassword: true, passwordType: passwordType)
            }
            switch passwordType! {
            case .advisor:
                performSegue(withIdentifier: "passwordToAdvisorView", sender: self)
            case .staff:
                performSegue(withIdentifier: "passwordToStaffView", sender: self)
            }
        } else {
            let alert = UIAlertController(title: "Incorrect Password", message: "Please enter the correct password. If you have forgotten the password, contact the Secretary-General or Director-General", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: {
                action in
                self.cancel(self)
            })
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passwordToAdvisorView" {
            let navController = segue.destination as! UINavigationController
            let advisorView = navController.childViewControllers[0] as! AdvisorTableViewController
            advisorView.committeeTimes = self.committeeTimes
            advisorView.delegate = self
        } else if segue.identifier == "passwordToStaffView" {
            let navController = segue.destination as! UINavigationController
            let staffView = navController.childViewControllers[0] as! StaffRoomsTableViewController
            staffView.committeeTimes = self.committeeTimes
            staffView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch passwordType!{
        case .advisor:
            passwordLabel.text = "Enter the advisor password:"
        case .staff:
            passwordLabel.text = "Enter the staff password."
        }
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        rightSwipe.direction = .right
//        view.addGestureRecognizer(rightSwipe)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
