//
//  MarvelProject.swift
//  App
//
//  Created by Maxime De Greve on 20/02/2018.
//

import Vapor
import Foundation

final class MarvelProject {

    // Non optionals
    var pk = 0
    var name = ""
    var prototypeUrl = ""
    var lastModified = Date()
    var screens = [MarvelScreen]()
    var collaborators = [MarvelMember]()

    init(with node: Node?) {

        pk = node?["pk"]?.int ?? 0
        name = node?["name"]?.string ?? ""
        prototypeUrl = node?["prototypeUrl"]?.string ?? ""

        if let date = dateFromString(node?["lastModified"]?.string){
            lastModified = date
        }

        if let screensArray = node?["screens"]?["edges"]?.array {
            for screen in screensArray{
                let screen = MarvelScreen(with: screen["node"])
                screens.append(screen)
            }
        }

        if let collabsArray = node?["collaborators"]?["edges"]?.array {
            for collab in collabsArray{
                let collab = MarvelMember(with: collab["node"])
                collaborators.append(collab)
            }
        }

    }

    func dateFromString(_ dateAsString: String?) -> Date? {
        guard let string = dateAsString else { return nil }

        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let val = dateformatter.date(from: string)
        return val
    }

}
