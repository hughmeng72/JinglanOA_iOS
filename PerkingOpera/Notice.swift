//
//  Notice.swift
//  PerkingOpera
//
//  Created by admin on 01/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct Notice: Glossy {
    let id: Int
    let typeName: String
    let title: String
    let filePath: String
    let notes: String
    let creator: String
    let addTime: String
    let url: String
    let attachments: [FlowDoc]
    
    init?(json: JSON) {
        guard let id: Int = "id" <~~ json,
        let typeName: String = "TypeName" <~~ json,
        let title: String = "Title" <~~ json,
        let filePath: String = "FilePath" <~~ json,
        let notes: String = "Notes" <~~ json,
        let creator: String = "Creator" <~~ json,
        let addTime: String = "AddTime" <~~ json,
        let url: String = "url" <~~ json,
        let attachments: [FlowDoc] = "Attachments" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.typeName = typeName
        self.title = title
        self.filePath = filePath
        self.notes = notes
        self.creator = creator
        self.addTime = addTime
        self.url = url
        self.attachments = attachments
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
