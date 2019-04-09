//
//  AppDataResponse.swift
//  CMUNC
//
//  Created by Cameron Hamidi on 12/29/18.
//  Copyright © 2019 Cornell Model United Nations Conference. All rights reserved.
//

import Foundation

class AppDataResponse: Codable {
    var advisorPassword: String
    var staffPassword: String
    var conferenceStartDate: String
    var numConferenceDays: Int
    var committeeTimes: [CommitteeTime]
    var apiKey: String
    var clientDomain: String
    var toEmail: String
    var fromEmail: String
}

class CommitteeTime: Codable {
    var start: String
    var end: String
}
