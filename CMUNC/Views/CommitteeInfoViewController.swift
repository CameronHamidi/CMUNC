//
//  CommitteeInfoViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/15/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import SDWebImage

class CommitteeInfoViewController: UIViewController {

    
    @IBOutlet weak var committeeImage: UIImageView!
    @IBOutlet weak var scheduleTextView: UITextView!
    var committee: RoomItem!
    var scheduleText: String!
    @IBOutlet weak var committeeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.title = committee!.committee
        scheduleTextView.text = scheduleText!
        committeeImage.sd_setImage(with: URL(string: "https://thecias.github.io/CMUNC/CommitteeImages/" + committee!.image), completed: nil)
        committeeLabel.text = committee!.committee
        // Do any additional setup after loading the view.
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
                navigationController?.popViewController(animated: true)
            }
            break
        default:
            break
        }
    }
    
//    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
//        if sender.direction == .right {
//            navigationController?.popViewController(animated: true)
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

}
