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
    var deltaTime: TimeInterval = 0.0
    
    let userDefaults = UserDefaults.standard
    var val: ObjCBool = ObjCBool.init(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeMasterPasswordView.enterBackground(_:)), name:NSNotification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeMasterPasswordView.enterForeground(_:)), name:NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        
        inputPassword1.isSecureTextEntry = true
        inputPassword2.isSecureTextEntry = true
        
        inputPassword1.placeholder = NSLocalizedString("input password", comment: "")
        inputPassword2.placeholder = NSLocalizedString("input password(check)", comment: "")
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
    
    // パスワード入力チェック
    @IBAction func checkPassword(_ sender: AnyObject) {
        var masterPassword: String?
        masterPassword = userDefaults.secureString(forKey: "masterPw", valid: &val)
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
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // パスワード入力１でReturn
    @IBAction func inputPassword1Return(_ sender: UITextField) {
        self.inputPassword2.becomeFirstResponder()
    }

    // パスワード入力２でReturn
    @IBAction func inputPassword2Return(_ sender: UITextField) {
        self.view.endEditing(true)
    }
    
    // 画面がタップされたらキーボードをしまう
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
