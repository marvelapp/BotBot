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
        fragment image on ImageScreen {
          filename
          url
        }

        {
          user {
            company {
              projects(first: 40) {
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
                    screens(first: 2) {
                      edges {
                        node {
                          name
                          uuid
                          modifiedAt
                          content {
                            __typename
                            ...image
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            projects(first: 40) {
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
                  screens(first: 2) {
                    edges {
                      node {
                        name
                        uuid
                        modifiedAt
                        content {
                          __typename
                          ...image
                        }
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

    static func project(pk: Int) -> String{

        return """

            fragment image on ImageScreen {
              filename
              url
            }

            query {
              project(pk: \(pk)) {
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
                screens(first: 2) {
                  edges {
                    node {
                      name
                      uuid
                      modifiedAt
                      content {
                        __typename
                        ...image
                      }
                    }
                  }
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
