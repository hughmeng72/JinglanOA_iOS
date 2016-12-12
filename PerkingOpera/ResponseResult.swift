//
//  ResponseResult.swift
//  PerkingOpera
//
//  Created by admin on 12/4/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct ResponseResult<T : Decodable> : Glossy {
    
    let entity: T
    let error: ResponseBase
    
    init?(json: JSON) {
        guard let error: ResponseBase = "error" <~~ json,
            let entity: T = "Entity" <~~ json
            else {
                return nil;
        }
        
        self.entity = entity
        self.error = error
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
