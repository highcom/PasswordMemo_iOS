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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // テーブルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // テーブルの表示内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = passwordListView.dequeueReusableCellWithIdentifier("PasswordCell")! as UITableViewCell
        // タイトルタグを取得
        let title = cell.viewWithTag(1) as! UILabel
        title.text = "Title"
        
        // 日付タグを取得
        let date = cell.viewWithTag(2) as! UILabel
        date.text = "2015/12/31"
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
