//
//  SlackProjectsController.swift
//  App
//
//  Created by Maxime De Greve on 19/02/2018.
//

import Vapor

final class SlackProjectsController {

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

        if let text = request.data["text"]?.string, text == "help"{
            let slackBotBotController = SlackBotBotController(droplet: drop)
            return try slackBotBotController.index(request:request)
        }

        return try JSON(node: [
            "attachments": [
                [
                    "text": "What project would you like to add to this channel?",
                    "color": "#3AA3E3",
                    "response_type": "ephemeral",
                    "attachment_type": "default",
                    "callback_id": SlackCallbacks.project.rawValue,
                    "actions": [
                        [
                            "name": SlackExternalCallbacks.projects.rawValue,
                            "text": "Pick a project...",
                            "type": "select",
                            "data_source": "external",
                            "min_query_length": 0
                        ]
                    ]
                ]
            ]
        ])

    }

    func project(request: Request) throws -> ResponseRepresentable  {

        let payloadJSON = try request.data.toJSON()

        guard
            let value = payloadJSON["actions"]?.array?.first?["selected_options"]?.array?.first?["value"]?.int,
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


        let projects = try Marvel(droplet: drop).project(pk: value, accessToken: marvelToken)

        guard let projectDic = projects.data["data"]?["project"] else {
            return try Error.with(name: .general)
        }

        let project = MarvelProject(with: projectDic)

        let collaborators = project.collaborators.compactMap { (collab) -> String? in
            return collab.username
        }.joined(separator: ", ")
        let collabWord = project.collaborators.count > 1 ? "👧  \(project.collaborators.count) collaborators" : "👧  1 collaborator"

        return try JSON(node: [
            "response_type": "in_channel",
            "replace_original": false,
            "delete_original": true,
            "attachments": [
                [
                    "title": project.name,
                    "title_link": project.prototypeUrl,
                    "thumb_url": project.screens.first?.content?.url ?? "",
                    "footer": "Marvel Prototyping",
                    "fields": [
                        [
                            "title": "⏱  Last updated",
                            "value": project.lastModified.since().capitalizingFirstLetter(),
                            "short": true
                        ],
                        [
                            "title": collabWord,
                            "value": collaborators,
                            "short": true
                        ],
                    ],
                ]
            ]
        ])

    }

}
