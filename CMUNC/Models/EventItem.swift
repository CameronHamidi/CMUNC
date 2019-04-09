//
//  EventItem.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 9/1/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import Foundation

enum EventIdentifier {
    case event
    case time
    case location
}

class EventItem {
    var event: String
    var identifier: String
    var information: String?
    
    init(event: String, identifier: String) {
        self.event = event
        self.identifier = identifier
    }
    
    init(event: String, identifier: String, information: String) {
        self.event = event
        self.identifier = identifier
        self.information = information
    }
}

class DayItem {
    var day: String
    var events: [EventItem]
    
    init(day: String, events: [EventItem]) {
        self.day = day
        self.events = events
    }
    
    init() {
        self.day = ""
        self.events = [EventItem]()
    }
}
