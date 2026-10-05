//
//  OnboardingData.swift
//  84Days
//
//  Created by Isaac Evans on 2/10/2026.
//

import Foundation

struct OnboardingData {
    var firstName = ""
    var lastName = ""
    var email = ""
    var selectedAvatar = "01-deadpan"

    func makeProfile() -> UserProfile {
        UserProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
            avatar: selectedAvatar
        )
    }
}
