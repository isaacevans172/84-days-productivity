import Foundation
import EventKit
import Combine

@MainActor
final class AppleCalendarManager: ObservableObject {
    
    private let eventStore = EKEventStore()
    
    @Published private(set) var isConnected = false
    @Published private(set) var calendars: [EKCalendar] = []
    @Published private(set) var events: [EKEvent] = []
    
    @Published var errorMessage: String?
    
    private var changeObserver: NSObjectProtocol?
    
    init() {
        updateAuthorizationStatus()
        
        changeObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }
    
    deinit {
        if let changeObserver {
            NotificationCenter.default.removeObserver(changeObserver)
        }
    }
    
    func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            
            if granted {
                isConnected = true
                loadCalendars()
            } else {
                isConnected = false
            }
        } catch {
            isConnected = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func updateAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        isConnected = status == .fullAccess
        
        if isConnected {
            loadCalendars()
        }
    }
    
    func loadCalendars() {
        calendars = eventStore
            .calendars(for: .event)
            .sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title)
                == .orderedAscending
            }
    }
    
    func loadEvents(
        from startDate: Date,
        to endDate: Date
    ) {
        guard isConnected else {
            events = []
            return
        }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        
        events = eventStore
            .events(matching: predicate)
            .sorted {
                $0.startDate < $1.startDate
            }
    }
    
    func refresh() {
        guard isConnected else {
            return
        }
        
        loadCalendars()
    }
    
    func clearEvents() {
        events = []
        calendars = []
        isConnected = false
    }
}
