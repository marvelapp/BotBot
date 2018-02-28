//
//  ProtectedMiddleware.swift
//  App
//
//  Created by Maxime De Greve on 19/02/2018.
//

import Foundation
import HTTP

final class HerokuHttpsMiddleware: Middleware {

    let enabled: Bool
    public init(enabled: Bool = true) {
        self.enabled = enabled
    }
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard enabled, request.headers["X-Forwarded-Proto"] == "http" else {
            return try next.respond(to: request)
        }
        request.uri.scheme = "https"
        return Response(redirect: request.uri.description)
    }
    
}
