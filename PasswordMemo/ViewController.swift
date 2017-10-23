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
    
    let userDefaults = UserDefaults.standard
    var masterPassword: String?
    var val: ObjCBool = ObjCBool.init(true)
    var enableDataDelete: Bool?
    var incorrectPwTimes: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorData.getSelectColor()
        // Do any additional setup after loading the view, typically from a nib.
        inputPassword.text = ""
        inputPassword.isSecureTextEntry = true
        
        // 全データ削除機能の有無設定
        enableDataDelete = userDefaults.object(forKey: "EnableDataDelete") as? Bool
        if enableDataDelete == nil {
            enableDataDelete = false
        }
        
        // タッチIDボタンの有無設定
        let enableTouchID = userDefaults.object(forKey: "EnableTouchID") as? Bool
        if enableTouchID == nil {
            touchIDButton.isEnabled = false
        } else {
            touchIDButton.isEnabled = enableTouchID!
        }
        
        // マスターパスワードが作成されているかどうかで案内文を変える
        masterPassword = userDefaults.secureString(forKey: "masterPw", valid: &val)
        //masterPassword = userDefaults.objectForKey("masterPw") as? String
        if masterPassword == nil {
            navigateLabel.text = NSLocalizedString("It will create a new password.", comment: "")
        } else {
            navigateLabel.text = NSLocalizedString("Enter the master password.", comment: "")
        }
        
        inputPassword.placeholder = NSLocalizedString("input master password", comment: "")
    }
    
    // キーボードが表示された時の位置の設定
    func handleKeyboardWillShowNotification(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        let txtLimit = inputPassword.frame.origin.y + inputPassword.frame.height + 72.0
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
            self.performSegue(withIdentifier: "listViewSegue", sender: nil)
        } else {
            // マスターパスワードが作成済みであればパスワードの照合
            if masterPassword == inputPassword.text {
                incorrectPwTimes = 0
                self.performSegue(withIdentifier: "listViewSegue", sender: nil)
            } else {
                if enableDataDelete == false {
                    navigateLabel.text = NSLocalizedString("Password is incorrect!", comment: "")
                    return
                }
                
                // パスワードを5回連続で間違ったらデータをすべて削除する
                incorrectPwTimes += 1
                if incorrectPwTimes >= 5 {
                    // マスターパスワードを削除
                    userDefaults.removeObject(forKey: "masterPw")
                    // 全CoreDataを削除
                    for item in PasswordEntity.sharedPasswordEntity.passwordItems {
                        PasswordEntity.sharedPasswordEntity.deletePasswordData(object: item as! PasswordEntity)
                    }
                    
                    // データをすべて削除したことをアラートに出す
                    let alertController = UIAlertController(title: "Caution!", message: "All data Delete!", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    present(alertController, animated: true, completion: nil)
                    
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
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error){
            
            //TocuhIDに対応している場合
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: {
                success, error in
                
                if success {
                    // 画面遷移はmainスレッドで実行する
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            self.incorrectPwTimes = 0
                            self.performSegue(withIdentifier: "listViewSegue", sender: nil)
                        }
                    }
/*
                    self.dispatch_async_main {
                        self.incorrectPwTimes = 0
                        self.performSegue(withIdentifier: "listViewSegue", sender: nil)
                    }
 */
                } else {
                    switch error!._code {
                    case LAError.authenticationFailed.rawValue:
                        message = NSLocalizedString("Authentication failure.", comment: "")
                    case LAError.userCancel.rawValue:
                        message = NSLocalizedString("Authentication has been canceled.", comment: "")
                    case LAError.userFallback.rawValue:
                        message = NSLocalizedString("Select the password input.", comment: "")
                    case LAError.passcodeNotSet.rawValue:
                        message = NSLocalizedString("Passcode is not set.", comment: "")
                    case LAError.systemCancel.rawValue:
                        message = NSLocalizedString("It has been canceled by the system.", comment: "")
                    default:
                        message = NSLocalizedString("Unknown error.", comment: "")
                        return
                    }
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            self.navigateLabel.text = message
                        }
                    }
/*
                    self.dispatch_async_main {
                        self.navigateLabel.text = message
                    }
 */
                }
            })
            
        }else{
            //TocuhIDに対応していない場合
            navigateLabel.text = NSLocalizedString("It does not correspond to TouchID.", comment: "")
        }
    }

    // mainスレッドへのディスパッチ
/*
    func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
*/
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
