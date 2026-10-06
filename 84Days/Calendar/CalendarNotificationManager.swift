//
//  CalendarNotificationManager.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//

import Foundation
import UserNotifications

final class CalendarNotificationManager {
    
    static let shared = CalendarNotificationManager()
    
    private init() {}
    
    // MARK: - Permission
    
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule
    
    func scheduleReminder(
        for event: CalendarEvent
    ) async {
        
        guard let minutes = event.reminderMinutes else {
            return
        }
        
        let permissionGranted = await requestPermission()
        
        guard permissionGranted else {
            return
        }
        
        let reminderDate = Calendar.current.date(
            byAdding: .minute,
            value: -minutes,
            to: event.startDate
        ) ?? event.startDate
        
        let content = UNMutableNotificationContent()
        content.title = event.title
        
        if event.location.isEmpty {
            content.body = "Your event is starting soon."
        } else {
            content.body = event.location
        }
        
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [
                .year,
                .month,
                .day,
                .hour,
                .minute
            ],
            from: reminderDate
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current()
                .add(request)
        } catch {
            print("Notification scheduling error: \(error)")
        }
    }
    
    // MARK: - Remove
    
    func removeReminder(for event: CalendarEvent) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [
                    event.id.uuidString
                ]
            )
    }
}
