//
//  Slack.swift
//  MarvelKarting
//
//  Created by Maxime De Greve on 23/08/2017.
//
//

import Vapor

final class Slack {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    let apiUrl = "https://slack.com"
    
    var clientId: String {
        return drop.config["slack", "client_id"]?.string ?? "No client id"
    }
    var clientSecret: String {
        return drop.config["slack", "client_secret"]?.string ?? "No client secret"
    }
    var redirectURI: String {
        return drop.config["slack", "redirect_uri"]?.string ?? "No redirect uri"
    }
    
    var verificationToken: String {
        return drop.config["slack", "verification_token"]?.string ?? "No token"
    }

    func authorizeURL(scopes: [String], request: Request) throws -> String{

        guard let spaceSeperatedScopes = scopes.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw Abort.badRequest
        }

        let url = "\(apiUrl)/oauth/authorize/?scope=\(spaceSeperatedScopes)&client_id=\(clientId)"
        return url

    }
    
    func requestAccessToken(code: String) throws -> Response{
        
        let body: Node = [
            "client_id" : .string(clientId),
            "client_secret": .string(clientSecret),
            "redirect_uri": .string(redirectURI),
            "code": .string(code)
        ]
        
        let request = Request(method: .post, uri: "\(apiUrl)/api/oauth.access")
        request.query = body
        return try drop.client.respond(to: request)
        
    }
    
    func userList(token: String, cursor: String?) throws -> Response{
        
        var body: Node = [
            "token": .string(token),
            "presence": .bool(false),
            "limit": 200
        ]
        
        if let cursor = cursor{
            body["cursor"] = .string(cursor)
        }
        
        let request = Request(method: .post, uri: "\(apiUrl)/api/users.list")
        request.query = body
        return try drop.client.respond(to: request)
        
    }
    
    func authTest(token: String) throws -> Response{
        
        let body: Node = [
            "token": .string(token)
        ]
        
        let request = Request(method: .post, uri: "\(apiUrl)/api/auth.test")
        request.query = body
        return try drop.client.respond(to: request)
        
    }
    
    func postMessage(message: String, channelId: String, token: String) throws -> Response{
        
        let body: Node = [
            "token": .string(token),
            "channel": .string(channelId),
            "text": .string(message)
        ]
        
        let request = Request(method: .post, uri: "\(apiUrl)/api/chat.postMessage")
        request.query = body
        return try drop.client.respond(to: request)
        
    }

    func updateMessage(message: String, channelId: String, token: String, ts: String) throws -> Response{

        let body: Node = [
            "token": .string(token),
            "channel": .string(channelId),
            "ts": .string(ts),
            "text": .string(message)
        ]

        let request = Request(method: .post, uri: "\(apiUrl)/api/chat.update")
        request.query = body
        return try drop.client.respond(to: request)

    }
    
    func channelUsers(channelId: String, token: String, cursor: String?) throws -> Response{
        
        var body: Node = [
            "token": .string(token),
            "channel": .string(channelId),
        ]
        
        if let cursor = cursor{
            body["cursor"] = .string(cursor)
        }
        
        let request = Request(method: .post, uri: "\(apiUrl)/api/conversations.members")
        request.query = body
        return try drop.client.respond(to: request)
        
    }

    func info(userId: String, token: String) throws -> Response{

        let body: Node = [
            "token": .string(token),
            "user": .string(userId),
            ]

        let request = Request(method: .post, uri: "\(apiUrl)/api/users.info")
        request.query = body
        return try drop.client.respond(to: request)

    }

    func dialogOpen(token: String, triggerId: String, dialog: JSON) throws -> Response {
        let dialogBytes = try dialog.serialize()

        let body: Node = [
            "token": .string(token),
            "trigger_id": .string(triggerId),
            "dialog": .bytes(dialogBytes)
        ]

        let request = Request(method: .post, uri: "\(apiUrl)/api/dialog.open")
        request.query = body

        return try drop.client.respond(to: request)

    }
    
}



