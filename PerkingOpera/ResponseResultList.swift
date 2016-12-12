//
//  ResponseResult.swift
//  PerkingOpera
//
//  Created by admin on 02/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct ResponseResultList<T : Decodable> : Glossy {
    
    let list: [T]
    let error: ResponseBase
    
    init?(json: JSON) {
        guard let error: ResponseBase = "error" <~~ json,
            let list: [T] = "list" <~~ json
            else {
                return nil;
        }

        self.list = list
        self.error = error
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
