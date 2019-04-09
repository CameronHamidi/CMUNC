//
//  AddressViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/29/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController {

    
    @IBOutlet weak var addressTextView: UITextView!
    var addresses: [AddressItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var addressText = ""
        for address in addresses {
            addressText += address.name + ":\n" + address.address + "\n\n"
        }
        addressTextView.text = addressText
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
            if panned.x > initialPoint.x {
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @IBAction func close(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
