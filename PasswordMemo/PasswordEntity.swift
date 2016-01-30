//
//  PasswordEntity.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/27.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class PasswordEntity: NSManagedObject {

    // シングルトンで唯一のインスタンスを定義
    class var sharedPasswordEntity: PasswordEntity {
        struct Static {
            static let instance = PasswordEntity()
        }
        return Static.instance
    }
    
    var passwordItems: NSMutableArray = []
    var searchItems: NSMutableArray = []
    var tableSearchText: String?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
    // CoreDataへレコードの書き込み
    func writePasswordData(order: Int, title: String, account: String, password: String, memo: String)
    {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        let myEntity: NSEntityDescription! = NSEntityDescription.entityForName("PasswordEntity", inManagedObjectContext: myContext)
        
        // オブジェクトを新規作成
        let newData = PasswordEntity(entity: myEntity, insertIntoManagedObjectContext: myContext)
        newData.displayOrder = order
        newData.titleName = title
        newData.accountID = account
        newData.password = password
        newData.memo = memo
        newData.updateDate = NSDate()
        
        // 作成したオブジェクトを保存
        var error: NSError? = nil
        do {
            try myContext.save()
        } catch let error1 as NSError {
            error = error1
            NSLog("writeMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataからレコードの読み込み
    func readPasswordData() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "PasswordEntity")
        myRequest.returnsObjectsAsFaults = false
        
        let myResults: NSArray! = try? myContext.executeFetchRequest(myRequest)
        
        passwordItems = []
        for myData in myResults {
            passwordItems.addObject(myData)
        }
        
        // displayOrderの順番で表示
        let sort_descriptor:NSSortDescriptor = NSSortDescriptor(key:"displayOrder", ascending:true)
        passwordItems.sortUsingDescriptors([sort_descriptor])
    }

    // CoreDataのレコードを更新
    func updatePasswordData(editRow: Int, title: String, account: String, password: String, memo: String) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        let editData = getItems(editRow)
        editData.titleName = title
        editData.accountID = account
        editData.password = password
        editData.memo = memo
        editData.updateDate = NSDate()
        
        // 作成したオブジェクトを保存
        var error: NSError? = nil
        do {
            try myContext.save()
        } catch let error1 as NSError {
            error = error1
            NSLog("updateMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataのレコードから部分一致検索
    func searchPasswordMemoData() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        let myRequest: NSFetchRequest = NSFetchRequest(entityName: "PasswordEntity")
        // 検索条件を設定
        let predicate = NSPredicate(format: "%K contains %@", "titleName", tableSearchText!)
        myRequest.predicate = predicate
        
        var error: NSError? = nil;
        // フェッチリクエストの実行
        searchItems = []
        do {
            let results = try myContext.executeFetchRequest(myRequest)
            for managedObject in results {
                searchItems.addObject(managedObject as! PasswordEntity)
            }
            // displayOrderの順番で表示
            let sort_descriptor:NSSortDescriptor = NSSortDescriptor(key:"displayOrder", ascending:true)
            searchItems.sortUsingDescriptors([sort_descriptor])
        } catch let error1 as NSError {
            error = error1
            NSLog("searchMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataの現在の状態を保存
    func savePasswordData() {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        // 作成したオブジェクトを保存
        var error: NSError? = nil
        do {
            try myContext.save()
        } catch let error1 as NSError {
            error = error1
            NSLog("updateMemoData err![\(error)]")
            abort()
        }
    }
    
    // CoreDataのレコードの削除
    func deletePasswordData(object: NSManagedObject) {
        // CoreDataの読み込み処理
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        
        myContext.deleteObject(object)
        
        // 作成したオブジェクトを保存
        var error: NSError? = nil
        do {
            try myContext.save()
        } catch let error1 as NSError {
            error = error1
            NSLog("deleteMemoData err![\(error)]")
            abort()
        }
    }

    // 検索状態に応じてテーブルを返却する
    func getItems(row: Int) -> PasswordEntity {
        if tableSearchText == "" {
            return passwordItems[row] as! PasswordEntity
        } else {
            return searchItems[row] as! PasswordEntity
        }
    }
}
