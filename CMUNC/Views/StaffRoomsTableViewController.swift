//
//  StaffRoomsTableViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/27/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import Alamofire

class StaffRoomsTableViewController: UITableViewController {

    var curSession: Int!
    var staffResponse: StaffResponseItem!
    var selectedRow: Int!
    var committeeTimes: [CommitteeTime]!
    var delegate: PasswordEnterViewController?
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        refresh()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        rightSwipe.direction = .right
//        view.addGestureRecognizer(rightSwipe)
        
        refresh(self)
        
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if staffResponse != nil {
            return staffResponse.staffRooms.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "staffRoomCell")
        let room = staffResponse.staffRooms[indexPath.row]
        let nameLabel = cell?.viewWithTag(1000) as! UILabel
        nameLabel.text = staffResponse.staffRooms[indexPath.row].name
        let roomLabel = cell?.viewWithTag(1001) as! UILabel
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
        let curDate = Date()
        for i in 0..<committeeTimes.count {
            if curDate < dateFormatter.date(from: committeeTimes[i].end)! {
                roomLabel.text = staffResponse.staffRooms[indexPath.row].rooms[i]
                return cell!
            }
        }
        noRoomsError()
        return UITableViewCell()
    }
    
    func noRoomsError() {
        let alert = UIAlertController(title: "No staff rooms available", message: "There are no staff rooms available now. Please check your internet connection and try again later.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.close(self)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "staffRoomsDetailViewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "staffRoomsDetailViewSegue" {
            let roomItem = staffResponse.staffRooms[selectedRow]
            var scheduleText = ""
            for i in 0..<roomItem.rooms.count {
                scheduleText += staffResponse.sessions[i] + ":\n\t" + roomItem.rooms[i] + "\n\n"
            }
            let staffRoomDetailViewController = segue.destination as! StaffRoomDetailViewController
            staffRoomDetailViewController.scheduleText = scheduleText
            staffRoomDetailViewController.navigationItem.title = roomItem.name
        }
    }
    
    @IBAction func close(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    @IBAction func refresh(_ sender: Any) {
        scrapeStaffRooms { staffResponse in
            do {
                self.staffResponse = staffResponse!
                DispatchQueue.main.async {
                    self.staffResponse.staffRooms = self.staffResponse.staffRooms.sorted {
                        $0.name.replacingOccurrences(of: "The", with: "") < $1.name.replacingOccurrences(of: "The", with: "")
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
                    let curDate = Date()
                    for i in 0..<self.committeeTimes.count {
                        if curDate < dateFormatter.date(from: self.committeeTimes[i].end)! {
                            self.curSession = i
                            self.tableView.reloadData()
                            return
                        }
                    }
                    self.noRoomsError()
                }
            } catch {
                print(error.localizedDescription)
                self.noRoomsError()
            }
        }
    }
    
    func scrapeStaffRooms(completion: @escaping (StaffResponseItem?) -> Void) {
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("https://thecias.github.io/CMUNC/staff.json", method: .get).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let staffResponse = try? decoder.decode(StaffResponseItem.self, from: data) {
                    completion(staffResponse)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
//    func scrapeStaffRooms(completion: @escaping (([RoomItem], Int)) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/staff.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var rooms = [RoomItem]()
//        var currSession = 0
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    let dataJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    currSession = dataJSON!["currSession"] as! Int
//                    let staffRoomsJSONArray = dataJSON!["staffRooms"]! as! [[String: Any]]
//                    for room in staffRoomsJSONArray {
//                        var newRoom = RoomItem(committee: room["name"]! as! String, image: "", rooms: room["rooms"] as! [String])
//                        rooms.append(newRoom)
//                    }
//                }
//            }
//            catch { print("Scrape schedule error")}
//            completion((rooms, currSession))
//        }
//        task.resume()
//        //return schedule
//    }
//
//    func scrapeSessionNames(completion: @escaping ([String]) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/rooms.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var sessionNames = [String]()
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    let dataJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    sessionNames = dataJSON!["sessions"]! as! [String]
//                }
//            }
//            catch { print("Scrape session names error")}
//            completion(sessionNames)
//        }
//        task.resume()
//        //return schedule
//    }
    
}
