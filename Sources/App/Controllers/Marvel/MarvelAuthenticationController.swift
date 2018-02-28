//
//  SlackAuthenticationController.swift
//  App
//
//  Created by Maxime De Greve on 16/10/2017.
//

import Vapor
import HTTP

final class MarvelAuthenticationController {
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK - Routes
    
    func redirect(request: Vapor.Request) throws -> ResponseRepresentable  {

        guard let code = request.query?["code"]?.string else{
            throw Abort.badRequest
        }
        
        let response = try Marvel(droplet: drop).requestAccessToken(code: code)
        let marvelAccessToken = MarvelAccessToken(with: response.data)

        // Fetch current user information

        let result = try Marvel(droplet: drop).myUser(accessToken: marvelAccessToken.accessToken)

        guard
            let pk = result.data["data"]?["user"]?["pk"]?.int,
            let name = result.data["data"]?["user"]?["username"]?.string,
            let email = result.data["data"]?["user"]?["email"]?.string else {
            throw Abort.badRequest
        }

        // Create user or use existing
        var user = User(name: name, email: email)
        if let existingUser = try User.with(email: email){
            user = existingUser
        } else {
            try user.save()
        }

        // Remove old Marvel tokens as we got a new one anyway...
        if let token = try MarvelToken.with(userId: pk){
            try token.delete()
        }

        // Create MarvelToken record
        let token = try MarvelToken(token: marvelAccessToken, marvelUserId: pk, user: user)
        try token.save()

        // Save in sessions
        try request.authenticate(user: user)

        return Response(redirect: "/dashboard")
        
    }
    
}

