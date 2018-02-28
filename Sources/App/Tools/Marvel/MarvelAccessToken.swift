//
//  MarvelAccessToken.swift
//  App
//
//  Created by Maxime De Greve on 22/02/2018.
//

import Vapor
import Foundation

final class MarvelAccessToken {

    // Non optionals
    var accessToken = ""
    var expiresIn = 0
    var refreshToken = ""
    var scopes = ""

    init(with content: Content?) {

        accessToken = content?["access_token"]?.string ?? ""
        expiresIn = content?["expires_in"]?.int ?? 0
        refreshToken = content?["refresh_token"]?.string ?? ""
        scopes = content?["scope"]?.string ?? ""

    }


}
