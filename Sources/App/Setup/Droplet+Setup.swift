@_exported import Vapor

extension Droplet {

    public func setup() throws {
        let routes = Routes(view, droplet: self)
        try collection(routes)

        let crons = CronsController(droplet: self)
        crons.start()

    }
}
