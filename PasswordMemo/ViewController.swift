//
//  ViewController.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/24.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var navigateLabel: UILabel!
    @IBOutlet weak var inputPassword: UITextField!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var masterPassword: String?
    var val: ObjCBool = ObjCBool.init(true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        inputPassword.text = ""
        inputPassword.secureTextEntry = true
        
        // マスターパスワードが作成されているかどうかで案内文を変える
        masterPassword = userDefaults.secureStringForKey("masterPw", valid: &val)
        //masterPassword = userDefaults.objectForKey("masterPw") as? String
        if masterPassword == nil {
            navigateLabel.text = "It will create a new password."
        } else {
            navigateLabel.text = "Enter the master password."
        }
    }

    // ログインボタン
    @IBAction func loginButton(sender: AnyObject) {
        if masterPassword == nil {
            // マスターパスワードが作成されていない場合は新規作成
            userDefaults.setSecureObject(inputPassword.text, forKey: "masterPw")
            //userDefaults.setObject(inputPassword.text, forKey: "masterPw")
            userDefaults.synchronize()
            self.performSegueWithIdentifier("listViewSegue", sender: nil)
        } else {
            // マスターパスワードが作成済みであればパスワードの照合
            if masterPassword == inputPassword.text {
                self.performSegueWithIdentifier("listViewSegue", sender: nil)
            } else {
                navigateLabel.text = "Password is incorrect!"
            }
        }
    }

    // TouchIDによるログインボタン
    @IBAction func loginTouchID(sender: AnyObject) {
        if masterPassword == nil {
            navigateLabel.text = "First to create a password."
            return
        }
        
        let context = LAContext()
        var message = ""
        var error :NSError?
        let localizedReason = "Authentication of login."
        
        // TouchID認証はサブスレッドで実行される
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            
            //TocuhIDに対応している場合
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: {
                success, error in
                
                if success {
                    // 画面遷移はmainスレッドで実行する
                    self.dispatch_async_main {
                        self.performSegueWithIdentifier("listViewSegue", sender: nil)
                    }
                } else {
                    switch error!.code {
                    case LAError.AuthenticationFailed.rawValue:
                        message = "Authentication failure."
                    case LAError.UserCancel.rawValue:
                        message = "Authentication has been canceled."
                    case LAError.UserFallback.rawValue:
                        message = "Select the path code input."
                    case LAError.PasscodeNotSet.rawValue:
                        message = "Passcode is not set."
                    case LAError.SystemCancel.rawValue:
                        message = "It has been canceled by the system."
                    default:
                        message = "Unknown error."
                        return
                    }

                    self.dispatch_async_main {
                        self.navigateLabel.text = message
                    }
                }
            })
            
        }else{
            //TocuhIDに対応していない場合
            navigateLabel.text = "It does not correspond to TouchID."
        }
    }

    // mainスレッドへのディスパッチ
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func returnMainMenu(segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }

}

