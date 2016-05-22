//
//  SelectColorView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/04/29.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class SelectColorView: UIViewController {
    
    @IBOutlet weak var colorPicker: UIPickerView!

    var now: NSDate = NSDate()
    var deltaTime: NSTimeInterval = 0.0
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var selectColorRow: Int = 0
    var colorNameArray: NSArray = [NSLocalizedString("white", comment: ""),
                                   NSLocalizedString("gray", comment: ""),
                                   NSLocalizedString("brown", comment: ""),
                                   NSLocalizedString("blue", comment: ""),
                                   NSLocalizedString("green", comment: ""),
                                   NSLocalizedString("pink", comment: ""),
                                   NSLocalizedString("yellow", comment: "")]
    var colorCodeArray: NSArray = [0xFFFFFF,
                                   0xDDDDDD,
                                   0xE4D4A1,
                                   0xD7EEFF,
                                   0xE6FFE9,
                                   0xFFD5EC,
                                   0xFFFFDD]

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SelectColorView.enterBackground(_:)), name:"applicationDidEnterBackground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SelectColorView.enterForeground(_:)), name:"applicationWillEnterForeground", object: nil)
        self.view.backgroundColor = ColorData.getSelectColor()
        
        // 保存されたカラーコードと同じ値のrowを取得する
        selectColorRow = 0
        var colorCodeData = userDefaults.objectForKey("selectColor") as? Int
        if colorCodeData == nil {
            colorCodeData = 0xFFFFFF
        }
        
        for colorItem in colorCodeArray {
            if colorItem as? Int == colorCodeData {
                break
            }
            selectColorRow += 1
        }
        
        // もし見つからなかった場合は初期値に戻す
        if selectColorRow >= colorNameArray.count {
            selectColorRow = 0
        }
        
        colorPicker.selectRow(selectColorRow, inComponent: 0, animated: true)
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
    
    // 表示列
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 表示個数
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorNameArray.count
    }
    
    // 表示内容
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return colorNameArray[row] as! String
    }
    
    // 選択時
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.view.backgroundColor = ColorData.setHexColor(colorCodeArray[row] as! Int)
        selectColorRow = row
    }
    
    // 完了時に選択した色を保存する
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        userDefaults.setObject(colorCodeArray[selectColorRow] as! Int, forKey: "selectColor")
        userDefaults.synchronize()
    }
}

class ColorData {
    // hex値で色を設定
    static func setHexColor(hex: Int) -> UIColor {
        let r = Float((hex >> 16) & 0xFF) / 255.0
        let g = Float((hex >> 8) & 0xFF) / 255.0
        let b = Float((hex) & 0xFF) / 255.0
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(1.0))
    }
    
    // 保存された色の値からUIColorを取得する
    static func getSelectColor() -> UIColor {
        var hex = NSUserDefaults.standardUserDefaults().objectForKey("selectColor") as? Int
        if hex == nil {
            hex = 0xFFFFFF
        }
        let r = Float((hex! >> 16) & 0xFF) / 255.0
        let g = Float((hex! >> 8) & 0xFF) / 255.0
        let b = Float((hex!) & 0xFF) / 255.0
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(1.0))
    }
}
