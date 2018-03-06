//
//  MarvelImage.swift
//  App
//
//  Created by Maxime De Greve on 20/02/2018.
//

import Vapor

final class MarvelScreen {

    // Non optionals
    var uuid = ""
    var width = 0
    var height = 0
    var name = ""
    var content: MarvelContent?

    init(with node: Node?) {
        uuid = node?["uuid"]?.string ?? ""
        width = node?["width"]?.int ?? 0
        height = node?["height"]?.int ?? 0
        name = node?["name"]?.string ?? ""

        if let contentNode = node?["content"]{
            content = MarvelContent(with: contentNode)
        }

    }

}
