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
        titleField.title = titleName
        accountField.text = accountName
        passwordField.text = password
        memoTextView.text = memo
        
        // テキストを編集不可にする
        memoTextView.editable = false
    }

    // テキストフィールドがタップされた場合
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // クリップボードにコピー
        let clipboard = UIPasteboard.generalPasteboard()
        clipboard.setValue(textField.text!, forPasteboardType: "public.text")
        
        // クリップボードにコピーしたことをアラートに出す
        let alertController = UIAlertController(title: textField.text, message: "Copy to clipboard.", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        return false
    }
}
