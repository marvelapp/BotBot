//
//  DashboardController.swift
//  App
//
//  Created by Maxime De Greve on 19/02/2018.
//

import Foundation

final class DashboardController {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }

    // MARK - Routes

    func index(request: Vapor.Request) throws -> ResponseRepresentable  {

        let user = try request.user()

        let slackToken = try user.slackToken()
        let slackTokenIsValid = try slackToken?.isValid(droplet: drop) ?? false

        if slackTokenIsValid == false {
            try slackToken?.delete()
        }

        let connectUrl = try Slack(droplet: self.drop).authorizeURL(scopes: ["commands"], request: request)
        return try drop.view.make("dashboard", [
            "connect-url": connectUrl,
            "slack-token-valid": slackTokenIsValid
            ])
    }

}
