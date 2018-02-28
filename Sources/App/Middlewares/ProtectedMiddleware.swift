//
//  ProtectedMiddleware.swift
//  App
//
//  Created by Maxime De Greve on 19/02/2018.
//

import Foundation
import HTTP

final class ProtectedMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        do {
            _ = try request.user()
        } catch {
            return Response(redirect: "/")
        }

        return try next.respond(to: request)

    }
}
