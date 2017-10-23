//
//  PlaceHolderTextView.swift
//  PasswordMemo
//
//  Created by 晃一 on 2016/01/30.
//  Copyright © 2016年 HIGHCOM. All rights reserved.
//

import UIKit

public class PlaceHolderTextView: UITextView {
    
    lazy var placeHolderLabel:UILabel = UILabel()
    var placeHolderColor:UIColor      = UIColor.lightGray
    var placeHolder:NSString          = ""
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlaceHolderTextView.textChanged(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    func _setText(text:NSString) {
        super.text = text as String
        self.textChanged(nil)
    }
    
    override public func draw(_ rect: CGRect) {
        if(self.placeHolder.length > 0) {
            self.placeHolderLabel.frame           = CGRect(x: 8, y: 8, width: self.bounds.size.width - 16, height: 0)
            self.placeHolderLabel.lineBreakMode   = NSLineBreakMode.byWordWrapping
            self.placeHolderLabel.numberOfLines   = 0
            self.placeHolderLabel.font            = self.font
            self.placeHolderLabel.backgroundColor = UIColor.clear
            self.placeHolderLabel.textColor       = self.placeHolderColor
            self.placeHolderLabel.alpha           = 0
            self.placeHolderLabel.tag             = 999
            
            self.placeHolderLabel.text = self.placeHolder as String
            self.placeHolderLabel.sizeToFit()
            self.addSubview(placeHolderLabel)
        }
        
        self.sendSubview(toBack: placeHolderLabel)
        
        if(self.text.lengthOfBytes(using: String.Encoding.ascii) == 0 && self.placeHolder.length > 0){
            self.viewWithTag(999)?.alpha = 1
        }
        
        super.draw(rect)
    }
    
    public func textChanged(_ notification:NSNotification?) -> (Void) {
        if(self.placeHolder.length == 0){
            return
        }
        
        if(self.text.characters.count == 0) {
            self.viewWithTag(999)?.alpha = 1
        }else{
            self.viewWithTag(999)?.alpha = 0
        }
    }
    
}
