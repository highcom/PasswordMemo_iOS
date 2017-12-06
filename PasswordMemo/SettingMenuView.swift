//
//  SettingMenuView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/02/21.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class SettingMenuView: UIViewController {

    @IBOutlet weak var DataDeleteSw: UISwitch!
    @IBOutlet weak var TouchIDSw: UISwitch!

    var now: NSDate = NSDate()
    var deltaTime: TimeInterval = 0.0
    
    let userDefaults = UserDefaults.standard
    var EnableTouchID: Bool?
    var EnableDataDelete: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingMenuView.enterBackground(_:)), name:NSNotification.Name(rawValue: "applicationDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingMenuView.enterForeground(_:)), name:NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        
        // データ削除機能設定
        DataDeleteSw.addTarget(self, action: #selector(SettingMenuView.onClickDataDeleteSwitch(_:)), for: UIControlEvents.valueChanged)
        EnableDataDelete = userDefaults.object(forKey: "EnableDataDelete") as? Bool
        if EnableDataDelete == nil {
            EnableDataDelete = false
        }
        DataDeleteSw.isOn = EnableDataDelete!
        
        // タッチIDの有効・無効設定
        TouchIDSw.addTarget(self, action: #selector(SettingMenuView.onClickTouchIDSwitch(_:)), for: UIControlEvents.valueChanged)
        EnableTouchID = userDefaults.object(forKey: "EnableTouchID") as? Bool
        if EnableTouchID == nil {
            EnableTouchID = false
        }
        TouchIDSw.isOn = EnableTouchID!
    }
    
    // アプリがバックグラウンドになった場合
    func enterBackground(_ notification: Notification?){
        now = NSDate()
    }
    
    // アプリがフォアグラウンドになった場合
    func enterForeground(_ notification: Notification?){
        deltaTime = NSDate().timeIntervalSince(now as Date)
        // バックグラウンドになってから2分以上経過した場合はログアウトする
        if (deltaTime > 120) {
            let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginMenu")
            self.present( targetViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func returnSettingMenu(_ segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }
    
    // データ削除機能スイッチ
    func onClickDataDeleteSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userDefaults.set(true, forKey: "EnableDataDelete")
        } else {
            userDefaults.set(false, forKey: "EnableDataDelete")
        }
        userDefaults.synchronize()
    }
    
    // タッチID有効スイッチ
    func onClickTouchIDSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userDefaults.set(true, forKey: "EnableTouchID")
        } else {
            userDefaults.set(false, forKey: "EnableTouchID")
        }
        userDefaults.synchronize()
    }
}
