//
//  MascotAIService.swift
//  84Days
//
//  Created by Isaac Evans on 4/10/2026.
//

import Foundation
import Supabase

struct MascotAIService {

    struct MascotRequest: Encodable {
        let message: String
        let mascotName: String
        let expression: String
        let context: String
    }

    struct MascotResponse: Decodable {
        let reply: String
    }

    static func sendMessage(
        message: String,
        mascotName: String,
        expression: String,
        context: String = ""
    ) async throws -> String {

        let request = MascotRequest(
            message: message,
            mascotName: mascotName,
            expression: expression,
            context: context
        )

        let response: MascotResponse = try await supabase.functions.invoke(
            "mascot-chat",
            options: FunctionInvokeOptions(
                body: request
            )
        )

        return response.reply
    }
}
