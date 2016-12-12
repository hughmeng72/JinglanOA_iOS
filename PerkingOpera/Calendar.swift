//
//  Calendar.swift
//  PerkingOpera
//
//  Created by admin on 03/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct Calendar: Glossy {
    let id: Int
    let title: String
    let depName: String
    let createTime: String
    let url: String
    let attachments: [FlowDoc]
    
    init?(json: JSON) {
        guard let id: Int = "Id" <~~ json,
            let title: String = "Title" <~~ json,
            let depName: String = "DepName" <~~ json,
            let createTime: String = "CreateTime" <~~ json,
            let url: String = "Url" <~~ json,
            let attachments: [FlowDoc] = "Attachments" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.title = title
        self.depName = depName
        self.createTime = createTime
        self.url = url
        self.attachments = attachments
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
