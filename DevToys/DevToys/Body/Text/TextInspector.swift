//
//  TextInspector.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class TextInspectorViewController: NSViewController {
    private let cell = TextInspectorView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
    }
}

final class TextInspectorView: ToolPage {
    let inputSection = TextViewSection(title: "Input", options: .defaultInput)
    let tagCloudView = TagCloudView()
    let outputSection = TextViewSection(title: "Output", options: .defaultOutput)
    
    override func onAwake() {
        self.title = "Text Case Converter and Inspector"
        
        self.tagCloudView.items = [
            "Original text", "Sentence case", "lower case", "UPPER CASE", "Title Case", "camelCase",
            "Original text", "Sentence case", "lower case", "UPPER CASE", "Title Case", "camelCase",
        ]
        
        self.addSection(inputSection)
        self.addSection(ControlSection(title: "Convert", items: [tagCloudView]))
        self.addSection(outputSection)

        self.tagCloudView.snp.remakeConstraints{ make in
            make.height.equalTo(68)
            make.width.equalToSuperview()
        }
    }
}
