//
//  FlowDoc.swift
//  PerkingOpera
//
//  Created by admin on 01/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct FlowDoc : Glossy {
    let fileName: String
    let uri: String
    
    init?(json: JSON) {
        guard let fileName: String = "FileName" <~~ json,
        let uri: String = "Uri" <~~ json
            else {
                return nil;
        }
        
        self.fileName = fileName
        self.uri = uri
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
