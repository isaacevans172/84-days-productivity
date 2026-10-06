//
//  Task.swift
//  84Days
//
//  Created by Eli Mangwiro on 5/10/2026.
//

import SwiftData
import Foundation

@Model
class ReflectionData {
    var rating: Int //(1-5)
    var date: Date
    
    init(rating: Int, date: Date) {
        self.rating = rating
        self.date = date
    }
}
