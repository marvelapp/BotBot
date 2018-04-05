//
//  Slack.swift
//  MarvelKarting
//
//  Created by Maxime De Greve on 23/08/2017.
//
//

import Vapor
import Random
import Foundation
import Sessions

final class Marvel {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }

    let apiUrl = "https://marvelapp.com"

    var clientId: String {
        return drop.config["marvel", "client_id"]?.string ?? "No client id"
    }
    var clientSecret: String {
        return drop.config["marvel", "client_secret"]?.string ?? "No client secret"
    }

    var redirectURI: String {
        return drop.config["marvel", "redirect_uri"]?.string ?? "No redirect uri"
    }

    func authorizeURL(scopes: [String], request: Request) throws -> String{

        guard let spaceSeperatedScopes = scopes.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw Abort.badRequest
        }

        let currentState = try state(request: request)
        let url = "\(apiUrl)/oauth/authorize/?state=\(currentState)&client_id=\(clientId)&response_type=code&scope=\(spaceSeperatedScopes)"
        return url

    }

    func state(request: Request) throws -> String{

        let stateKey = "marvel-state"
        let session = try request.assertSession()

        if let currentState = session.data[stateKey]?.string {
            return currentState
        } else {
            let random = URandom.lettersNumbers(length: 15)
            try session.data.set(stateKey, random)
            return random
        }

    }

    func requestAccessToken(code: String) throws -> Response{

        let body: Node = [
            "grant_type": "authorization_code",
            "client_id": .string(clientId),
            "client_secret": .string(clientSecret),
            "redirect_uri": .string(redirectURI),
            "code": .string(code),
            ]

        let request = Request(method: .post, uri: "\(apiUrl)/oauth/token/")
        request.query = body
        return try drop.client.respond(to: request)

    }

    func refreshAccessToken(_ marvelToken: MarvelToken) throws -> Response{

        let body: Node = [
            "grant_type": "refresh_token",
            "client_id": .string(clientId),
            "client_secret": .string(clientSecret),
            "refresh_token": .string(marvelToken.refreshToken),
            "scope": .string(marvelToken.scopes),
            ]

        let request = Request(method: .post, uri: "\(apiUrl)/oauth/token/")
        request.query = body
        return try drop.client.respond(to: request)

    }

    // MARK: Calls

    func myUser(accessToken: String) throws -> Response{
        return try graphQL(query: GraphQueries.myUser, accessToken: accessToken)
    }

    func projectsIncludingCompany(accessToken: String) throws -> Response{
        return try graphQL(query: GraphQueries.projects, accessToken: accessToken)
    }

    func project(pk: Int, accessToken: String) throws -> Response{
        return try graphQL(query: GraphQueries.project(pk: pk), accessToken: accessToken)
    }

    func createProject(name: String, accessToken: String) throws -> Response{
        return try graphQL(query: GraphQueries.createProject(name: name), accessToken: accessToken)
    }

    func companyMembers(accessToken: String) throws -> Response{
        return try graphQL(query: GraphQueries.companyMembers, accessToken: accessToken)
    }

    func addCollaboratorToProject(_ projectPK: Int, email: String, accessToken: String) throws -> Response{
        return try graphQL(query: GraphQueries.addCollaboratorToProject(email: email, projectPk: projectPK), accessToken: accessToken)
    }

    // MARK: GraphQL Helpers

    func graphQL(query: String, accessToken: String) throws -> Response{

        let body: Node = [
            "query": .string(query)
            ]


        let request = Request(method: .post, uri: "\(apiUrl)/graphql/")
        request.query = body
        request.headers = [
            "Authorization" : "Bearer \(accessToken)"
        ]
        return try drop.client.respond(to: request)


    }

}
