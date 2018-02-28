//
//  MarvelToken.swift
//  App
//
//  Created by Maxime De Greve on 16/02/2018.
//

import Vapor
import FluentProvider
import HTTP
import Foundation

final class MarvelToken: Model, Timestampable, SoftDeletable {

    public struct Properties {
        public static let id = "id"
        public static let marvelUserId = "marvel_user_id"
        public static let accessToken = "access_token"
        public static let refreshToken = "refresh_token"
        public static let expiresIn = "expires_in"
        public static let scopes = "scopes"
    }

    public var marvelUserId: Int
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Int
    public var user: Identifier
    public var scopes: String

    public let storage = Storage()

    init(token: MarvelAccessToken, marvelUserId: Int, user: User) throws {
        self.marvelUserId = marvelUserId
        self.accessToken = token.accessToken
        self.refreshToken = token.refreshToken
        self.expiresIn = token.expiresIn
        self.user = user.id!
        self.scopes = token.scopes
    }

    // Initializes the Post from the database row

    init(row: Row) throws {
        marvelUserId = try row.get(Properties.marvelUserId)
        accessToken = try row.get(Properties.accessToken)
        refreshToken = try row.get(Properties.refreshToken)
        expiresIn = try row.get(Properties.expiresIn)
        scopes = try row.get(Properties.scopes)
        user = try row.get(User.foreignIdKey)
    }

    // Serializes the Post to the database

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.marvelUserId, marvelUserId)
        try row.set(Properties.accessToken, accessToken)
        try row.set(Properties.refreshToken, refreshToken)
        try row.set(Properties.expiresIn, expiresIn)
        try row.set(Properties.scopes, scopes)
        try row.set(User.foreignIdKey, user)
        return row
    }

}

// MARK: Fluent Preparation

extension MarvelToken: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.int(Properties.marvelUserId, optional: false, unique: false, default: nil)
            user.string(Properties.accessToken)
            user.string(Properties.refreshToken)
            user.string(Properties.scopes)
            user.int(Properties.expiresIn)
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
extension MarvelToken: JSONConvertible {
    convenience init(json: JSON) throws {
        throw Abort.badRequest
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.marvelUserId, marvelUserId)
        try json.set(Properties.accessToken, accessToken)
        try json.set(Properties.refreshToken, refreshToken)
        try json.set(Properties.scopes, scopes)
        try json.set(Properties.expiresIn, expiresIn)
        try json.set(Properties.id, id)
        return json
    }
}

extension MarvelToken {

    static func with(userId: Int) throws -> MarvelToken?{
        return try MarvelToken.makeQuery().filter(Properties.marvelUserId, .equals, userId).first()
    }

}

extension MarvelToken {

    func refreshIfNeeded(droplet: Droplet) throws -> MarvelToken? {

        let marvel = Marvel(droplet: droplet)

        guard let expireDate = Calendar.current.date(byAdding: .second, value: expiresIn, to: updatedAt ?? Date()) else {
            return nil
        }

        // Check if a refresh is needed

        if expireDate < Date(){

            let refreshResponse = try marvel.refreshAccessToken(self)

            if refreshResponse.status == .unauthorized{
                try delete()
                return nil
            }

            let marvelAccessToken = MarvelAccessToken(with: refreshResponse.data)

            accessToken = marvelAccessToken.accessToken
            expiresIn = marvelAccessToken.expiresIn
            refreshToken = marvelAccessToken.refreshToken
            try save()

        }

        return self

    }


}
