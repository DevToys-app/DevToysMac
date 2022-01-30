//
//  HTMLDecoder.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil
import HTMLEntities

final class HTMLDecoderViewController: NSViewController {
    private let cell = HTMLDecoderView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        cell.inputTextView.stringPublisher
            .sink{[unowned self] in cell.outputTextView.string = $0.htmlEscape() }.store(in: &objectBag)
        cell.outputTextView.stringPublisher
            .sink{[unowned self] in cell.inputTextView.string = $0.htmlUnescape() }.store(in: &objectBag)
    }
}

final private class HTMLDecoderView: ToolPage {
    
    let inputTextView = TextView()
    let outputTextView = TextView()
    
    private lazy var inputSection = ControlSection(title: "Encoded", items: [inputTextView]) => { $0.minTitle = true }
    private lazy var outputSection = ControlSection(title: "Decoded", items: [outputTextView]) => { $0.minTitle = true }
    
    override func onAwake() {
        self.title = "HEML Encoder / Decoder"
        
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
