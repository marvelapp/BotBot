//
//  SlackAddCollaborators.swift
//  App
//
//  Created by Maxime De Greve on 26/02/2018.
//

import Vapor
import Cache

fileprivate class SlackAddPeopleStorage: NodeInitializable, NodeRepresentable {

    var projectPk: Int

    init(projectPk: Int) {
        self.projectPk = projectPk
    }

    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("project_pk", projectPk)
        return node
    }

    required init(node: Node) throws {
        projectPk = try node.get("project_pk")
    }

    static func get(messageTs: String, drop: Droplet) throws -> SlackAddPeopleStorage? {

        guard let storageRaw = try drop.cache.get(messageTs) else {
            return nil
        }

        return try SlackAddPeopleStorage(node: storageRaw)

    }

    func store(messageTs: String, drop: Droplet) throws{
        // We store this for 30 mins
        try drop.cache.set(messageTs, self, expiration: Date(timeIntervalSinceNow: 1800))
    }

    static func delete(messageTs: String, drop: Droplet) throws{
        try drop.cache.delete(messageTs)
    }


}

final class SlackAddPeopleController {

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
                    "text": "*Step 1:* What project would you like to add someone to?",
                    "color": "#3AA3E3",
                    "response_type": "ephemeral",
                    "attachment_type": "default",
                    "callback_id": SlackCallbacks.addPeoplePickedProject.rawValue,
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

    func pickedProject(request: Request) throws -> ResponseRepresentable {

        let payloadJSON = try request.data.toJSON()

        guard
            let value = payloadJSON["actions"]?.array?.first?["selected_options"]?.array?.first?["value"]?.int,
            let messageTs = payloadJSON["message_ts"]?.string else {
                throw Abort.badRequest
        }

        // Store for later use
        let storage = SlackAddPeopleStorage(projectPk: value)
        try storage.store(messageTs: messageTs, drop: drop)

        return try JSON(node: [
            "attachments": [
                [
                    "text": "*Step 2:* Who would you like to add to a project?",
                    "color": "#3AA3E3",
                    "response_type": "ephemeral",
                    "attachment_type": "default",
                    "callback_id": SlackCallbacks.addPeoplePickedPerson.rawValue,
                    "actions": [
                        [
                            "name": SlackExternalCallbacks.companyMembers.rawValue,
                            "text": "Pick someone...",
                            "type": "select",
                            "data_source": "external",
                            "min_query_length": 0
                        ]
                    ]
                ]
            ]
        ])
    }

    func pickedPerson(request: Request) throws -> ResponseRepresentable {

        let payloadJSON = try request.data.toJSON()

        guard
            let email = payloadJSON["actions"]?.array?.first?["selected_options"]?.array?.first?["value"]?.string,
            let messageTs = payloadJSON["message_ts"]?.string,
            let teamId = payloadJSON["team"]?["id"]?.string else {
                throw Abort.badRequest
        }

        guard let team = try SlackToken.with(teamId: teamId) else {
            return try Error.with(name: .teamNotFound)
        }

        guard let user = try team.owner.get() else {
            return try Error.with(name: .userNotFound)
        }

        guard let userMarvelToken = try user.marvelToken()?.accessToken else {
            return try Error.with(name: .invalidAccessToken)
        }

        // Get the storage
        guard let storage = try SlackAddPeopleStorage.get(messageTs: messageTs, drop: drop) else {
            return try Error.with(name: .messageExpired)
        }

        // Add the collborator
        let result = try Marvel(droplet: drop).addCollaboratorToProject(storage.projectPk, email: email, accessToken: userMarvelToken)


        // Check if error
        if let errorMessage = result.data["errors"]?["message"]?.string{
            return try Error.custom(text: errorMessage)
        }

        if let failedMessage = result.data["data"]?["addCollaboratorsToProject"]?["failed"]?.array?.first?["message"]?.string{
            return try Error.custom(text: failedMessage)
        }

        // Get success added username
        guard
            let username = result.data["data"]?["addCollaboratorsToProject"]?["succeeded"]?.array?.first?["username"]?.string,
            let projectName = result.data["data"]?["addCollaboratorsToProject"]?["project"]?["name"]?.string else {
                return try Error.with(name: .general)
        }

        return try JSON(node: [
            "text": "*\(username)* was added to the *\"\(projectName)\"* project. 😎",
            "response_type": "in_channel",
            "replace_original": false,
            "delete_original": true,
        ])

    }

}
