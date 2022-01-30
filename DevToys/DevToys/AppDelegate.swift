//
//  AppDelegate.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
    }
}

