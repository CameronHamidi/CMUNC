////
////  RoomTableViewController.swift
////  CMUNC
////
////  Created by Cameron Hamidi on 8/29/18.
////  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
////
//
//import UIKit
//
//class RoomTableViewController: UITableViewController {
//
//    var rooms: [RoomItem]
//    var selectedRow: Int?
//    var associatedRow: Int
//    
//    required init?(coder aDecoder: NSCoder) {
//        rooms = [RoomItem]()
//        associatedRow = 0
//        super.init(coder: aDecoder)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        print("celling refresh")
//        refresh(self)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        var selectedRowConstant = 0
//        if self.selectedRow != nil {
//            selectedRowConstant = 1
//        }
//        return rooms.count + selectedRowConstant
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if selectedRow != nil && indexPath.row == selectedRow {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
//            let room = rooms[selectedRow! - 1]
//            let label = cell.viewWithTag(1000) as! UILabel
//            label.text = room
//            label.adjustsFontSizeToFitWidth = true
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CommitteeCell", for: indexPath)
//            let committee = rooms[indexPath.row].committee
//            let label = cell.viewWithTag(1000) as! UILabel
//            label.text = committee
//            label.adjustsFontSizeToFitWidth = true
//            return cell
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if tableView.cellForRow(at: indexPath) != nil {
//            //showTappedRoomAlert(room: rooms[indexPath.row])
//            let savedSelectedRow = selectedRow
//            if selectedRow != nil {
//                let newIndexPath = IndexPath(row: selectedRow!, section: 0)
//                selectedRow = nil
//                tableView.deleteRows(at: [newIndexPath], with: UITableViewRowAnimation.top)
//            }
//            if savedSelectedRow == nil || savedSelectedRow! - 1 > indexPath.row {
//                selectedRow = indexPath.row + 1
//                let newIndexPath = IndexPath(row: selectedRow!, section: 0)
//                associatedRow = indexPath.row
//                tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.bottom)
//            } else if savedSelectedRow! < indexPath.row {
//                selectedRow = indexPath.row
//                tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
//            }
//            tableView.deselectRow(at: indexPath, animated: false)
//        }
//    }
//    
//    @IBAction func refresh(_ sender: Any) {
//        scrapeRooms { rooms in
//            self.rooms = rooms
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//    
//    @IBAction func back(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func scrapeRooms(completion: @escaping ([RoomItem]) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/rooms.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var readRooms = [RoomItem]()
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                print("Getting information from website")
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    do {
//                        let roomsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                        let session = roomsJSON!["session"] as! String
//                        print(session)
//                        if session == "" {
//                            self.showUnavailableRoomsAlert()
//                        } else {
//                            self.navigationItem.title = session
//                            let currSessionJSON = roomsJSON!["rooms"] as! [[String: String]]
//                            print(currSessionJSON)
//                            for room in currSessionJSON {
//                                let newRoomItem = RoomItem(committee: room["committee"]!, room: room["room"]!)
//                                readRooms.append(newRoomItem)
//                            }
//                        }
//                    }
//                    catch { print(error)}
//                }
//            }
//            completion(readRooms)
//            //completionHandler(loops)
//        }
//        task.resume()
//    }
//    
//    /*func scrapeRooms() -> [String] {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/appData.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var readRooms = [String]()
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                print("Getting information from website")
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data,
//                    let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                        //do {
//                        //let jsonDecoder = JSONDecoder()
//                        let decodedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                        let roomsJSON = decodedData!["roomAssignments"] as! [String: Any]
//                        let session = roomsJSON["session"] as! String
//                    print(session)
//                        if session == "" {
//                            self.showUnavailableRoomsAlert()
//                        } else {
//                            self.navigationController?.title = session
//                            readRooms = roomsJSON["rooms"] as! [String]
//                        }
//                    }
//            }
//            catch { print(error)}
//        }
//        task.resume()
//        return readRooms
//    }
// */
//    
//    @IBAction func close(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func showUnavailableRoomsAlert() {
//        let message = "No room assignments available. Check back later."
//        let alert = UIAlertController(title: "No room assignments available", message: message, preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: {
//            action in
//            self.dismiss(animated: true, completion: nil)
//            })
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    func showTappedRoomAlert(room: String) {
//        let message = room
//        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        let action = UIAlertAction(title: "Close", style: .default, handler: nil)
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
//    
//}
