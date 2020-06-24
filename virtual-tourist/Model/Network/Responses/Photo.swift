//
//  Photo.swift
//  virtual-tourist
//
//  Created by Arman on 23/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import Foundation

struct Photo : Codable {
    let id : String
    let owner : String
    let secret : String
    let server : String
    let farm : Int
    let title : String
    let isPublic : Int
    let isFriend : Int
    let isFamily : Int
    let photoUrl : String
    let height : Int
    let width : Int
    
    enum CodingKeys : String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend =  "isfriend"
        case isFamily =  "isfamily"
        case photoUrl = "url_m"
        case height = "height_m"
        case width = "width_m"
        
    }
}
