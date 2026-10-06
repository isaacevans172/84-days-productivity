//
//  ContentView.swift
//  84Days
//
//  Created by Isaac Evans on 1/10/2026.
//


import SwiftUI

struct ContentView: View {

    var body: some View {

        TabView {

            // MARK: - Home

            NavigationStack {
                Text("Home")
                    .navigationTitle("84Days")
            }
            .tabItem {
                Label(
                    "Home",
                    systemImage: "house.fill"
                )
            }


            // MARK: - Calendar

            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label(
                    "Calendar",
                    systemImage: "calendar"
                )
            }


            // MARK: - Tasks

            NavigationStack {
                Text("Tasks")
                    .navigationTitle("Tasks")
            }
            .tabItem {
                Label(
                    "Tasks",
                    systemImage: "checkmark.circle"
                )
            }


            // MARK: - Goals

            NavigationStack {
                Text("Goals")
                    .navigationTitle("Goals")
            }
            .tabItem {
                Label(
                    "Goals",
                    systemImage: "target"
                )
            }


            // MARK: - Profile

            NavigationStack {
                Text("Profile")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label(
                    "Profile",
                    systemImage: "person.circle"
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
