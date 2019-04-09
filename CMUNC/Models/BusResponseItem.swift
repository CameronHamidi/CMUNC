//
//  BusResponseItem.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 12/27/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import Foundation

class BusResponseItem: Codable {
    var addresses: [AddressItem]
    var buses: [LoopDayItem]
}

class AddressItem: Codable {
    var name: String
    var address: String
}

class LoopDayItem: Codable {
    var day: String
    var buses: [LoopItem]
}

class LoopItem: Codable {
    var bus: String
    var time: String
    var info: String
}
