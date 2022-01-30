//
//  URLDecoder.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class URLDecoderViewController: NSViewController {
    private let cell = URLDecoderView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        cell.inputTextView.stringPublisher
            .sink{[unowned self] in cell.outputTextView.string = encodeToURL($0) }.store(in: &objectBag)
        cell.outputTextView.stringPublisher
            .sink{[unowned self] in cell.inputTextView.string = $0.removingPercentEncoding ?? "???" }.store(in: &objectBag)
    }
    
    private func encodeToURL(_ string: String) -> String {
        let allowedCharacters = NSCharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? "???"
    }
}

final private class URLDecoderView: ToolPage {
    
    let inputTextView = TextView()
    let outputTextView = TextView()
    
    private lazy var inputSection = ControlSection(title: "Encoded", items: [inputTextView]) => { $0.minTitle = true }
    private lazy var outputSection = ControlSection(title: "Decoded", items: [outputTextView]) => { $0.minTitle = true }
    
    override func onAwake() {
        self.title = "URL Encoder / Decoder"
        
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
