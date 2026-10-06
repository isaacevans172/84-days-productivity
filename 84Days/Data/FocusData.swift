//
//  Untitled.swift
//  84Days
//
//  Created by Eli Mangwiro on 6/10/2026.
//

import SwiftData
import Foundation

@Model
class QuoteData {
    var duration: Duration
    var breaktime: TimeInterval // max: 25 mins potentially
    var startDateTime: DateInterval
    
    init(message: String, duration: TimeInterval, startDateTime: DateInterval) {
        self.duration = Duration
        self.startDateTime = startDateTime
    }
}
