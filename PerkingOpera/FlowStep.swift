//
//  FlowStep.swift
//  PerkingOpera
//
//  Created by admin on 03/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct FlowStep: Glossy {
    
    let stepName: String
    let userName: String
    let addTime: String
    let action: String
    let result: String
    let description: String
    
    init?(json: JSON) {
        guard let stepName: String = "StepName" <~~ json,
            let userName: String = "UserName" <~~ json,
            let addTime: String = "AddTime" <~~ json,
            let action: String = "Action" <~~ json,
            let result: String = "Result" <~~ json,
            let description: String = "Description" <~~ json
            else {
                return nil;
        }
        
        self.stepName = stepName
        self.userName = userName
        self.addTime = addTime
        self.action = action
        self.result = result
        self.description = description
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}

