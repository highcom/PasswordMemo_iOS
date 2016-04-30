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
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var EnableTouchID: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorData.getSelectColor()
        
        // データ削除機能設定
        DataDeleteSw.addTarget(self, action: #selector(SettingMenuView.onClickDataDeleteSwitch(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // タッチIDの有効・無効設定
        TouchIDSw.addTarget(self, action: #selector(SettingMenuView.onClickTouchIDSwitch(_:)), forControlEvents: UIControlEvents.ValueChanged)
        EnableTouchID = userDefaults.objectForKey("EnableTouchID") as? Bool
        if EnableTouchID == nil {
            EnableTouchID = false
        }
        TouchIDSw.on = EnableTouchID!
    }
    
    @IBAction func returnSettingMenu(segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }
    
    // データ削除機能スイッチ
    func onClickDataDeleteSwitch(sender: UISwitch) {
        
    }
    
    // タッチID有効スイッチ
    func onClickTouchIDSwitch(sender: UISwitch) {
        if sender.on {
            userDefaults.setObject(true, forKey: "EnableTouchID")
            userDefaults.synchronize()
        } else {
            userDefaults.setObject(false, forKey: "EnableTouchID")
            userDefaults.synchronize()
        }
    }
}
