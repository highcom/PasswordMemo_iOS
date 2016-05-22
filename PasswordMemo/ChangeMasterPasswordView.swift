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
    
    var now: NSDate = NSDate()
    var deltaTime: NSTimeInterval = 0.0
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var val: ObjCBool = ObjCBool.init(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChangeMasterPasswordView.enterBackground(_:)), name:"applicationDidEnterBackground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChangeMasterPasswordView.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        
        inputPassword1.secureTextEntry = true
        inputPassword2.secureTextEntry = true
        
        inputPassword1.placeholder = NSLocalizedString("input password", comment: "")
        inputPassword2.placeholder = NSLocalizedString("input password(check)", comment: "")
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
    
    // パスワード入力チェック
    @IBAction func checkPassword(sender: AnyObject) {
        var masterPassword: String?
        masterPassword = userDefaults.secureStringForKey("masterPw", valid: &val)
        //masterPassword = userDefaults.objectForKey("masterPw") as? String
        if inputPassword1.text != inputPassword2.text {
            // 入力が違っていたらエラー
            checkResultLabel.text = NSLocalizedString("Input password is different!", comment: "")
        } else if inputPassword1.text == "" {
            // パスワードが空ならエラー
            checkResultLabel.text = NSLocalizedString("Password is empty!", comment: "")
        } else if masterPassword == inputPassword1.text {
            // マスターパスワードと同じだったらエラー
            checkResultLabel.text = NSLocalizedString("It is same as the master password.", comment: "")
        } else {
            // マスターパスワードが作成されていない場合は新規作成
            userDefaults.setSecureObject(inputPassword1.text, forKey: "masterPw")
            //userDefaults.setObject(inputPassword1.text, forKey: "masterPw")
            userDefaults.synchronize()
            // 画面を終了する
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // パスワード入力１でReturn
    @IBAction func inputPassword1Return(sender: UITextField) {
        self.inputPassword2.becomeFirstResponder()
    }

    // パスワード入力２でReturn
    @IBAction func inputPassword2Return(sender: UITextField) {
        self.view.endEditing(true)
    }
    
    // 画面がタップされたらキーボードをしまう
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
