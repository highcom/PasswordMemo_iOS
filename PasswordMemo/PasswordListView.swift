//
//  PasswordListView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/24.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class PasswordListView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var passwordListView: UITableView!

    let dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // テーブルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PasswordEntity.sharedPasswordEntity.passwordItems.count
    }
    
    // テーブルの表示内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = passwordListView.dequeueReusableCellWithIdentifier("PasswordCell")! as UITableViewCell
        let pwItem = PasswordEntity.sharedPasswordEntity.getItems(indexPath.row)
        
        // タイトルタグを取得
        let title = cell.viewWithTag(1) as! UILabel
        title.text = pwItem.titleName
        
        // 日付タグを取得
        let updateDate = cell.viewWithTag(2) as! UILabel
        let date:NSDate? = pwItem.updateDate
        if date == nil {
            updateDate.text = ""
        } else {
            updateDate.text = dateFormatter.stringFromDate(date!)
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
