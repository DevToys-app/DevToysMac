//
//  Base64Decoder.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class Base64DecoderViewController: NSViewController {
    private let cell = Base64DecoderView()
    
    @RestorableState("base64.rawString") var rawString = defaultRawString
    @RestorableState("base64.formattedString") var formattedString = defaultBase64String
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.encodeTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; self.formattedString = encode($0) }.store(in: &objectBag)
        self.cell.decodeTextSection.stringPublisher
            .sink{[unowned self] in self.formattedString = $0; self.rawString = decode($0) }.store(in: &objectBag)
        
        self.$rawString
            .sink{[unowned self] in self.cell.encodeTextSection.string = $0 }.store(in: &objectBag)
        self.$formattedString
            .sink{[unowned self] in self.cell.decodeTextSection.string = $0 }.store(in: &objectBag)
    }
    
    private func encode(_ string: String) -> String {
        string.data(using: .utf8)!.base64EncodedString()
    }
    private func decode(_ string: String) -> String {
        String(data: Data(base64Encoded: string) ?? Data(), encoding: .utf8) ?? "Not String"
    }
}

final private class Base64DecoderView: ToolPage {
    let encodeTextSection = TextViewSection(title: "Encoded", options: [.all])
    let decodeTextSection = TextViewSection(title: "Decoded", options: [.all])
    
    override func onAwake() {
        self.title = "Base64 Encoder / Decoder"
        
        self.addSection(encodeTextSection)
        self.addSection(decodeTextSection)
    }
}

private let defaultRawString = "An Open-Source Swiss Army knife for developers. DevToys helps in everyday tasks like formatting JSON, comparing text, testing RegExp. No need to use many untruthful websites to do simple tasks with your data. With Smart Detection, DevToys is able to detect the best tool that can treat the data you copied in the clipboard of your Windows. Compact overlay lets you keep the app in small and on top of other windows. Multiple instances of the app can be used at once."

private let defaultBase64String = "QW4gT3Blbi1Tb3VyY2UgU3dpc3MgQXJteSBrbmlmZSBmb3IgZGV2ZWxvcGVycy4KRGV2VG95cyBoZWxwcyBpbiBldmVyeWRheSB0YXNrcyBsaWtlIGZvcm1hdHRpbmcgSlNPTiwgY29tcGFyaW5nIHRleHQsIHRlc3RpbmcgUmVnRXhwLiBObyBuZWVkIHRvIHVzZSBtYW55IHVudHJ1dGhmdWwgd2Vic2l0ZXMgdG8gZG8gc2ltcGxlIHRhc2tzIHdpdGggeW91ciBkYXRhLiBXaXRoIFNtYXJ0IERldGVjdGlvbiwgRGV2VG95cyBpcyBhYmxlIHRvIGRldGVjdCB0aGUgYmVzdCB0b29sIHRoYXQgY2FuIHRyZWF0IHRoZSBkYXRhIHlvdSBjb3BpZWQgaW4gdGhlIGNsaXBib2FyZCBvZiB5b3VyIFdpbmRvd3MuIENvbXBhY3Qgb3ZlcmxheSBsZXRzIHlvdSBrZWVwIHRoZSBhcHAgaW4gc21hbGwgYW5kIG9uIHRvcCBvZiBvdGhlciB3aW5kb3dzLiBNdWx0aXBsZSBpbnN0YW5jZXMgb2YgdGhlIGFwcCBjYW4gYmUgdXNlZCBhdCBvbmNlLg=="
