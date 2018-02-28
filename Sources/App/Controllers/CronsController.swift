//
//  CronsController.swift
//  App
//
//  Created by Maxime De Greve on 29/10/2017.
//

import Vapor
import Jobs

final class CronsController {
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func start(){

        // Interval
        Jobs.add(interval: .hours(1)) {

        }
        
    }


}
