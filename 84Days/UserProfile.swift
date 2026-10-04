//
//  UserProfile.swift
//  84Days
//
//  Created by Isaac Evans on 2/10/2026.
//

import Foundation

struct UserProfile: Codable {

    let firstName: String
    let lastName: String
    let email: String
    let avatar: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case avatar
    }
}
