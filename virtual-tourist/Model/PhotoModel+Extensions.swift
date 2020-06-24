//
//  PhotoModel+Extensions.swift
//  virtual-tourist
//
//  Created by Arman on 24/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import Foundation
import CoreData

extension PhotoModel {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
