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
    @IBOutlet weak var scvBackGround: UIScrollView!
    @IBOutlet weak var touchIDButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var masterPassword: String?
    var val: ObjCBool = ObjCBool.init(true)
    var enableDataDelete: Bool?
    var incorrectPwTimes: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorData.getSelectColor()
        // Do any additional setup after loading the view, typically from a nib.
        inputPassword.text = ""
        inputPassword.secureTextEntry = true
        
        // 全データ削除機能の有無設定
        enableDataDelete = userDefaults.objectForKey("EnableDataDelete") as? Bool
        if enableDataDelete == nil {
            enableDataDelete = false
        }
        
        // タッチIDボタンの有無設定
        let enableTouchID = userDefaults.objectForKey("EnableTouchID") as? Bool
        if enableTouchID == nil {
            touchIDButton.enabled = false
        } else {
            touchIDButton.enabled = enableTouchID!
        }
        
        // マスターパスワードが作成されているかどうかで案内文を変える
        masterPassword = userDefaults.secureStringForKey("masterPw", valid: &val)
        //masterPassword = userDefaults.objectForKey("masterPw") as? String
        if masterPassword == nil {
            navigateLabel.text = NSLocalizedString("It will create a new password.", comment: "")
        } else {
            navigateLabel.text = NSLocalizedString("Enter the master password.", comment: "")
        }
        
        inputPassword.placeholder = NSLocalizedString("input master password", comment: "")
    }
    
    // キーボードが表示された時の位置の設定
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        
        let txtLimit = inputPassword.frame.origin.y + inputPassword.frame.height + 72.0
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

    //改行ボタンが押された際に呼ばれる.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // ログインボタン
    @IBAction func loginButton(sender: AnyObject) {
        if masterPassword == nil {
            if inputPassword.text == "" {
                navigateLabel.text = NSLocalizedString("Password is empty!", comment: "")
                return
            }
            // マスターパスワードが作成されていない場合は新規作成
            userDefaults.setSecureObject(inputPassword.text, forKey: "masterPw")
            //userDefaults.setObject(inputPassword.text, forKey: "masterPw")
            userDefaults.synchronize()
            self.performSegueWithIdentifier("listViewSegue", sender: nil)
        } else {
            // マスターパスワードが作成済みであればパスワードの照合
            if masterPassword == inputPassword.text {
                incorrectPwTimes = 0
                self.performSegueWithIdentifier("listViewSegue", sender: nil)
            } else {
                if enableDataDelete == false {
                    navigateLabel.text = NSLocalizedString("Password is incorrect!", comment: "")
                    return
                }
                
                // パスワードを5回連続で間違ったらデータをすべて削除する
                incorrectPwTimes += 1
                if incorrectPwTimes >= 5 {
                    // マスターパスワードを削除
                    userDefaults.removeObjectForKey("masterPw")
                    // 全CoreDataを削除
                    for item in PasswordEntity.sharedPasswordEntity.passwordItems {
                        PasswordEntity.sharedPasswordEntity.deletePasswordData(item as! PasswordEntity)
                    }
                    
                    // データをすべて削除したことをアラートに出す
                    let alertController = UIAlertController(title: "Caution!", message: "All data Delete!", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                    
                    // 画面を再表示
                    self.viewDidLoad()
                } else {
                    navigateLabel.text = NSLocalizedString("Password is incorrect! [", comment: "") + String(incorrectPwTimes) + NSLocalizedString(" times]", comment: "")
                }
            }
        }
    }

    // TouchIDによるログインボタン
    @IBAction func loginTouchID(sender: AnyObject) {
        if masterPassword == nil {
            navigateLabel.text = NSLocalizedString("First to create a password.", comment: "")
            return
        }
        
        let context = LAContext()
        var message = ""
        var error :NSError?
        let localizedReason = NSLocalizedString("Authentication of login.", comment: "")
        
        // TouchID認証はサブスレッドで実行される
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            
            //TocuhIDに対応している場合
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: {
                success, error in
                
                if success {
                    // 画面遷移はmainスレッドで実行する
                    self.dispatch_async_main {
                        self.incorrectPwTimes = 0
                        self.performSegueWithIdentifier("listViewSegue", sender: nil)
                    }
                } else {
                    switch error!.code {
                    case LAError.AuthenticationFailed.rawValue:
                        message = NSLocalizedString("Authentication failure.", comment: "")
                    case LAError.UserCancel.rawValue:
                        message = NSLocalizedString("Authentication has been canceled.", comment: "")
                    case LAError.UserFallback.rawValue:
                        message = NSLocalizedString("Select the password input.", comment: "")
                    case LAError.PasscodeNotSet.rawValue:
                        message = NSLocalizedString("Passcode is not set.", comment: "")
                    case LAError.SystemCancel.rawValue:
                        message = NSLocalizedString("It has been canceled by the system.", comment: "")
                    default:
                        message = NSLocalizedString("Unknown error.", comment: "")
                        return
                    }

                    self.dispatch_async_main {
                        self.navigateLabel.text = message
                    }
                }
            })
            
        }else{
            //TocuhIDに対応していない場合
            navigateLabel.text = NSLocalizedString("It does not correspond to TouchID.", comment: "")
        }
    }

    // mainスレッドへのディスパッチ
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }

    // マスターパスワード入力でReturn
    @IBAction func inputMasterPasswordReturn(sender: UITextField) {
        self.view.endEditing(true)
    }

    // 画面がタップされたらキーボードをしまう
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func returnMainMenu(segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }

}
