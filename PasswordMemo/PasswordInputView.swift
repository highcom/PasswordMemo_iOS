//
//  PasswordInputView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/26.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class PasswordInputView: UIViewController {

    @IBOutlet weak var operationName: UINavigationItem!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var memoTextView: PlaceHolderTextView!
    @IBOutlet weak var scvBackGround: UIScrollView!
    
    var titleName: String = ""
    var accountName: String = ""
    var password: String = ""
    var memo: String = ""
    var textFrame: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorData.getSelectColor()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        memoTextView.layer.cornerRadius = 5
        
        if titleName != "" {
            operationName.title = "Edit Data"
        }
        // 編集の場合は前の画面から値が渡されている
        titleField.text = titleName
        accountField.text = accountName
        passwordField.text = password
        
        // メモが何も入力されていない場合はプレースホルダーを表示
        memoTextView.text = memo
        if memoTextView.text.characters.count == 0 {
            memoTextView.placeHolder = "input memo"
        }
    }
    
    // UITextFieldが編集された場合に呼ばれる
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textFrame = textField.frame
        return true
    }
    
    // UITextViewが編集された場合に呼ばれる
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textFrame = textView.frame
        return true
    }
    
    // キーボードが表示された時の位置の設定
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        
        let txtLimit = textFrame.origin.y + textFrame.height + 72.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        
        if txtLimit >= kbdLimit {
            scvBackGround.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    // キーボードが閉じられた時に元に戻す
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        scvBackGround.contentOffset.y = 0
    }
    
    // キーボードが表示された時
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // キーボードが閉じられた時
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // タイトル入力でReturn
    @IBAction func titleTextFieldReturn(sender: UITextField) {
        self.accountField.becomeFirstResponder()
    }
    
    // アカウント入力でReturn
    @IBAction func accountTextFieldReturn(sender: UITextField) {
        self.passwordField.becomeFirstResponder()
    }

    // 画面がタップされたらキーボードをしまう
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
