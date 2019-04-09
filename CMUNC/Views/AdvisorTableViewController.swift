//
//  AdvisorTableViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 9/7/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class AdvisorTableViewController: UITableViewController {

    var committeeTimes: [CommitteeTime]!
    var correctPassword: String?
    var secretariatInfo: [SecretariatInfoResponse]!
    var meetings: [MeetingItem]!
    var delegate: PasswordEnterViewController?
    var meetingViewController: AdvisorMeetingsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        rightSwipe.direction = .right
//        view.addGestureRecognizer(rightSwipe)
        refresh()
        
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
                close(self)
            }
            break
        default:
            break
        }
    }
    
//    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
//        if sender.direction == .right {
//            close(self)
//        }
//    }

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
        return 2
    }

    
    @IBAction func close(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdvisorCell", for: indexPath)
        let label = cell.viewWithTag(1000) as! UILabel
        if indexPath.row == 0 {
            label.text = "Secretariat Information"
        } else if indexPath.row == 1 {
            label.text = "Advisor Meetings"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "showSecretariatInfo", sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "showAdvisorMeetings", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSecretariatInfo" {
            let destination = segue.destination as! SecretariatInfoViewController
            destination.secretariatInfo = self.secretariatInfo
        } else if segue.identifier == "showAdvisorMeetings" {
            let destination = segue.destination as! AdvisorMeetingsTableViewController
            destination.meetings = meetings
            meetingViewController = destination
        }
    }
    
    func refresh() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
        let curDate = Date()
        for i in 0..<self.committeeTimes.count {
            if curDate < dateFormatter.date(from: self.committeeTimes[i].end)! {
                scrapeInfo { headDelData in
                    self.meetings = headDelData!.meetings
                    self.secretariatInfo = headDelData!.secretariatInfo
                    DispatchQueue.main.async {
                        self.meetingViewController?.meetings = self.meetings
                    }
                }
                return
            }
        }
        noInfoError()
    }
    
    func noInfoError() {
        let alert = UIAlertController(title: "No head delegate available", message: "There is no head delegate information available now. Please check your internet connection and try again later.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.close(self)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func scrapeInfo(completion: @escaping (AdvisorDataResponse?) -> Void) {
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("https://thecias.github.io/CMUNC/advisorData.json", method: .get).validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let advisorData = try decoder.decode(AdvisorDataResponse.self, from: data)
                    completion(advisorData)
                } catch {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
//    func scrapeInfo(completion: @escaping ((JSON, [MeetingItem])) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/advisorData.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var secretariatInfoJSON = JSON()
//        var scrapedMeetings = [MeetingItem]()
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                print("Getting information from website")
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    do {
//                        let dataJSON = try JSON(data: data)
//                        let secretariatData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                        secretariatInfoJSON = dataJSON["secretariatInfo"]
//                        let meetingsArray = try secretariatData!["meetings"] as? [[String: String]]
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
//            completion((secretariatInfoJSON, scrapedMeetings))
//        }
//        task.resume()
//    }

}
