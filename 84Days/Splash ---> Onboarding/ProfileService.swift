//
//  ProfileService.swift
//  84Days
//
//  Created by Isaac Evans on 2/10/2026.
//

import Foundation
import Supabase

struct ProfileService {

    static func createProfile(
        userID: UUID,
        firstName: String,
        lastName: String,
        email: String,
        avatar: String
    ) async throws {

        struct NewProfile: Encodable {
            let user_id: UUID
            let first_name: String
            let last_name: String
            let email: String
            let avatar: String
        }

        let profile = NewProfile(
            user_id: userID,
            first_name: firstName,
            last_name: lastName,
            email: email,
            avatar: avatar
        )

        try await supabase
            .from("user_profiles")
            .insert(profile)
            .execute()

        print("✅ Profile successfully saved to Supabase")
    }
}
