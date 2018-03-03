//
//  SlackCreateProjectController.swift
//  App
//
//  Created by Maxime De Greve on 20/02/2018.
//

import Foundation

enum SlackCreateNameIdentifiers: String {
    case projectName = "project-name"
}

final class SlackCreateProjectController {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }

    // MARK - Routes

    func index(request: Request) throws -> ResponseRepresentable {

        let verificationToken = Slack(droplet: drop).verificationToken

        if verificationToken != request.data["token"]?.string{
            throw Abort.badRequest
        }

        if let text = request.data["text"]?.string, text == "help"{
            let slackBotBotController = SlackBotBotController(droplet: drop)
            return try slackBotBotController.index(request:request)
        }

        guard
            let teamId = request.data["team_id"]?.string,
            let triggerId = request.data["trigger_id"]?.string else{
                throw Abort.badRequest
        }

        guard let team = try SlackToken.with(teamId: teamId) else {
            return try Error.with(name: .teamNotFound)
        }

        guard let user = try team.owner.get() else {
            return try Error.with(name: .userNotFound)
        }

        guard let userSlackToken = try user.slackToken()?.accessToken else {
             return try Error.with(name: .invalidAccessToken)
        }

        let json = try JSON(node: [
            "callback_id": SlackCallbacks.createProject.rawValue,
            "title": "Create a Marvel project",
            "submit_label": "Create",
            "elements": [
                [
                    "type": "text",
                    "label": "Project Name",
                    "name": SlackCreateNameIdentifiers.projectName.rawValue
                ],
            ]
        ])

        _ = try Slack(droplet: drop).dialogOpen(token: userSlackToken, triggerId: triggerId, dialog: json)

        return ""

    }

    func create(request: Request) throws -> ResponseRepresentable {

        let payloadJSON = try request.data.toJSON()

        let verificationToken = Slack(droplet: drop).verificationToken

        if verificationToken != payloadJSON["token"]?.string{
            throw Abort.badRequest
        }

        guard
            let projectName = payloadJSON["submission"]?[SlackCreateNameIdentifiers.projectName.rawValue]?.string,
            let teamId = payloadJSON["team"]?["id"]?.string else {
                throw Abort.badRequest
        }

        guard let team = try SlackToken.with(teamId: teamId) else {
            return try Error.with(name: .teamNotFound)
        }

        guard let user = try team.owner.get() else {
            return try Error.with(name: .userNotFound)
        }

        guard let marvelToken = try user.marvelTokenWithRefresh(drop: drop)?.accessToken else {
            return try Error.with(name: .noMarvelToken)
        }

        let result = try Marvel(droplet: drop).createProject(name: projectName, accessToken: marvelToken)

        guard
            let ok = result.data["data"]?["createProject"]?["ok"]?.bool else {
            return try Error.with(name: .general)
        }

        if ok == false{
            return try Error.with(name: .general)
        }

        return ""
    }

}
