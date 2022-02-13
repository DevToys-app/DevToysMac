//
//  AppWindowController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

final class AppWindowController: NSWindowController {
    let appModel = AppModel()
    
    override func windowDidLoad() {        
        self.contentViewController?.chainObject = appModel
        
        appModel.$tool
            .sink{[unowned self] in self.window?.title = $0.title }.store(in: &objectBag)
    }
}
