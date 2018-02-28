//
//  SlackExternalController.swift
//  App
//
//  Created by Maxime De Greve on 26/02/2018.
//

import Vapor

enum SlackExternalCallbacks: String {
    case projects = "projects"
    case companyMembers = "company-members"
}

final class SlackExternalController {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }

    func index(request: Request) throws -> ResponseRepresentable  {

        let verificationToken = Slack(droplet: drop).verificationToken

        let payloadJSON = try request.data.toJSON()

        guard
            let vertificationTokenRequest = payloadJSON["token"]?.string,
            let name = payloadJSON["name"]?.string else{
                throw Abort.badRequest
        }

        // Compare the verifications token (Security)
        if vertificationTokenRequest != verificationToken{
            throw Abort.badRequest
        }

        // Check if known callback
        guard let slackCallback = SlackExternalCallbacks(rawValue: name) else{
            throw Abort.badRequest
        }

        switch slackCallback {
        case .projects:
            return try projects(request:request)
        case .companyMembers:
            return try companyMembers(request:request)
        }

    }

    func projects(request: Request) throws -> ResponseRepresentable  {

        let payloadJSON = try request.data.toJSON()

        guard
            let teamId = payloadJSON["team"]?["id"]?.string,
            let searchValue = payloadJSON["value"]?.string else{
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

        // Get company members

        let projectsJSON = try projectsInSlackFormat(request: request, marvelAccessToken: marvelToken)

        // Filter on what the user is searching for in the field on Slack

        let filteredProjectJSON = projectsJSON.filter { json in

            if searchValue.isEmpty {
                return true
            }

            guard let projectName = json["text"]?.string else {
                return false
            }

            return projectName.lowercased().contains(searchValue.lowercased())

        }

        return try JSON(node: [
            "options": filteredProjectJSON
            ])

    }

    func companyMembers(request: Request) throws -> ResponseRepresentable  {

        let payloadJSON = try request.data.toJSON()

        guard
            let teamId = payloadJSON["team"]?["id"]?.string,
            let searchValue = payloadJSON["value"]?.string else{
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

        // Get company members

        let membersJSON = try companyMembersInSlackFormat(request: request, marvelAccessToken: marvelToken)

        // Filter on what the user is searching for in the field on Slack

        let filteredMembersJSON = membersJSON.filter { json in

            if searchValue.isEmpty {
                return true
            }

            guard let name = json["text"]?.string else {
                return false
            }

            return name.lowercased().contains(searchValue.lowercased())

        }

        return try JSON(node: [
            "options": filteredMembersJSON
            ])

    }


    // MARK: Helpers

    func projectsInSlackFormat(request: Request, marvelAccessToken: String, displayProperty: String = "text") throws -> [JSON]  {

        let result = try Marvel(droplet: drop).projects(accessToken: marvelAccessToken)

        guard let projectsArray = result.data["data"]?["user"]?["projects"]?["edges"]?.array else {
            throw Abort.badRequest
        }

        var projectsNode = [MarvelProject]()
        for project in projectsArray{
            let project = MarvelProject(with: project["node"])
            projectsNode.append(project)
        }


        // Map to a readable Slack format

        let projectsJSON = try projectsNode.map { (project) -> JSON in

            let json = try JSON(node: [
                displayProperty: project.name,
                "value": project.pk
                ])
            return json

        }

        return projectsJSON

    }

    func companyMembersInSlackFormat(request: Request, marvelAccessToken: String) throws -> [JSON]  {

        let companyResult = try Marvel(droplet: drop).companyMembers(accessToken: marvelAccessToken)

        guard let companyMembers = companyResult.data["data"]?["user"]?["company"]?["members"]?["edges"]?.array else {
            throw Abort.badRequest
        }

        var membersNode = [MarvelMember]()
        for member in companyMembers{
            let member = MarvelMember(with: member["node"])
            membersNode.append(member)
        }

        // Map to a readable Slack format

        let membersJSON = try membersNode.map { (member) -> JSON in

            let json = try JSON(node: [
                "text": member.username,
                "value": member.email
                ])
            return json

        }

        return membersJSON

    }

}

