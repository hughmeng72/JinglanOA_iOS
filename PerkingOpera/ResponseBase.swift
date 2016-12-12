//
//  ResponseBase.swift
//  PerkingOpera
//
//  Created by admin on 28/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct ResponseBase : Glossy {
    let result: Int
    let errorInfo: String

    // MARK: - Deserialization
    
    init?(json: JSON) {
        guard let result: Int = "result" <~~ json,
            let errorInfo: String = "errorInfo" <~~ json
            else {
                return nil
        }
        
        self.result = result
        self.errorInfo = errorInfo
    }
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify([
            "result" ~~> self.result,
            "errorInfo" ~~> self.errorInfo
            ])
    }
    
    
}


