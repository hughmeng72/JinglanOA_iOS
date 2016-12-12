//
//  Flow.swift
//  PerkingOpera
//
//  Created by admin on 03/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct Gov: Glossy {
    
    let id: Int
    let flowName: String
    let modelName: String
    let currentStepName: String
    let status: Int
    let depName: String
    let remark: String
    let currentDocPath: String?
    let flowFiles: String?

    let creatorId: Int
    let creator: String
    let createTime: String
    
    let approvalAuthorized: Bool
    
    let steps: [FlowStep]?
    let attachments: [FlowDoc]?
    
    init?(json: JSON) {
        guard let id: Int = "Id" <~~ json,
            let flowName: String = "FlowName" <~~ json,
            let modelName: String = "ModelName" <~~ json,
            let currentStepName: String = "CurrentStepName" <~~ json,
            let status: Int = "Status" <~~ json,
            let depName: String = "DepName" <~~ json,
            let remark: String = "Remark" <~~ json,
            let creatorId: Int = "CreatorId" <~~ json,
            let creator: String = "Creator" <~~ json,
            let createTime: String = "CreateTime" <~~ json,
            let approvalAuthorized: Bool = "ApprovalAuthorized" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.flowName = flowName
        self.modelName = modelName
        self.currentStepName = currentStepName
        self.status = status
        self.depName = depName
        self.remark = remark
        self.currentDocPath = "CurrentDocPath" <~~ json
        self.flowFiles = "FlowFiles" <~~ json;
        self.creatorId = creatorId
        self.creator = creator
        self.createTime = createTime
        self.approvalAuthorized = approvalAuthorized;
        self.steps = "Steps" <~~ json
        self.attachments = "Attachments" <~~ json
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
