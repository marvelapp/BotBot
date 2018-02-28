//
//  MarvelCollaborators.swift
//  App
//
//  Created by Maxime De Greve on 20/02/2018.
//

import Foundation

final class MarvelMember {

    // Non optionals
    var username = ""
    var email = ""
    var pk = 0

    init(with node: Node?) {
        username = node?["username"]?.string ?? ""
        email = node?["email"]?.string ?? ""
        pk = node?["pk"]?.int ?? 0
    }

}
