//
//  SettingMenuView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/02/21.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class SettingMenuView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorData.getSelectColor()
    }
    
    @IBAction func returnSettingMenu(segue: UIStoryboardSegue) {
        self.viewDidLoad()
    }
}
