//
//  User.swift
//  PerkingOpera
//
//  Created by admin on 28/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct User: Glossy {
    
    let userId: Int
    let token: String
    let userName: String
    let depId: Int
    let realName: String?
    let depName: String?
    let error: ResponseBase
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        guard let userId: Int = "userId" <~~ json,
            let token: String = "token" <~~ json,
            let userName: String = "userName" <~~ json,
            let depId: Int = "depId" <~~ json,
            let error: ResponseBase = "error" <~~ json
            else {
                return nil
            }
        
        self.userId = userId
        self.token = token
        self.userName = userName
        self.depId = depId
        self.realName = "RealName" <~~ json
        self.depName = "DepName" <~~ json
        self.error = error
    }
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify([
            "userId" ~~> self.userId,
            "token" ~~> self.token,
            "userName" ~~> self.userName,
            "depId" ~~> self.depId,
            "RealName" ~~> self.realName,
            "DepName" ~~> self.depName
            ])
    }
}

// MARK: - Custom transformers

extension Decoder {
    
    static func decodeStringUppercase(key: String, json: JSON) -> String? {
        if let string = json[key] as? String {
            return string.uppercased()
        }
        
        return nil
    }
    
}

extension Encoder {
    
    static func encodeStringCapitalized(key: String, value: String?) -> JSON? {
        if let value = value {
            return [key : value.capitalized]
        }
        
        return nil
    }
    
}
