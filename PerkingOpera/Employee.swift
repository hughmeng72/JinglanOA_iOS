//
//  Employee.swift
//  PerkingOpera
//
//  Created by admin on 12/15/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct Employee: Glossy {
    let id: Int
    let realName: String
    let depName: String
    
    var selected: Bool = false
    
    init?(json: JSON) {
        guard let id: Int = "Id" <~~ json,
            let realName: String = "RealName" <~~ json,
            let depName: String = "DepName" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.realName = realName
        self.depName = depName
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
