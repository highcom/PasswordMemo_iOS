//
//  ViewController.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/24.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var navigateLabel: UILabel!
    @IBOutlet weak var inputPassword: UITextField!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var masterPassword: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        inputPassword.text = ""
        inputPassword.secureTextEntry = true
        
        // マスターパスワードが作成されているかどうかで案内文を変える
        masterPassword = userDefaults.objectForKey("masterPw") as? String
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
            userDefaults.setObject(inputPassword.text, forKey: "masterPw")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func returnMainMenu(segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }

}

