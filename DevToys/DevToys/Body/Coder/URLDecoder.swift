//
//  URLDecoder.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class URLDecoderViewController: NSViewController {
    private let cell = URLDecoderView()
    
    @RestorableState("url.rawString") var rawString = "https://www.microsoft.com/ja-jp/p/devtoys/9pgcv4v3bk4w?rtc=1#activetab=pivot:overviewtab"
    @RestorableState("url.formattedString") var formattedString = "https%3A%2F%2Fwww.microsoft.com%2Fja-jp%2Fp%2Fdevtoys%2F9pgcv4v3bk4w%3Frtc%3D1%23activetab%3Dpivot%3Aoverviewtab"
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.encodeTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; self.formattedString = encodeToURL($0) }.store(in: &objectBag)
        self.cell.decodeTextSection.stringPublisher
            .sink{[unowned self] in self.formattedString = $0; if let s = $0.removingPercentEncoding { self.rawString = s } }.store(in: &objectBag)
        
        self.$rawString
            .sink{[unowned self] in self.cell.encodeTextSection.string = $0 }.store(in: &objectBag)
        self.$formattedString
            .sink{[unowned self] in self.cell.decodeTextSection.string = $0 }.store(in: &objectBag)
    }
    
    private func encodeToURL(_ string: String) -> String {
        let allowedCharacters = NSCharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? "???"
    }
}

final private class URLDecoderView: Page {
    let encodeTextSection = TextViewSection(title: "Encoded", options: [.all])
    let decodeTextSection = TextViewSection(title: "Decoded", options: [.all])
    
    override func layout() {
        super.layout()
        let halfHeight = max(200, (self.frame.height - 80) / 2)
        
        self.encodeTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
        self.decodeTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
    }
    
    override func onAwake() {        
        self.addSection(encodeTextSection)
        self.addSection(decodeTextSection)
    }
}
