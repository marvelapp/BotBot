//
//  Slack.swift
//  MarvelKarting
//
//  Created by Maxime De Greve on 23/08/2017.
//
//

import Vapor

final class Error {

    enum Name: Int {
        case teamNotFound
        case general
        case userNotFound
        case noMarvelToken
        case invalidAccessToken
        case invalidPermissions
        case noCompanyPlan
        case noCompanyUsers
        case messageExpired
    }
    
    static let supportEmail = "max@marvelapp.com"
    
    static func with(name: Name) throws -> JSON{
        
        var text = "Something went wrong, contact \(supportEmail)."
        
        switch name {
        case .teamNotFound:
            text = "Team not found, contact \(supportEmail)."
        case .userNotFound:
            text = "User(s) not found. Users are refreshed every hour. If you just added a user to your Slack account please try again later. If the problem keeps happening contact \(supportEmail)."
        case .general:
            text = "Something went wrong, contact \(supportEmail)."
        case .invalidAccessToken:
            text = "No or an invalid access token."
        case .invalidPermissions:
            text = "You don't have enough Slack api permissions to run this command. This could be because we've made an update and therefore you have to reconnect to resolve this."
        case .noMarvelToken:
            text = "Please setup your bot again."
        case .noCompanyPlan:
            text = "You need to be on a company plan for this."
        case .noCompanyUsers:
            text = "There are no people added to your company plan"
        case .messageExpired:
            text = "This message is older then 30 minutes. Use your command again."
        }
        
        return try JSON(node: [
            "response_type": "ephemeral",
            "replace_original": true,
            "text": text
            ])
        
    }

    static func custom(text: String) throws -> JSON{
        return try JSON(node: [
            "response_type": "ephemeral",
            "replace_original": true,
            "text": text
            ])
    }

}
