//
//  ProtectedMiddleware.swift
//  App
//
//  Created by Maxime De Greve on 19/02/2018.
//

import Foundation
import HTTP

final class HerokuHttpsMiddleware: Middleware {

    let config: Config
    init(config: Config) throws {
        self.config = config
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if config.environment == .production,
            let originalProtocol = request.headers["X-Forwarded-Proto"],
            originalProtocol != "https" {
            return Response(status: .forbidden, body: "HTTPS Required")
        }

        return try next.respond(to: request)
    }
}
