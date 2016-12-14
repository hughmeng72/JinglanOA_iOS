//
//  Flow.swift
//  PerkingOpera
//
//  Created by admin on 03/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct Flow: Glossy {
    
    let id: Int
    let flowName: String
    let flowNo: String
    let modelName: String
    let amount: Double
    let currentStepName: String
    let status: Int
    let depName: String
    var remark: String
    let currentDocPath: String?
    let flowFiles: String?
    let docBody: String?
    let creatorId: Int
    let creator: String
    let createTime: String
    
    let budgetInvolved: Bool
    let projectName: String?
    let itemName: String?
    let totalAmount: Double
    let amountPaidProcurement: Double
    let amountToBePaidProcurement: Double
    let amountPaidReimbursement: Double
    let amountToBePaidReimbursement: Double
    let amountLeft: Double
    
    let budgetAuthorized: Bool
    let approvalAuthorized: Bool
    
    let steps: [FlowStep]?
    let attachments: [FlowDoc]?
    let procurements: [FlowProcurement]?
    
    init?(json: JSON) {
        guard let id: Int = "Id" <~~ json,
            let flowName: String = "FlowName" <~~ json,
            let flowNo: String = "FlowNo" <~~ json,
            let modelName: String = "ModelName" <~~ json,
            let amount: Double = "Amount" <~~ json,
            let currentStepName: String = "CurrentStepName" <~~ json,
            let status: Int = "Status" <~~ json,
            let depName: String = "DepName" <~~ json,
            let remark: String = "Remark" <~~ json,
            let creatorId: Int = "CreatorId" <~~ json,
            let creator: String = "Creator" <~~ json,
            let createTime: String = "CreateTime" <~~ json,
            let budgetInvolved: Bool = "BudgetInvolved" <~~ json,
            let totalAmount: Double = "TotalAmount" <~~ json,
            let amountPaidProcurement: Double = "AmountPaidProcurement" <~~ json,
            let amountToBePaidProcurement: Double = "AmountToBePaidProcurement" <~~ json,
            let amountPaidReimbursement: Double = "AmountPaidReimbursement" <~~ json,
            let amountToBePaidReimbursement: Double = "AmountToBePaidReimbursement" <~~ json,
            let amountLeft: Double = "AmountLeft" <~~ json,
            let budgetAuthorized: Bool = "BudgetAuthorized" <~~ json,
            let approvalAuthorized: Bool = "ApprovalAuthorized" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.flowName = flowName
        self.flowNo = flowNo
        self.modelName = modelName
        self.amount = amount
        self.currentStepName = currentStepName
        self.status = status
        self.depName = depName
        self.remark = remark
        self.currentDocPath = "CurrentDocPath" <~~ json
        self.flowFiles = "FlowFiles" <~~ json;
        self.docBody = "DocBody" <~~ json
        self.creatorId = creatorId
        self.creator = creator
        self.createTime = createTime
        self.budgetInvolved = budgetInvolved
        self.projectName = "ProjectName" <~~ json
        self.itemName = "ItemName" <~~ json
        self.totalAmount = totalAmount
        self.amountPaidProcurement = amountPaidProcurement
        self.amountToBePaidProcurement = amountToBePaidProcurement
        self.amountPaidReimbursement = amountPaidReimbursement
        self.amountToBePaidReimbursement = amountToBePaidReimbursement
        self.amountLeft = amountLeft
        self.budgetAuthorized = budgetAuthorized
        self.approvalAuthorized = approvalAuthorized;
        self.steps = "Steps" <~~ json
        self.attachments = "Attachments" <~~ json
        self.procurements = "Procurements" <~~ json
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
