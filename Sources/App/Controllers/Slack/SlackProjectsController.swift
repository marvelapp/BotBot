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

        let projects = try Marvel(droplet: drop).projects(accessToken: marvelToken)

        guard let projectsArray = projects.data["data"]?["user"]?["projects"]?["edges"]?.array else {
            return try Error.with(name: .general)
        }

        var projectsNode = [MarvelProject]()
        for project in projectsArray{
            let project = MarvelProject(with: project["node"])
            projectsNode.append(project)
        }

        let project = projectsNode.filter { (project) -> Bool in
            return project.pk == value
        }.first

        guard let projectFound = project else {
            return try Error.with(name: .general)
        }

        let collaborators = projectFound.collaborators.flatMap { (collab) -> String? in
            return collab.username
        }.joined(separator: ", ")
        let collabWord = projectFound.collaborators.count > 1 ? "👧  \(projectFound.collaborators.count) collaborators" : "👧  1 collaborator"

        return try JSON(node: [
            "response_type": "in_channel",
            "replace_original": false,
            "delete_original": true,
            "attachments": [
                [
                    "title": projectFound.name,
                    "title_link": projectFound.prototypeUrl,
                    "thumb_url": projectFound.images.first?.url ?? "",
                    "footer": "Marvel Prototyping",
                    "fields": [
                        [
                            "title": "⏱  Last updated",
                            "value": projectFound.lastModified.since().capitalizingFirstLetter(),
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
