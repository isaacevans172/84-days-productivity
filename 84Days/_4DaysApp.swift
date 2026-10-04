//
//  _4DaysApp.swift
//  84Days
//
//  Created by Isaac Evans on 1/10/2026.
//

import SwiftUI
import Supabase
import Auth

@main
struct _4DaysApp: App {

    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    var body: some Scene {

        WindowGroup {

            Group {

                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    SplashView()
                }
            }
            .onOpenURL { url in

                supabase.auth.handle(url)

                print("✅ Authentication callback handled")
            }
        }
    }
}
