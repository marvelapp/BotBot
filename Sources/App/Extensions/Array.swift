//
//  Array.swift
//  App
//
//  Created by Maxime De Greve on 16/02/2018.
//

import Foundation

extension Array {

    func filterDuplicates(includeElement: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {

        var results = [Element]()

        forEach { (element) in

            let existingElements = results.filter {
                return includeElement(element, $0)
            }

            if existingElements.count == 0 {
                results.append(element)
            }
        }
        return results
    }
}
