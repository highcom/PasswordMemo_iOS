//
//  ViewController.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/24.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var masterPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        masterPassword.secureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func returnMainMenu(segue: UIStoryboardSegue) {
        
    }

}

