//
//  Team.swift
//  App
//
//  Created by Maxime De Greve on 15/10/2017.
//

import Vapor
import FluentProvider
import HTTP

final class SlackToken: Model, Timestampable, SoftDeletable {
    
    public struct Properties {
        public static let id = "id"
        public static let teamId = "team_id"
        public static let accessToken = "access_token"
    }
    
    public var teamId: String
    public var accessToken: String
    public var user: Identifier?

    public let storage = Storage()
    
    init(teamId: String, user: User, accessToken: String) {
        self.teamId = teamId
        self.user = user.id!
        self.accessToken = accessToken
    }
    
    // Initializes the Post from the database row
    
    init(row: Row) throws {
        teamId = try row.get(Properties.teamId)
        accessToken = try row.get(Properties.accessToken)
        user = try row.get(User.foreignIdKey)
    }
    
    // Serializes the Post to the database
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.teamId, teamId)
        try row.set(Properties.accessToken, accessToken)
        try row.set(User.foreignIdKey, user)
        return row
    }
    
}

// MARK: Fluent Preparation

extension SlackToken: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string(Properties.teamId, length: nil, optional: false, unique: true, default: nil)
            user.string(Properties.accessToken)
            user.parent(User.self)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension SlackToken: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            teamId: json.get(Properties.teamId),
            user: json.get(User.foreignIdKey),
            accessToken: json.get(Properties.accessToken)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.teamId, teamId)
        try json.set(Properties.accessToken, accessToken)
        try json.set(Properties.id, id)
        return json
    }
}

extension SlackToken {

    var owner: Parent<SlackToken, User> {
        return parent(id: user)
    }

}

extension SlackToken {

    static func with(teamId: String) throws -> SlackToken?{
        return try SlackToken.makeQuery().filter(Properties.teamId, .equals, teamId).first()
    }

}

extension SlackToken {

    func isValid(droplet: Droplet) throws -> Bool {

        let result = try Slack(droplet: droplet).authTest(token:accessToken)

        if let error = result.data["error"]?.string{

            switch error {
            case "invalid_auth":
                return false
            case "account_inactive":
                return false
            case "token_revoked":
                return false
            default:
                Swift.print(error)
                return false
            }

        }

        return true

    }

}
