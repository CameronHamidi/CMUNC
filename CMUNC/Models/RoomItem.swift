//
//  RoomItem.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 10/4/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import Foundation

class RoomResponse: Codable {
    var rooms: [RoomItem]
    var sessions: [String]
}

class RoomItem: Codable {
    var committee: String
    var image: String
    var rooms: [String]
    
    init(committee: String, image: String, rooms: [String]) {
        self.committee = committee
        self.image = image
        self.rooms = rooms
    }
}
