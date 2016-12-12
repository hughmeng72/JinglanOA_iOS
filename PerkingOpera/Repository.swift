//
//  Repository.swift
//  PerkingOpera
//
//  Created by admin on 02/12/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

class Repository {
    static let sharedInstance = Repository()
    
    private init() {
        
    }
    
    var user: User?
}
