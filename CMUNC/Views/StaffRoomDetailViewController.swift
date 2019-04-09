//
//  StaffRoomDetailViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/29/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit

class StaffRoomDetailViewController: UIViewController {

    
    @IBOutlet weak var scheduleTextView: UITextView!
    var scheduleText: String!
    
//    required init?(coder aDecoder: NSCoder) {
//        scheduleText = ""
//        super.init(coder: aDecoder)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleTextView.text = scheduleText

//         Do any additional setup after loading the view.
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        var initialPoint: CGPoint = .zero
        switch sender.state {
        case .began:
            initialPoint = sender.translation(in: self.view)
            break
        case .changed:
            let panned = sender.translation(in: self.view)
            if panned.x > initialPoint.x {
                navigationController?.popViewController(animated: true)
            }
            break
        default:
            break
        }
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func close(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
}
