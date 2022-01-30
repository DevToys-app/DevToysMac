//
//  Base64Decoder.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class Base64DecoderViewController: NSViewController {
    private let cell = Base64DecoderView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        cell.inputTextView.stringPublisher
            .sink{[unowned self] in cell.outputTextView.string = $0.data(using: .utf8)!.base64EncodedString() }.store(in: &objectBag)
        cell.outputTextView.stringPublisher
            .sink{[unowned self] in cell.inputTextView.string = String(data: Data(base64Encoded: $0) ?? Data(), encoding: .utf8) ?? "Not String" }.store(in: &objectBag)
    }
}

final private class Base64DecoderView: ToolPage {
    
    let inputTextView = TextView()
    let outputTextView = TextView()
    
    private lazy var inputSection = ControlSection(title: "Encoded", items: [inputTextView]) => { $0.minTitle = true }
    private lazy var outputSection = ControlSection(title: "Decoded", items: [outputTextView]) => { $0.minTitle = true }
    
    override func onAwake() {
        self.title = "Base64 Encoder / Decoder"
        
        self.addSection(inputSection)
        self.addSection(outputSection)
        
        self.inputTextView.snp.makeConstraints{ make in
            make.height.equalTo(200)
        }
        self.outputTextView.snp.makeConstraints{ make in
            make.height.equalTo(200)
        }
    }
}
