//
//  Mail.swift
//  PerkingOpera
//
//  Created by admin on 02/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct Mail: Glossy {
    
    let id: Int
    let subject: String
    let creator: String
    let sendTime: String
    let url: String

    init?(json: JSON) {
        guard let id: Int = "Id" <~~ json,
            let subject: String = "Subject" <~~ json,
            let creator: String = "Creator" <~~ json,
            let sendTime: String = "SendTime" <~~ json,
            let url: String = "Url" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.subject = subject
        self.creator = creator
        self.sendTime = sendTime
        self.url = url
    }
    
    func toJSON() -> JSON? {
        return nil
    }

}

