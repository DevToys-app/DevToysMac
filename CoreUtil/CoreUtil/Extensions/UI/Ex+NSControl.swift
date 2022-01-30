//
//  Ex+NSControl.swift
//  CoreUtil
//
//  Created by yuki on 2021/10/28.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa

extension NSControl {
    public func setTarget(_ target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    public func executeAction() {
        guard let object = (target as? NSObject), let action = self.action else { return NSSound.beep() }
        
        if object.responds(to: action) {
            object.perform(action, with: self)
        }
    }
}

