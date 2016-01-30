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
    var editRow: Int = 0
    // 画面遷移時の状態
    var state = STATE.ST_NONE
    enum STATE {
        case ST_NONE
        case ST_ADD
        case ST_EDIT
    }

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

    // 追加ボタン
    @IBAction func tapAddButton(sender: AnyObject) {
        // ステートを追加状態にする
        state = STATE.ST_ADD
        // データ入力のため詳細画面へ遷移する
        self.performSegueWithIdentifier("inputViewSegue", sender: nil)
    }
    
    // 入力画面のキャンセルボタン
    @IBAction func cancelButton(segue: UIStoryboardSegue) {
        // ステートを初期状態に戻す
        state = STATE.ST_NONE
    }
    
    // 詳細画面の完了ボタン
    @IBAction func doneButton(segue: UIStoryboardSegue) {
        let inputData = segue.sourceViewController as! PasswordInputView
        // 詳細画面の入力データを受け取る
        let titleName = inputData.titleField.text
        let accountName = inputData.accountField.text
        let password = inputData.passwordField.text
        let memo = inputData.memoTextView.text
        
        // infoボタンを押されて編集の場合はレコードを更新にするよう処理を分ける
        if state == STATE.ST_ADD {
            // 詳細画面で入力したデータを追加
            PasswordEntity.sharedPasswordEntity.writePasswordData(PasswordEntity.sharedPasswordEntity.passwordItems.count, title: titleName!, account: accountName!, password: password!, memo: memo!)
        } else if state == STATE.ST_EDIT {
            // 詳細画面で入力したデータで更新
            PasswordEntity.sharedPasswordEntity.updatePasswordData(editRow, title: titleName!, account: accountName!, password: password!, memo: memo!)
        } else {
            NSLog("state err!")
        }
        
        // ステートを初期状態に戻す
        state = STATE.ST_NONE
        // データの再読込
        PasswordEntity.sharedPasswordEntity.readPasswordData()
        // TableViewを再読み込み.
        passwordListView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
