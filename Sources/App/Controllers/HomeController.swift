//
//  HomeController.swift
//  App
//
//  Created by Maxime De Greve on 16/02/2018.
//

import Vapor
import HTTP

final class HomeController {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }

    // MARK - Routes

    func index(request: Vapor.Request) throws -> ResponseRepresentable  {

        let connectUrl = try Marvel(droplet: self.drop).authorizeURL(scopes: ["user:read", "projects:read", "projects:write", "company:read"], request: request)
        return try drop.view.make("home", [
            "connect-url": connectUrl,
            ])

    }

}

