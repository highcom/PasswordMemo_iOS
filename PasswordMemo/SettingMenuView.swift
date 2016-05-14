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
    var deltaTime: NSTimeInterval = 0.0
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var EnableTouchID: Bool?
    var EnableDataDelete: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingMenuView.enterBackground(_:)), name:"applicationDidEnterBackground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingMenuView.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        
        // データ削除機能設定
        DataDeleteSw.addTarget(self, action: #selector(SettingMenuView.onClickDataDeleteSwitch(_:)), forControlEvents: UIControlEvents.ValueChanged)
        EnableDataDelete = userDefaults.objectForKey("EnableDataDelete") as? Bool
        if EnableDataDelete == nil {
            EnableDataDelete = false
        }
        DataDeleteSw.on = EnableDataDelete!
        
        // タッチIDの有効・無効設定
        TouchIDSw.addTarget(self, action: #selector(SettingMenuView.onClickTouchIDSwitch(_:)), forControlEvents: UIControlEvents.ValueChanged)
        EnableTouchID = userDefaults.objectForKey("EnableTouchID") as? Bool
        if EnableTouchID == nil {
            EnableTouchID = false
        }
        TouchIDSw.on = EnableTouchID!
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
    
    @IBAction func returnSettingMenu(segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }
    
    // データ削除機能スイッチ
    func onClickDataDeleteSwitch(sender: UISwitch) {
        if sender.on {
            userDefaults.setObject(true, forKey: "EnableDataDelete")
        } else {
            userDefaults.setObject(false, forKey: "EnableDataDelete")
        }
        userDefaults.synchronize()
    }
    
    // タッチID有効スイッチ
    func onClickTouchIDSwitch(sender: UISwitch) {
        if sender.on {
            userDefaults.setObject(true, forKey: "EnableTouchID")
        } else {
            userDefaults.setObject(false, forKey: "EnableTouchID")
        }
        userDefaults.synchronize()
    }
}
