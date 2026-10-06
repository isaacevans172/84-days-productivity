//
//  TaskData.swift
//  84Days
//
//  Created by Eli Mangwiro on 5/10/2026.
//


import SwiftData
import Foundation

@Model
class TaskData {
    var name: String
    var isComplete: Bool
    var icon: String
    var priority: String
    
    init(name:String,
         isComplete:Bool = false,
         priority: String,
         icon: String
    ) {
        self.name = name
        self.isComplete = isComplete
        self.priority = priority
        self.icon = icon
    }
}
