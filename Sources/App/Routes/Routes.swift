import Vapor
import AuthProvider

final class Routes: RouteCollection {

    let view: ViewRenderer
    let drop: Droplet

    init(_ view: ViewRenderer, droplet: Droplet) {
        self.view = view
        self.drop = droplet
    }

    func build(_ builder: RouteBuilder) throws {

        // Controllers
        let slackAuthController = SlackAuthenticationController(droplet: self.drop)
        let slackInteractiveController = SlackInteractiveController(droplet: self.drop)
        let slackExternalController = SlackExternalController(droplet: self.drop)
        let slackProjectsController = SlackProjectsController(droplet: self.drop)
        let slackAddPeopleController = SlackAddPeopleController(droplet: self.drop)
        let slackCreateProjectController = SlackCreateProjectController(droplet: self.drop)
        let marvelAuthController = MarvelAuthenticationController(droplet: self.drop)
        let homeController = HomeController(droplet: self.drop)
        let dashboardController = DashboardController(droplet: self.drop)

        // Middlewares
        let redirect = RedirectMiddleware(path: "/")
        let authed = ProtectedMiddleware()
        let protected = drop.grouped([redirect, authed])

        // Routes
        drop.get(handler: homeController.index)

        drop.get("privacy"){ request in
            return try self.view.make("privacy")
        }

        drop.get("support"){ request in
            return try self.view.make("support")
        }

        // Marvel oAuth Redirection
        drop.group("marvel"){ slack in
            slack.get("redirect", handler: marvelAuthController.redirect)
        }

        // Slack
        drop.group("slack"){ slack in
            slack.get("redirect", handler: slackAuthController.redirect)
            slack.post("projects", handler: slackProjectsController.index)
            slack.post("create-project", handler: slackCreateProjectController.index)
            slack.post("add-people", handler: slackAddPeopleController.index)
            slack.post("interactive", handler: slackInteractiveController.index)
            slack.post("interactive-external", handler: slackExternalController.index)
        }

        // Protected Areas
        protected.group("dashboard"){ dashboard in
            dashboard.get(handler: dashboardController.index)
        }

    }

}

