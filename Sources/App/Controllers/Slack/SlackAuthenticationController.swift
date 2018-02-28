//
//  SlackAuthenticationController.swift
//  App
//
//  Created by Maxime De Greve on 16/10/2017.
//

import Vapor
import HTTP

final class SlackAuthenticationController {
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK - Routes
    
    func redirect(request: Vapor.Request) throws -> ResponseRepresentable  {

        guard let code = request.query?["code"]?.string else{
            throw Abort.badRequest
        }
        
        let response = try Slack(droplet: drop).requestAccessToken(code: code)
        
        guard
            let accessToken = response.data["access_token"]?.string,
            let teamId = response.data["team_id"]?.string else {
                throw Abort.badRequest
        }

        // Session user
        let user = try request.user()
        
        // Create Team or get existing Team
        var team = SlackToken(teamId: teamId, user: user, accessToken: accessToken)
        if let existingTeam = try SlackToken.with(teamId: teamId){
            team = existingTeam
        }

        // Marvel doesn't have the concept of Slack workspaces therefore
        // another Marvel user could have set up this bot in the past for their Slack workspace...
        // to ensure they can always set it up again we change the owner of the last known Slack workspace token.
        team.user = user.id
        team.accessToken = accessToken
        team.teamId = teamId

        try team.save()

        return Response(redirect: "/dashboard")
        
    }
    
}

