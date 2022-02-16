//
//  SettingView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/16.
//

import CoreUtil

final class SettingViewController: NSViewController {
    private let cell = SettingView()
    
    override func loadView() { self.view = cell }
    
    override func chainObjectDidLoad() {
        
    }
}

final private class SettingView: Page {
    override func onAwake() {
        
    }
}
