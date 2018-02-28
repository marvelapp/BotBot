//
//  SlackBotBotController.swift
//  App
//
//  Created by Maxime De Greve on 28/02/2018.
//

import Foundation

final class SlackBotBotController {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }

    // MARK - Routes

    func index(request: Request) throws -> ResponseRepresentable  {

        let verificationToken = Slack(droplet: drop).verificationToken

        if verificationToken != request.data["token"]?.string{
            throw Abort.badRequest
        }

        return try JSON(node: [
                "mrkdwn": true,
                "text": " Here is a list of available commands\n`/add-people`              Add people to a project\n`/create-project`      Create a project\n`/projects`                 Find a project & post it in your channel"
            ])

    }

}
