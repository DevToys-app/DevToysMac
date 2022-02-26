//
//  SQLFormatterView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

final class SQLFormatterViewController: NSViewController {
    private let cell = SQLFormatterView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
    }
}

final private class SQLFormatterView: Page {
    override func onAwake() {
        
    }
}
