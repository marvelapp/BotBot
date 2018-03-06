//
//  SlackAuthenticationController.swift
//  Created by Maxime De Greve on 16/10/2017.
//

import Foundation
import Vapor
import HTTP

enum SlackCallbacks: String {
    case project = "project"
    case createProject = "create-project"
    case addPeoplePickedProject = "add-people-picked-project"
    case addPeoplePickedPerson = "add-people-picked-person"
}

final class SlackInteractiveController {

    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    // MARK - Routes

    
    func index(request: Request) throws -> ResponseRepresentable  {
        
        let verificationToken = Slack(droplet: drop).verificationToken
        
        let payloadJSON = try request.data.toJSON()

        guard
            let vertificationTokenRequest = payloadJSON["token"]?.string,
            let callbackId = payloadJSON["callback_id"]?.string else{
            Swift.print(payloadJSON)
            throw Abort.badRequest
        }

        // Compare the verifications token (Security)
        if vertificationTokenRequest != verificationToken{
            throw Abort.badRequest
        }
        
        // Check if known callback
        guard let slackCallback = SlackCallbacks(rawValue: callbackId) else{
            throw Abort.badRequest
        }
        
        switch slackCallback {
        case .project:
            let slackProjectsController = SlackProjectsController(droplet: drop)
            return try slackProjectsController.project(request: request)
        case .createProject:
            let slackCreateProjectController = SlackCreateProjectController(droplet: drop)
            return try slackCreateProjectController.create(request: request)
        case .addPeoplePickedProject:
            let slackAddPeopleController = SlackAddPeopleController(droplet: drop)
            return try slackAddPeopleController.pickedProject(request:request)
        case .addPeoplePickedPerson:
            let slackAddPeopleController = SlackAddPeopleController(droplet: drop)
            return try slackAddPeopleController.pickedPerson(request:request)
        }
        
    }

    
}
