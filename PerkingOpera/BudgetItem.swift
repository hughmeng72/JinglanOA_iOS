//
//  BudgetItem.swift
//  PerkingOpera
//
//  Created by admin on 12/18/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct BudgetItem: Glossy {
    let itemName: String
    
    init?(json: JSON) {
        guard let itemName: String = "ItemName" <~~ json
            else {
                return nil;
        }
        
        self.itemName = itemName
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
