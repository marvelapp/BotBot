//
//  User.swift
//  App
//
//  Created by Maxime De Greve on 19/02/2018.
//

import Vapor
import FluentProvider
import HTTP
import Foundation

final class User: Model, Timestampable, SoftDeletable {

    public struct Properties {
        public static let id = "id"
        public static let name = "name"
        public static let email = "email"
    }

    public var name: String?
    public var email: String?

    public let storage = Storage()

    init(name: String, email: String) {
        self.name = name
        self.email = email
    }

    // Initializes the Post from the database row

    init(row: Row) throws {
        name = try row.get(Properties.name)
        email = try row.get(Properties.email)
    }

    // Serializes the Post to the database

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name, name)
        try row.set(Properties.email, email)
        return row
    }

}

// MARK: Fluent Preparation

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string(Properties.name)
            user.string(Properties.email, length: nil, optional: false, unique: true, default: nil)
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
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Properties.name),
            email: json.get(Properties.email)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.name, name)
        try json.set(Properties.email, email)
        try json.set(Properties.id, id)
        return json
    }
}

// MARK: Helpers

extension User {

    static func with(email: String) throws -> User?{
        return try User.makeQuery().filter(Properties.email, .equals, email).first()
    }

}

// MARK: Tokens

extension User {

    func marvelToken() throws -> MarvelToken? {
        return try children().first()
    }

    func marvelTokenWithRefresh(drop: Droplet) throws -> MarvelToken? {
        return try marvelToken()?.refreshIfNeeded(droplet: drop)
    }

    func slackToken() throws -> SlackToken? {
        return try children().first()
    }

}


// MARK: Auth

extension Request {

    func authenticate(user: User) throws {
        let session = try assertSession()
        try session.data.set("user", user.id)
    }

    func user() throws -> User {
        let session = try assertSession()
        guard let userId = session.data["user"]?.int else {
            throw Abort.unauthorized
        }

        guard let user = try User.find(userId) else {
            throw Abort.unauthorized
        }

        return user
    }

}


