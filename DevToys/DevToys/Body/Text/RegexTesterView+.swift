//
//  RegexTesterView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/03.
//

import Cocoa

final class RegexTesterViewController: ToolPageViewController {
    private let cell = RegexTesterView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
    }
}

final private class RegexTesterView: ToolPage {
    
    let regexField = TextField(showCopyButton: false)
    let textView = TextViewSection(title: "Text", options: .all)
    
    override func onAwake() {
        self.title = "Regex Tester"
        
        self.addSection(Section(title: "Reguler expression", items: [regexField]))
        self.addSection(textView)
    }
}
