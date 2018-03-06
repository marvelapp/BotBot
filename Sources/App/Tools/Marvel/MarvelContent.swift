//
//  MarvelContent.swift
//  App
//
//  Created by Maxime De Greve on 06/03/2018.
//

import Vapor

final class MarvelContent {

    // Non optionals
    var fileName = ""
    var url = ""

    init(with node: Node?) {
        fileName = node?["filename"]?.string ?? ""
        url = node?["url"]?.string ?? ""
    }

}
