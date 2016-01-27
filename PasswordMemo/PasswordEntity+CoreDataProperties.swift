//
//  PasswordEntity+CoreDataProperties.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/27.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PasswordEntity {

    @NSManaged var displayOrder: NSNumber?
    @NSManaged var titleName: String?
    @NSManaged var updateDate: NSDate?
    @NSManaged var accountID: String?
    @NSManaged var password: String?
    @NSManaged var memo: String?

}
