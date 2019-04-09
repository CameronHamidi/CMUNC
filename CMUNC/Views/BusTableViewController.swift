//
//  BusTableViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/29/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import Alamofire

class BusTableViewController: UITableViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    var busResponse: BusResponseItem!
    var displayDay: Int!
    @IBOutlet weak var prevDayButton: UIBarButtonItem!
    @IBOutlet weak var nextDayButton: UIBarButtonItem!
    var panGesture: UIPanGestureRecognizer!
    var startDate: Date!
    var numDays: Int!
    
    required init?(coder aDecoder: NSCoder) {
        displayDay = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prevDayButton.isEnabled = false
        nextDayButton.isEnabled = false
        
        if startDate == nil || numDays == nil {
            noInfoError()
            return
        }
        
        if setDate() {
            refresh(self)
        }
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
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
            if panned.x > initialPoint.x { //right swipe
                if prevDayButton.isEnabled {
                    prevDay(self)
                } else {
                    dismiss(animated: true, completion: nil)
                }
            } else if panned.x < initialPoint.x { //left swipe
                if nextDayButton.isEnabled {
                    nextDay(self)
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            if prevDayButton.isEnabled {
                prevDay(self)
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else if sender.direction == .left {
            if nextDayButton.isEnabled {
                nextDay(self)
            }
        }
    }
    
    func noInfoError() {
        var alert = UIAlertController(title: "No bus information available", message: "There is no bus information currently available. Please check your internet connection and try again later.", preferredStyle: .alert)
        var action = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func setDate() -> Bool {
        var curDate = Date()
        let calendar = Calendar.current
        var curDay = calendar.component(.day, from: curDate)
        
        if curDate < startDate {
            displayDay = 0
            return true
        }
        
        for i in 1..<numDays {
            var newDate = calendar.date(byAdding: .day, value: i, to: startDate)
            if curDate < newDate! {
                displayDay = i - 1
                return true
            }
        }
        if curDate < calendar.date(byAdding: .day, value: numDays, to: startDate)! {
            displayDay = numDays - 1
            return true
        }
        noBusesError()
        return false
        
    }
    
    func noBusesError() {
        let alert = UIAlertController(title: "No buses available", message: "There is no bus information available now. Please check your internet connection and try again later.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.close(self)
            })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
//
//    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer){
//
//
//        let interactiveTransition = UIPercentDrivenInteractiveTransition()
//
//        let percent = max(gesture.translation(in: view).x, 0) / view.frame.width
//
//        switch gesture.state {
//
//        case .began:
//            dismiss(animated: true, completion: nil)
//
//        case .changed:
//            interactiveTransition.update(percent)
//
//        case .ended:
//            let velocity = gesture.velocity(in: view).x
//
//            // Continue if drag more than 50% of screen width or velocity is higher than 1000
//            if percent > 0.5 || velocity > 1000 {
//                interactiveTransition.finish()
//            } else {
//                interactiveTransition.cancel()
//            }
//
//        case .cancelled, .failed:
//            interactiveTransition.cancel()
//
//        default:break
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddressesSegue" {
            let destination = segue.destination as! AddressViewController
            destination.addresses = busResponse.addresses
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(77)
    }

    func reloadData() {
        tableView.reloadData()
        do {
            if busResponse.buses.count != 0 {
                self.navigationItem.title = busResponse.buses[displayDay].day
            }
        } catch {
            noBusesError()
        }
    }
    
    func configureDayButtons() {
        if busResponse.buses.count == 0 {
            prevDayButton.isEnabled = false
            nextDayButton.isEnabled = false
        } else {
            if displayDay == 0 {
                prevDayButton.isEnabled = false
            } else {
                prevDayButton.isEnabled = true
            }
            
            if displayDay == busResponse.buses.count - 1 {
                nextDayButton.isEnabled = false
            } else {
                nextDayButton.isEnabled = true
            }
        }
    }
    
    @IBAction func prevDay(_ sender: Any) {
        if displayDay != 0 {
            displayDay -= 1
            configureDayButtons()
            reloadData()
        }
    }
    
    @IBAction func nextDay(_ sender: Any) {
        if displayDay != busResponse.buses.count - 1 {
            displayDay += 1
            configureDayButtons()
            reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if busResponse == nil || busResponse.buses.count == 0 {
            return 0
        } else {
            return busResponse.buses[displayDay].buses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busDay = busResponse.buses[displayDay]
        let busItem = busDay.buses[indexPath.row]
        let name = busItem.bus
        let time = busItem.time
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "busCell", for: indexPath)
        let nameLabel = cell.viewWithTag(1000) as! UILabel
        nameLabel.text = name
        nameLabel.adjustsFontSizeToFitWidth = true
        
        let timeLabel = cell.viewWithTag(1001) as! UILabel
        timeLabel.text = time
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.tableView(self.tableView, didSelectRowAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        var busDay = busResponse.buses[displayDay]
        var busLoop = busDay.buses[indexPath.row]
        var info = busLoop.info
        var alert = UIAlertController(title: "Bus Information", message: info, preferredStyle: .alert)
        var action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var busDay = busResponse.buses[displayDay]
        var busLoop = busDay.buses[indexPath.row]
        var info = busLoop.info
        var alert = UIAlertController(title: "Bus Information", message: info, preferredStyle: .alert)
        var action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        scrapeBuses { busResponse in
            do {
                self.busResponse = busResponse
                DispatchQueue.main.async {
                    self.reloadData()
                    self.configureDayButtons()
                }
            } catch {
                print(error.localizedDescription)
                self.noBusesError()
            }
        }
    }
    
    func scrapeBuses(completion: @escaping (BusResponseItem?) -> Void) {
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("https://thecias.github.io/CMUNC/buses.json", method: .get).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let busResponse = try? decoder.decode(BusResponseItem.self, from: data) {
                    completion(busResponse)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
//
//    func scrapeBuses(completion: @escaping (([BusDayItem], [[String: String]])) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/buses.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var busDays = [BusDayItem]()
//        var addresses = [[String: String]]()
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    let busJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    addresses = busJSON?["addresses"] as! [[String: String]]
//                    let busDaysArrayJSON = busJSON?["buses"] as! [[String: Any]]?
//                    for busDay in busDaysArrayJSON! {
//                        var newBusDay = BusDayItem(day: busDay["day"] as! String, busItems: [])
//                        for busItem in busDay["buses"] as! [[String: String]] {
//                            var newBusItem = BusItem(name: busItem["bus"]!, time: busItem["time"]!)
//                            newBusDay.busItems.append(newBusItem)
//                        }
//                        busDays.append(newBusDay)
//                    }
//                    completion((busDays, addresses))
//                }
//            }
//            catch { print("Scrape buses error")}
//        }
//        task.resume()
//    }

}
