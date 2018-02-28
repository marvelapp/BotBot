//
//  Random.swift
//  App
//
//  Created by Maxime De Greve on 16/02/2018.
//

import Foundation
import Random

extension URandom{

    static func lettersNumbers(length: Int) -> String {
        var result = ""
        let base62chars = [Character]("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        let maxBase : Int = 62
        let minBase : Int = 32

        for _ in 0..<length {
            let random = Int.random(min: minBase, max: maxBase)
            result.append(base62chars[random-1])
        }
        return result
    }

}

