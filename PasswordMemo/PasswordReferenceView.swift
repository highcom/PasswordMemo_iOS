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
    var deltaTime: NSTimeInterval = 0.0
    
    var titleName: String = ""
    var accountName: String = ""
    var password: String = ""
    var memo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PasswordReferenceView.enterBackground(_:)), name:"applicationDidEnterBackground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PasswordReferenceView.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        memoTextView.layer.cornerRadius = 5
        
        // 編集の場合は前の画面から値が渡されている
        titleField.title = titleName
        accountField.text = accountName
        passwordField.text = password
        memoTextView.text = memo
        
        // テキストを編集不可にする
        memoTextView.editable = false
    }

    // アプリがバックグラウンドになった場合
    func enterBackground(notification: NSNotification){
        now = NSDate()
    }
    
    // アプリがフォアグラウンドになった場合
    func enterForeground(notification: NSNotification){
        deltaTime = NSDate().timeIntervalSinceDate(now)
        // バックグラウンドになってから2分以上経過した場合はログアウトする
        if (deltaTime > 120) {
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginMenu")
            self.presentViewController( targetViewController, animated: true, completion: nil)
        }
    }
    
    // テキストフィールドがタップされた場合
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // クリップボードにコピー
        let clipboard = UIPasteboard.generalPasteboard()
        clipboard.setValue(textField.text!, forPasteboardType: "public.text")
        
        // クリップボードにコピーしたことをアラートに出す
        let alertController = UIAlertController(title: textField.text, message: NSLocalizedString("Copy to clipboard.", comment: ""), preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        return false
    }
    
    // 編集ボタンがタップされた場合
    @IBAction func editPasswordMemoData(sender: AnyObject) {
        self.performSegueWithIdentifier("editInputViewSegue", sender: nil)
    }
    
    // 参照画面遷移時に値を渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editInputViewSegue" {
            let newVC = segue.destinationViewController as! PasswordInputView
            newVC.titleName = titleField.title!
            newVC.accountName = accountField.text!
            newVC.password = passwordField.text!
            newVC.memo = memoTextView.text!
        }
    }
}
