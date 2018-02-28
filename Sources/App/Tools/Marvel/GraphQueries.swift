import Vapor
import Random
import Foundation
import Sessions

final class GraphQueries {

    static let myUser =
    """
        query {
            user {
                pk
                username
                email
            }
        }
    """

    static let companyMembers =
    """
        query {
            user {
                company {
                  members(first: 100) {
                    edges {
                      node {
                        pk
                        username
                        email
                      }
                    }
                  }
                }
            }
        }
    """

    static let projects =
    """
        query {
          user {
            projects(first: 50) {
              edges {
                node {
                  pk
                  name
                  prototypeUrl
                  lastModified
                  collaborators {
                    edges {
                      node {
                        pk
                        username
                        email
                      }
                    }
                  }
                  images {
                    edges {
                      node {
                        displayName
                        fileName
                        url
                        width
                        height
                        uuid
                      }
                    }
                  }
                }
              }
            }
          }
        }
    """

    static func createProject(name: String) -> String{

        return """
            mutation {
                createProject(name: "\(name)") {
                    ok
                    project {
                        name
                        pk
                    }
                }
            }
        """

    }

    static func addCollaboratorToProject(email: String, projectPk: Int) -> String{

        return """
            mutation {
                addCollaboratorsToProject(emails: ["\(email)"], projectPk: \(projectPk)){
                    project{
                        name
                    }
                    succeeded{
                        username
                        addedByPk
                        email
                    }
                    failed{
                        email
                        message
                        code
                    }
                }
            }
        """

    }

}
