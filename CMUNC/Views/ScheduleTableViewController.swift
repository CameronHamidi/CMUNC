//
//  ScheduleTableViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 9/1/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class ScheduleTableViewController: UITableViewController {

    var schedule: [DayItem]!
    var displayDay: Int!
    @IBOutlet weak var prevDayButton: UIBarButtonItem!
    @IBOutlet weak var nextDayButton: UIBarButtonItem!
    var startDate: Date!
    var numDays: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //schedule = scrapeSchedule()
//        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)//action: #selector(addTapped))
//        navigationController!.toolbarItems = [add]
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        self.prevDayButton.isEnabled = false
        self.nextDayButton.isEnabled = false
        
        if startDate == nil || numDays == nil {
            noInfoError()
            return
        }
        
        if setDate() {
            refresh(self)
        }
        
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
        var alert = UIAlertController(title: "No schedule information available", message: "There is no schedule information currently available. Please check your internet connection and try again later.", preferredStyle: .alert)
        var action = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.displayDay = 0
        self.schedule = [DayItem]()
        self.numDays = 0
        super.init(coder: aDecoder)
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
        noScheduleError()
        return false
        
    }
    
    func noScheduleError() {
        let alert = UIAlertController(title: "No schedule available", message: "There is no schedule information available now. Please check your internet connection and try again later.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.close(self)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func reloadData() {
        tableView.reloadData()
        if schedule.count != 0 {
            self.navigationItem.title = self.schedule[self.displayDay].day
        }
    }
    
    func configureDayButtons() {
        if schedule.count == 0 {
            prevDayButton.isEnabled = false
            nextDayButton.isEnabled = false
        } else {
            prevDayButton.isEnabled = true
            nextDayButton.isEnabled = true
            
            if displayDay == 0 {
                prevDayButton.isEnabled = false
            }
            
            if displayDay == numDays! - 1 {
                nextDayButton.isEnabled = false
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
        if displayDay != numDays! - 1 {
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
        if schedule.count != 0 {
            return schedule[displayDay].events.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dayItem = schedule[displayDay]
        let eventItem = dayItem.events[indexPath.row]
        let identifier = eventItem.identifier
        let eventOrTimeText = eventItem.event

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = eventOrTimeText
        if identifier == "event" || identifier == "eventDDI" {
            label.adjustsFontSizeToFitWidth = true
        } else if identifier == "time" || identifier == "location" {
           label.sizeToFit()
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.tableView(self.tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if schedule[displayDay].events[indexPath.row].information != nil {
            let message = schedule[displayDay].events[indexPath.row].information
            let alert = UIAlertController(title: schedule[displayDay].events[indexPath.row].event, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        scrapeSchedule { schedule in
            do {
                self.schedule = schedule!
                DispatchQueue.main.async {
                    self.setDate()
                    self.reloadData()
                    self.numDays = self.schedule.count
                    self.configureDayButtons()
                }
            }
            catch {
                self.noScheduleError()
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       // if schedule.
        if schedule.count != 0 {
            let event = schedule[displayDay].events[indexPath.row]
            if event.identifier == "time" && event.event.count > 51 {
                return 75
            } else if event.identifier == "time" && event.event.count > 31 {
                let additionalChars = event.event.count - 31
                var quotient: Float = Float(additionalChars) / 20.0
                quotient = quotient.rounded(.up)
                return CGFloat(quotient * 14 + 40)
            }
        }
        return 34
    }
    
    func scrapeSchedule(completion: @escaping ([DayItem]?) -> Void) {
        var schedule = [DayItem]()
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("https://thecias.github.io/CMUNC/schedule.json", method: .get).validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSON(data: data)
                    for (index,day):(String, JSON) in json {
                        schedule.append(self.organizeScheduleJSON(dayJSON: day))
                    }
                    completion(schedule)
                } catch {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }

    func organizeScheduleJSON(dayJSON: JSON) -> DayItem {
        do {
            var events = [EventItem]()
            for (index,event):(String, JSON) in dayJSON["eventTimes"] {
                if event["information"].string != nil {
                    events.append(EventItem(event: event["event"].string!, identifier: "eventDDI", information: event["information"].string!))
                } else {
                    events.append(EventItem(event: event["event"].string!, identifier: "event"))
                }
                if event["location"].string != nil {
                    events.append(EventItem(event: event["location"].string!, identifier: "location"))
                }
                if event["times"].array != nil {
                    var timeArray = event["times"].arrayValue.map({$0.stringValue})
                    for time in timeArray {
                        events.append(EventItem(event: time, identifier: "time"))
                    }
                }
            }
            return DayItem(day: dayJSON["day"].string!, events: events)
        }
        catch {
            noScheduleError()
        }
    }
}

//func neworganizeScheduleJSON(scheduleJSON: [String: Any], dayIndex: Int) -> DayItem {
//    let returnDayItem = DayItem()
//    returnDayItem.day = scheduleJSON["day"] as! String
//    let eventTimesArray = scheduleJSON["eventTimes"] as! [[String : Any]]
//    for event in eventTimesArray {
//        let eventName = event["event"] as! String
//        returnDayItem.events.append(EventItem(event: eventName, identifier: "event"))
//        let timesArray = event["times"] as! [String]
//        for time in timesArray {
//            let timeEventItem = EventItem(event: time, identifier: "time")
//            returnDayItem.events.append(timeEventItem)
//        }
//    }
//    return returnDayItem
//}
