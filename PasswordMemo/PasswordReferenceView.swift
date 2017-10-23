//
//  PasswordReferenceView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/31.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class PasswordReferenceView: UIViewController {
    @IBOutlet weak var titleField: UINavigationItem!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var memoTextView: PlaceHolderTextView!

    var now: NSDate = NSDate()
    var deltaTime: TimeInterval = 0.0
    
    var titleName: String = ""
    var accountName: String = ""
    var password: String = ""
    var memo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PasswordReferenceView.enterBackground(_:)), name:NSNotification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PasswordReferenceView.enterForeground(_:)), name:NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.layer.cornerRadius = 5
        
        // 編集の場合は前の画面から値が渡されている
        titleField.title = titleName
        accountField.text = accountName
        passwordField.text = password
        memoTextView.text = memo
        
        // テキストを編集不可にする
        memoTextView.isEditable = false
    }

    // アプリがバックグラウンドになった場合
    func enterBackground(_ notification: NSNotification){
        now = NSDate()
    }
    
    // アプリがフォアグラウンドになった場合
    func enterForeground(_ notification: NSNotification){
        deltaTime = NSDate().timeIntervalSince(now as Date)
        // バックグラウンドになってから2分以上経過した場合はログアウトする
        if (deltaTime > 120) {
            let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginMenu")
            self.present( targetViewController, animated: true, completion: nil)
        }
    }
    
    // テキストフィールドがタップされた場合
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // クリップボードにコピー
        let clipboard = UIPasteboard.general
        clipboard.setValue(textField.text!, forPasteboardType: "public.text")
        
        // クリップボードにコピーしたことをアラートに出す
        let alertController = UIAlertController(title: textField.text, message: NSLocalizedString("Copy to clipboard.", comment: ""), preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        return false
    }
    
    // 編集ボタンがタップされた場合
    @IBAction func editPasswordMemoData(sender: AnyObject) {
        self.performSegue(withIdentifier: "editInputViewSegue", sender: nil)
    }
    
    // 参照画面遷移時に値を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editInputViewSegue" {
            let newVC = segue.destination as! PasswordInputView
            newVC.titleName = titleField.title!
            newVC.accountName = accountField.text!
            newVC.password = passwordField.text!
            newVC.memo = memoTextView.text!
        }
    }
}
