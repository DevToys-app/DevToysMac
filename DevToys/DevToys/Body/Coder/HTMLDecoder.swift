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
    
    @Observable var rawString = "<script>alert(\"abc\")</script>"
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        cell.encodeTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0 }.store(in: &objectBag)
        cell.decodeTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0.htmlUnescape() }.store(in: &objectBag)
        
        self.$rawString
            .sink{[unowned self] in
                self.cell.encodeTextSection.string = $0
                self.cell.decodeTextSection.string = $0.htmlEscape()
            }
            .store(in: &objectBag)
    }
}

final private class HTMLDecoderView: ToolPage {
    
    let encodeTextSection = TextViewSection(title: "Encoded", options: [.all])
    let decodeTextSection = TextViewSection(title: "Decoded", options: [.all])
    
    override func onAwake() {
        self.title = "HEML Encoder / Decoder"
        
        self.addSection(encodeTextSection)
        self.addSection(decodeTextSection)
    }
}

