//
//  AdvisorMeetingsTableViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 9/30/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import SwiftyJSON

class AdvisorMeetingsTableViewController: UITableViewController {

    var delegate: AdvisorTableViewController!
    var meetings: [MeetingItem]!
    var detailViewDisplayMeeting: MeetingItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    @IBAction func refresh(_ sender: Any) {
        delegate.refresh()
    }
    
//    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
//        if sender.direction == .right {
//            navigationController?.popViewController(animated: true)
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        self.meetings = []
        super.init(coder: aDecoder)
//        getMeetingData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meetings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meetingItem = meetings[indexPath.row]
        var cell: UITableViewCell
        if meetingItem.description == "" {
            cell = tableView.dequeueReusableCell(withIdentifier: "meetingCellNoDetail")!
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "meetingCellWithDetail")!
        }
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = meetingItem.date
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if meetings[indexPath.row].description != "" {
            detailViewDisplayMeeting = meetings[indexPath.row]
            performSegue(withIdentifier: "showMeetingDetailView", sender: self)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMeetingDetailView" {
            var destination = segue.destination as! MeetingDetailViewController
            destination.event = detailViewDisplayMeeting!
        }
    }
    
    @IBAction func close(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
//    func getMeetingData() {
//        scrapeMeetings { scrapedMeetings in
//            self.meetings = scrapedMeetings
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    func scrapeMeetings(completion: @escaping ([MeetingItem]) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/advisorData.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var scrapedMeetings = [MeetingItem]()
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                print("Getting information from website")
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    do {
//                        let advisorJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                        let meetingsArray = try advisorJSON!["meetings"] as? [[String: String]]
//                        for meeting in meetingsArray! {
//                            let newDate = meeting["date"]!
//                            let newDescription = meeting["description"]!
//                            let newMeeting = MeetingItem(date: newDate, description: newDescription)
//                            scrapedMeetings.append(newMeeting)
//                        }
//                    }
//                    catch { print(error)}
//                }
//            }
//            completion(scrapedMeetings)
//        }
//        task.resume()
//    }
    

}
