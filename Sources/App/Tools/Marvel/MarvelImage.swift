//
//  MarvelImage.swift
//  App
//
//  Created by Maxime De Greve on 20/02/2018.
//

import Vapor

final class MarvelImage {

    // Non optionals
    var uuid = ""
    var width = 0
    var height = 0
    var displayName = ""
    var fileName = ""
    var url = ""

    init(with node: Node?) {
        uuid = node?["uuid"]?.string ?? ""
        width = node?["width"]?.int ?? 0
        height = node?["height"]?.int ?? 0
        url = node?["url"]?.string ?? ""
        fileName = node?["fileName"]?.string ?? ""
        displayName = node?["displayName"]?.string ?? ""
    }

}
