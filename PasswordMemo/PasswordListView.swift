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

    var locale = NSLocale.currentLocale()
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
        
        PasswordEntity.sharedPasswordEntity.tableSearchText = ""
        
        // 日付表示フォーマットを指定
        dateFormatter.locale = NSLocale(localeIdentifier: locale.description)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        PasswordEntity.sharedPasswordEntity.readPasswordData()
    }
    
    // テーブルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var tableCount = 0
        // 検索中か
        if PasswordEntity.sharedPasswordEntity.tableSearchText == "" {
            tableCount = PasswordEntity.sharedPasswordEntity.passwordItems.count
        } else {
            tableCount = PasswordEntity.sharedPasswordEntity.searchItems.count
        }
        
        return tableCount
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
    
    // Cellを挿入または削除しようとした際に呼び出される
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // 削除のとき.
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // 削除するセルのdisplayOrderを保持する
            let delValue = PasswordEntity.sharedPasswordEntity.getItems(indexPath.row).displayOrder!.integerValue
            
            // CoreDataからレコードをを削除する
            PasswordEntity.sharedPasswordEntity.deletePasswordData(PasswordEntity.sharedPasswordEntity.getItems(indexPath.row) as PasswordEntity)
            
            // 指定されたセルのオブジェクトをmyItemsから削除する.
            PasswordEntity.sharedPasswordEntity.passwordItems.removeObjectAtIndex(delValue)
            if PasswordEntity.sharedPasswordEntity.tableSearchText != "" {
                PasswordEntity.sharedPasswordEntity.searchItems.removeObjectAtIndex(indexPath.row)
            }
            
            // 削除したセル以降のdisplayOrderをつめる
            for var i = delValue; i < PasswordEntity.sharedPasswordEntity.passwordItems.count; i++ {
                let buffItem = PasswordEntity.sharedPasswordEntity.passwordItems[i] as! PasswordEntity
                buffItem.displayOrder = buffItem.displayOrder!.integerValue - 1
            }
            
            // TableViewを再読み込み.
            tableView.reloadData()
            
            // データ数が0になった場合は編集モードをキャンセルする
            if PasswordEntity.sharedPasswordEntity.passwordItems.count == 0 && editing {
                super.setEditing(false, animated: true)
                tableView.setEditing(false, animated: true)
            }
        }
    }
    
    // セルが選択された場合は参照画面に遷移する
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択された行数を設定
        editRow = indexPath.row
        self.performSegueWithIdentifier("referenceViewSegue", sender: nil)
    }
    
    // 参照画面遷移時に値を渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "referenceViewSegue" {
            // 選択したテーブルのデータを詳細画面に渡す
            let editData = PasswordEntity.sharedPasswordEntity.getItems(editRow)
            let newVC = segue.destinationViewController as! PasswordReferenceView
            newVC.titleName = editData.titleName!
            newVC.accountName = editData.accountID!
            newVC.password = editData.password!
            newVC.memo = editData.memo!
        }
    }

    // 追加ボタン
    @IBAction func tapAddButton(sender: AnyObject) {
        // ステートを追加状態にする
        state = STATE.ST_ADD
        // データ入力のため詳細画面へ遷移する
        self.performSegueWithIdentifier("inputViewSegue", sender: nil)
    }
    
    // 編集ボタン
    @IBAction func tapEdit(sender: AnyObject) {
        var tableCount = 0
        // 検索中か
        if PasswordEntity.sharedPasswordEntity.tableSearchText == "" {
            tableCount = PasswordEntity.sharedPasswordEntity.passwordItems.count
        } else {
            tableCount = PasswordEntity.sharedPasswordEntity.searchItems.count
        }
        // テーブルに表示されているデータが0件の場合には何もしない
        if tableCount == 0 {
            return
        }
        
        if editing {
            super.setEditing(false, animated: true)
            passwordListView.setEditing(false, animated: true)
        } else {
            super.setEditing(true, animated: true)
            passwordListView.setEditing(true, animated: true)
        }
    }
    
    // 並べ替えをできるようにする
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // 並べ替えたら、その順番でCoreDataに保存する
        let srcIndex = sourceIndexPath.row
        let desIndex = destinationIndexPath.row
        var minIndex = 0
        var maxIndex = 0
        var isMoveDir = false
        
        if srcIndex == desIndex {
            return
        } else if srcIndex < desIndex {
            minIndex = srcIndex
            maxIndex = desIndex
            isMoveDir = true
        } else {
            minIndex = desIndex
            maxIndex = srcIndex
            isMoveDir = false
        }
        
        for var i = minIndex; i <= maxIndex; i++ {
            var newOrder = 0
            if i == srcIndex {
                newOrder = desIndex
            } else if isMoveDir {
                let buffItem = PasswordEntity.sharedPasswordEntity.passwordItems[i] as! PasswordEntity
                newOrder = (buffItem.displayOrder?.integerValue)! - 1
            } else {
                let buffItem = PasswordEntity.sharedPasswordEntity.passwordItems[i] as! PasswordEntity
                newOrder = (buffItem.displayOrder?.integerValue)! + 1
            }
            PasswordEntity.sharedPasswordEntity.passwordItems[i].setValue(newOrder, forKey: "displayOrder")
        }
        // 現在の状態を保存する
        PasswordEntity.sharedPasswordEntity.savePasswordData()
        // 順番が変わったのでデータを再読込する
        PasswordEntity.sharedPasswordEntity.readPasswordData()
    }
    
    // 検索状態に応じてtableViewを並べ替え可能・不可能を設定
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // 検索中でない場合は並べ替えを可能とする
        if PasswordEntity.sharedPasswordEntity.tableSearchText == "" {
            return true
        } else {
            return false
        }
    }
    
    // 検索バー入力開始時
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // 検索バーを伸ばす
        searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.width + 70, searchBar.frame.height)
        // キャンセルボタンを有効化する
        searchBar.showsCancelButton = true
        // AutoResizeを無効化する
        searchBar.translatesAutoresizingMaskIntoConstraints = true
    }

    // 検索バー入力イベント
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: 検索バーで入力された文字列をCoreDataから検索
        // テキストが変更される毎に呼ばれる
        PasswordEntity.sharedPasswordEntity.tableSearchText = searchText
        // CoreDataから検索する
        PasswordEntity.sharedPasswordEntity.searchPasswordData()
        // TableViewを再読み込み.
        passwordListView.reloadData()
    }
    
    // 検索ボタンが押下された場合
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // キーボードをしまう
        self.view.endEditing(true)
        // CoreDataから検索する
        PasswordEntity.sharedPasswordEntity.searchPasswordData()
        // TableViewを再読み込み.
        passwordListView.reloadData()
    }
    
    // キャンセルボタンが押下された場合
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // キーボードをしまう
        self.view.endEditing(true)
        // 文字列を初期化する
        PasswordEntity.sharedPasswordEntity.tableSearchText = ""
        searchBar.text = ""
        // TableViewを再読み込み.
        passwordListView.reloadData()
    }
    
    // 検索バー入力終了時
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // キャンセルボタンを無効化する
        searchBar.showsCancelButton = false
        // 検索バーを元のサイズに戻す
        searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.width - 60, searchBar.frame.height)
        // AutoResizeを有効化する
        searchBar.translatesAutoresizingMaskIntoConstraints = false
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
