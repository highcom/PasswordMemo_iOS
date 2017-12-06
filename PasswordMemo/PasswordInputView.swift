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
    
    var now: NSDate = NSDate()
    var deltaTime: TimeInterval = 0.0
    
    var titleName: String = ""
    var accountName: String = ""
    var password: String = ""
    var memo: String = ""
    var textFrame: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PasswordInputView.enterBackground(_:)), name:NSNotification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PasswordInputView.enterForeground(_:)), name:NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGray.cgColor
        memoTextView.layer.cornerRadius = 5
        
        if titleName != "" {
            operationName.title = NSLocalizedString("Edit Data", comment: "")
        }
        // 編集の場合は前の画面から値が渡されている
        titleField.text = titleName
        accountField.text = accountName
        passwordField.text = password
        
        // メモが何も入力されていない場合はプレースホルダーを表示
        memoTextView.text = memo
        if memoTextView.text.characters.count == 0 {
            memoTextView.placeHolder = NSLocalizedString("input memo", comment: "") as NSString
        }
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
    
    // UITextFieldが編集された場合に呼ばれる
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFrame = textField.frame
        return true
    }
    
    // UITextViewが編集された場合に呼ばれる
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textFrame = textView.frame
        return true
    }
    
    // キーボードが表示された時の位置の設定
    func handleKeyboardWillShowNotification(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        let txtLimit = textFrame.origin.y + textFrame.height + 72.0
        let kbdLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        
        if txtLimit >= kbdLimit {
            scvBackGround.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    // キーボードが閉じられた時に元に戻す
    func handleKeyboardWillHideNotification(_ notification: NSNotification) {
        scvBackGround.contentOffset.y = 0
    }
    
    // キーボードが表示された時
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // キーボードが閉じられた時
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // タイトル入力でReturn
    @IBAction func titleTextFieldReturn(sender: UITextField) {
        self.accountField.becomeFirstResponder()
    }
    
    // アカウント入力でReturn
    @IBAction func accountTextFieldReturn(sender: UITextField) {
        self.passwordField.becomeFirstResponder()
    }
    
    // パスワード入力でReturn
    @IBAction func passwordTextFieldReturn(sender: UITextField) {
        self.view.endEditing(true)
    }

    // 画面がタップされたらキーボードをしまう
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
