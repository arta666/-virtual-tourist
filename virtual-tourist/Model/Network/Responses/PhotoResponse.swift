//
//  PhotoResponse.swift
//  virtual-tourist
//
//  Created by Arman on 23/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import Foundation

struct Photos : Codable {
    let page : Int
    let pages : String
    let perpage : Int
    let total : String
    let photo : [Photo]
}
