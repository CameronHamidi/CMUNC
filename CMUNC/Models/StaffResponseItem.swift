//
//  StaffResponseItem.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 12/27/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import Foundation

class StaffResponseItem: Codable {
    var staffRooms: [StaffRoomsItem]
    var sessions: [String]
}

class StaffRoomsItem: Codable {
    var name: String
    var rooms: [String]
}
