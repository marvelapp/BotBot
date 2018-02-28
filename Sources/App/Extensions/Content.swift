//
//  Content.swift
//  App
//
//  Created by Maxime De Greve on 30/11/2017.
//

import Vapor

extension Content{

    func toJSON() throws -> JSON{

        // Slack returns a JSON string object 👀

        guard let payload = self["payload"]?.string else{
            throw Abort.badRequest
        }

        let bytes = payload.makeBytes()
        return try JSON(bytes: bytes)

    }

}
