//
//  Untitled.swift
//  84Days
//
//  Created by Eli Mangwiro on 6/10/2026.
//

import SwiftUI
import MapKit


class EventData {
    
    var date: Date
    var title: String
    @State private var selectedPlace: MKMapItem
    
    init(date: Date, title: String, selectedPlace: MKMapItem) {
        self.date = date
        self.title = title
        self.selectedPlace = selectedPlace
    
    }
}
