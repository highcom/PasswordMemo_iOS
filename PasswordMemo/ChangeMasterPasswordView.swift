//
//  ChangeMasterPasswordView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/02/21.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class ChangeMasterPasswordView: UIViewController {

    @IBOutlet weak var inputPassword1: UITextField!
    @IBOutlet weak var inputPassword2: UITextField!

    @IBOutlet weak var checkResultLabel: UILabel!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var val: ObjCBool = ObjCBool.init(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputPassword1.secureTextEntry = true
        inputPassword2.secureTextEntry = true
    }
    
    @IBAction func checkPassword(sender: AnyObject) {
        var masterPassword: String?
        masterPassword = userDefaults.secureStringForKey("masterPw", valid: &val)
        //masterPassword = userDefaults.objectForKey("masterPw") as? String
        if inputPassword1.text != inputPassword2.text {
            // 入力が違っていたらエラー
            checkResultLabel.text = "Password is different!"
        } else if masterPassword == inputPassword1.text {
            // マスターパスワードと同じだったらエラー
            checkResultLabel.text = "It is the same as the master password"
        } else {
            // マスターパスワードが作成されていない場合は新規作成
            userDefaults.setSecureObject(inputPassword1.text, forKey: "masterPw")
            //userDefaults.setObject(inputPassword1.text, forKey: "masterPw")
            userDefaults.synchronize()
            // 画面を終了する
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
