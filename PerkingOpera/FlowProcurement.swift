//
//  FlowProcurement.swift
//  PerkingOpera
//
//  Created by admin on 03/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct FlowProcurement: Glossy  {
    
    let id: Int
    let productName: String
    let productSpec: String
    let productQuantity: Int
    let amount: Double
    let projectName: String
    let itemName: String
    let totalAmount: Double
    let amountPaidProcurement: Double
    let amountToBePaidProcurement: Double
    let amountPaidReimbursement: Double
    let amountToBePaidReimbursement: Double
    let amountLeft: Double
    
    init?(json: JSON) {
        guard let id: Int = "Id" <~~ json,
            let productName: String = "ProductName" <~~ json,
            let productSpec: String = "ProductSpec" <~~ json,
            let productQuantity: Int = "ProductQuantity" <~~ json,
            let amount: Double = "Amount" <~~ json,
            let projectName: String = "ProjectName" <~~ json,
            let itemName: String = "ItemName" <~~ json,
            let totalAmount: Double = "TotalAmount" <~~ json,
            let amountPaidProcurement: Double = "AmountPaidProcurement" <~~ json,
            let amountToBePaidProcurement: Double = "AmountToBePaidProcurement" <~~ json,
            let amountPaidReimbursement: Double = "AmountPaidReimbursement" <~~ json,
            let amountToBePaidReimbursement: Double = "AmountToBePaidReimbursement" <~~ json,
            let amountLeft: Double = "AmountLeft" <~~ json
            else {
                return nil;
        }
        
        self.id = id
        self.productName = productName
        self.productSpec = productSpec
        self.productQuantity = productQuantity
        self.amount = amount
        self.projectName = projectName
        self.itemName = itemName
        self.totalAmount = totalAmount
        self.amountPaidProcurement = amountPaidProcurement
        self.amountToBePaidProcurement = amountToBePaidProcurement
        self.amountPaidReimbursement = amountPaidReimbursement
        self.amountToBePaidReimbursement = amountToBePaidReimbursement
        self.amountLeft = amountLeft
    }
    
    func toJSON() -> JSON? {
        return nil
    }
}
