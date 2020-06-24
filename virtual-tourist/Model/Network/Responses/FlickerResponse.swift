//
//  FlickerResponse.swift
//  virtual-tourist
//
//  Created by Arman on 23/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import Foundation

class FlickerResponse : Codable {
    let stat : String
    let code : Int
    let message : String
}


extension FlickerResponse : LocalizedError {
    var errorDescription: String? {
        return message
    }
}
