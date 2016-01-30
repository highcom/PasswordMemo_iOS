//
//  PasswordInputView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/26.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class PasswordInputView: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var memoTextView: PlaceHolderTextView!
    
    var titleName: String = ""
    var accountName: String = ""
    var password: String = ""
    var memo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        memoTextView.layer.cornerRadius = 5
        
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
