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
    
    @RestorableState("html.rawString") var rawString = "<script>alert(\"abc\")</script>"
    @RestorableState("html.formattedString") var formattedString = "&#x3C;script&#x3E;alert(&#x22;abc&#x22;)&#x3C;/script&#x3E;"
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.decodeTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; self.formattedString = $0.htmlEscape() }.store(in: &objectBag)
        self.cell.encodeTextSection.stringPublisher
            .sink{[unowned self] in self.formattedString = $0; self.rawString = $0.htmlUnescape() }.store(in: &objectBag)
        
        self.$rawString
            .sink{[unowned self] in self.cell.decodeTextSection.string = $0 }.store(in: &objectBag)
        self.$formattedString
            .sink{[unowned self] in self.cell.encodeTextSection.string = $0 }.store(in: &objectBag)
    }
}

final private class HTMLDecoderView: Page {
    let decodeTextSection = CodeViewSection(title: "Decoded".localized(), options: [.all], language: .xml)
    let encodeTextSection = TextViewSection(title: "Encoded".localized(), options: [.all])
    
    override func layout() {
        super.layout()
        let halfHeight = max(200, (self.frame.height - 100) / 2)
        
        self.decodeTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
        self.encodeTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
    }
    
    override func onAwake() {        
        self.addSection(decodeTextSection)
        self.addSection(encodeTextSection)
    }
}

