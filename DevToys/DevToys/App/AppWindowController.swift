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
        
        self.appModel.$tool
            .sink{[unowned self] in self.window?.title = $0.title }.store(in: &objectBag)
        self.appModel.settings.$appearanceType
            .sink{
                switch $0 {
                case .useSystemSettings: NSApp.appearance = nil
                case .darkMode: NSApp.appearance = NSAppearance(named: .darkAqua)
                case .lightMode: NSApp.appearance = NSAppearance(named: .aqua)
                }
            }
            .store(in: &objectBag)
    }
}
