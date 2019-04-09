//
//  RoomsCollectionViewController.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/12/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

private let reuseIdentifier = "Cell"

class RoomsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var rooms: [RoomItem]
    var selectedRoom: Int
    var sessionNumber: Int
    var sessionNames: [String]
    var committeeTimes: [CommitteeTime]!
    
    required init?(coder aDecoder: NSCoder) {
        rooms = [RoomItem]()
        selectedRoom = 0
        sessionNumber = 0
        sessionNames = [String]()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        refresh(self)
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
                dismiss(animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
    
//    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
//        if sender.direction == .right {
//            dismiss(animated: true, completion: nil)
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return rooms.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomCell", for: indexPath)
    
        let roomItem = rooms[indexPath.row]
        let committeeLabel = cell.viewWithTag(1000) as! UILabel
        committeeLabel.text = roomItem.committee
        let roomLabel = cell.viewWithTag(1001) as! UILabel
        roomLabel.text = rooms[indexPath.row].rooms[sessionNumber]
        let committeeImage = cell.viewWithTag(1004) as! UIImageView
        committeeImage.sd_setImage(with: URL(string: "https://thecias.github.io/CMUNC/CommitteeImages/" + roomItem.image), completed: nil)
    
        let mainView = cell.viewWithTag(1003) as! UIView
        
        mainView.layer.cornerRadius = 10.0
        mainView.layer.borderWidth = 1.0
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.masksToBounds = true
        //mainView.clipsToBounds = true
        
        let shadowView = cell.viewWithTag(1002) as! UIView
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        shadowView.layer.shadowRadius = 2.0
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.masksToBounds = false
        //shadowView.clipsToBounds = true
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: mainView.layer.cornerRadius).cgPath
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
//        cell.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            cell.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            cell.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            cell.heightAnchor.constraint(equalToConstant: 133)
//            ])
        
//        let width = collectionView.frame.size.width
//        cell.contentView.bounds.size.width = width
//        cell.contentView.setNeedsLayout()
//        cell.contentView.layoutIfNeeded()
//        let height = cell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: UILayoutFittingCompressedSize.height)).height
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.width, height: 133)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRoom = indexPath.row
        performSegue(withIdentifier: "showCommitteeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommitteeSegue" {
            let destination = segue.destination as! CommitteeInfoViewController
            destination.committee = rooms[selectedRoom]
            var committeeScheduleText = ""
            for x in 0..<committeeTimes.count {
                committeeScheduleText.append(sessionNames[x] + ":\n\t" + rooms[selectedRoom].rooms[x] + "\n\n")
            }
            destination.scheduleText = committeeScheduleText
        }
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        scrapeRooms { roomResponse in
            if roomResponse != nil {
                self.rooms = roomResponse!.rooms
                self.sessionNames = roomResponse!.sessions
                DispatchQueue.main.async {
                    self.rooms = self.rooms.sorted {
                        $0.committee.replacingOccurrences(of: "The", with: "") < $1.committee.replacingOccurrences(of: "The", with: "")
                    }
                    let curDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
                    for i in 0..<self.committeeTimes.count {
                        if curDate < dateFormatter.date(from: self.committeeTimes[i].end)! {
                            self.sessionNumber = i
                            self.collectionView?.reloadData()
                            return
                        }
                    }
                    
                    self.showUnavailableRoomsAlert()
                }
            } else {
                DispatchQueue.main.async {
                    self.showUnavailableRoomsAlert()
                }
            }
        }
    }
    
    func scrapeRooms(completion: @escaping (RoomResponse?) -> Void) {
        URLCache.shared.removeAllCachedResponses()
        Alamofire.request("https://thecias.github.io/CMUNC/rooms.json", method: .get).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let roomResponse = try? decoder.decode(RoomResponse.self, from: data) {
                    completion(roomResponse)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
    
//    func scrapeRooms(completion: @escaping (([RoomItem], Int, [String], Int)) -> Void) {
//        let config = URLSessionConfiguration.default
//        //config.waitsForConnectivity = true
//        let defaultSession = URLSession(configuration: config)
//        let url = URL(string: "https://thecias.github.io/CMUNC/rooms.json")
//        let request = NSMutableURLRequest(url: url!)
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        var readRooms = [RoomItem]()
//        var sessionNumber = 0
//        var sessionNames = [String]()
//        var numSessions = 0
//        let task = defaultSession.dataTask(with: request as URLRequest) { data, response, error in
//            do {
//                print("Getting information from website")
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
//                    do {
//                        let roomsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                        sessionNumber = roomsJSON!["session"] as! Int
//                        if sessionNumber == 0 {
//                            self.showUnavailableRoomsAlert()
//                        } else {
//                            sessionNames = roomsJSON!["sessions"] as! [String]
//                            numSessions = roomsJSON!["numSessions"] as! Int
//                            let currSessionJSON = roomsJSON!["rooms"] as! [[String: Any]]
//                            for room in currSessionJSON {
//                                let newRoomItem = RoomItem(committee: room["committee"]! as! String, image: room["image"]! as! String, rooms: room["rooms"]! as! [String])
//                                readRooms.append(newRoomItem)
//                            }
//                        }
//                    }
//                    catch { print(error)}
//                }
//            }
//            completion((rooms: readRooms, sessionNumber: sessionNumber - 1, sessionNames, numSessions))
//        }
//        task.resume()
//    }

    func showUnavailableRoomsAlert() {
        let message = "No room assignments available. Check back later."
        let alert = UIAlertController(title: "No room assignments available", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: {
            action in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
