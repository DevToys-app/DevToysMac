//
//  Base64Decoder.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

extension Data {

    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
}

final class Base64DecoderViewController: NSViewController {
    private let cell = Base64DecoderView()
    
    @RestorableState("base64.sourceType") private var sourceType = SourceType.text
    @RestorableState("base64.rawString") private var rawString = defaultRawString
    @Observable private var formattedString = defaultBase64String
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.inputTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; self.formattedString = encode($0) }.store(in: &objectBag)
        self.cell.hexTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; self.formattedString = encodeHex($0) }.store(in: &objectBag)
        self.cell.encodeTextSection.stringPublisher
            .sink{[unowned self] in self.formattedString = $0; self.rawString = sourceType == SourceType.hex ? decodeHex($0) : decode($0) }.store(in: &objectBag)
        self.cell.sourceTypePicker.itemPublisher
            .sink{[unowned self] in self.sourceType = $0 }.store(in: &objectBag)
        self.cell.fileDrop.urlsPublisher.compactMap{ $0.first }
            .sink{[unowned self] in self.formattedString = self.encodeFile($0) }.store(in: &objectBag)
        self.cell.exportButton.actionPublisher
            .sink{[unowned self] in self.exportFile() }.store(in: &objectBag)
        
        self.$sourceType
            .sink{[unowned self] in self.cell.sourceTypePicker.selectedItem = $0; updateEncodeView($0) }.store(in: &objectBag)
        self.$rawString
            .sink{[unowned self] in self.cell.inputTextSection.string = $0 }.store(in: &objectBag)
        self.$rawString
            .sink{[unowned self] in self.cell.hexTextSection.string = $0 }.store(in: &objectBag)
        self.$formattedString
            .sink{[unowned self] in self.cell.encodeTextSection.string = $0 }.store(in: &objectBag)
    }
    
    private func updateEncodeView(_ sourceType: SourceType) {
        switch sourceType {
        case .file:
            self.cell.inputSectionContainer.contentView = cell.fileDropSection
        case .text:
            self.cell.inputSectionContainer.contentView = cell.inputTextSection
            self.formattedString = self.encode(rawString)
        case .hex:
            self.cell.inputSectionContainer.contentView = cell.hexTextSection
            self.formattedString = self.encodeHex(rawString)
        }
    }
    
    private func exportFile() {
        let panel = NSSavePanel()
        guard let data = Data(base64Encoded: formattedString), panel.runModal() == .OK, let url = panel.url else { return }
        
        do {
            try data.write(to: url)
        } catch {
            NSSound.beep()
        }
    }
    private func encodeFile(_ url: URL) -> String {
        (try? Data(contentsOf: url).base64EncodedString()) ?? "[Encode Failed]"
    }
    private func encode(_ string: String) -> String {
        string.data(using: .utf8)!.base64EncodedString()
    }
    private func encodeHex(_ string: String) -> String {
        (string.count % 2 != 0) ? "must be even length" : (string.hexadecimal?.base64EncodedString() ?? "not hex string")
    }
    private func decode(_ string: String) -> String {
        String(data: Data(base64Encoded: string) ?? Data(), encoding: .utf8) ?? "Not String"
    }
    private func decodeHex(_ string: String) -> String {
        Data(base64Encoded: string)?.hexadecimal.uppercased() ?? "Not Hex String"
    }
}

private enum SourceType: String, TextItem {
    case text = "Text Source"
    case file = "File Source"
    case hex = "Hex Source"
    var title: String { rawValue.localized() }
}

final private class Base64DecoderView: Page {
    let sourceTypePicker = EnumPopupButton<SourceType>()
    
    let fileDrop = FileDrop()
    let exportButton = SectionButton(title: "Export".localized(), image: R.Image.export)
    let inputSectionContainer = NSPlaceholderView()
    let inputTextSection = TextViewSection(title: "Text".localized(), options: [.all])
    let hexTextSection = TextViewSection(title: "Hex".localized(), options: [.all])
    lazy var fileDropSection = Section(title: "File".localized(), items: [fileDrop], toolbarItems: [exportButton])
    
    let encodeTextSection = TextViewSection(title: "Encoded".localized(), options: [.all])
    
    override func layout() {
        super.layout()
        let halfHeight = max(200, (self.frame.height - 190) / 2)
        
        self.fileDropSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
        self.inputTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
        self.hexTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
        self.encodeTextSection.snp.remakeConstraints{ make in
            make.height.equalTo(halfHeight)
        }
    }
    
    override func onAwake() {            
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.convert, title: "Source Type".localized(), control: sourceTypePicker)
        ]))
        self.inputSectionContainer.contentView = inputTextSection
        self.addSection(inputSectionContainer)
        self.addSection(inputTextSection)
        self.addSection(hexTextSection)
        self.addSection(encodeTextSection)
    }
}

private let defaultRawString = "An Open-Source Swiss Army knife for developers. DevToys helps in everyday tasks like formatting JSON, comparing text, testing RegExp. No need to use many untruthful websites to do simple tasks with your data. With Smart Detection, DevToys is able to detect the best tool that can treat the data you copied in the clipboard of your Windows. Compact overlay lets you keep the app in small and on top of other windows. Multiple instances of the app can be used at once."

private let defaultBase64String = "QW4gT3Blbi1Tb3VyY2UgU3dpc3MgQXJteSBrbmlmZSBmb3IgZGV2ZWxvcGVycy4KRGV2VG95cyBoZWxwcyBpbiBldmVyeWRheSB0YXNrcyBsaWtlIGZvcm1hdHRpbmcgSlNPTiwgY29tcGFyaW5nIHRleHQsIHRlc3RpbmcgUmVnRXhwLiBObyBuZWVkIHRvIHVzZSBtYW55IHVudHJ1dGhmdWwgd2Vic2l0ZXMgdG8gZG8gc2ltcGxlIHRhc2tzIHdpdGggeW91ciBkYXRhLiBXaXRoIFNtYXJ0IERldGVjdGlvbiwgRGV2VG95cyBpcyBhYmxlIHRvIGRldGVjdCB0aGUgYmVzdCB0b29sIHRoYXQgY2FuIHRyZWF0IHRoZSBkYXRhIHlvdSBjb3BpZWQgaW4gdGhlIGNsaXBib2FyZCBvZiB5b3VyIFdpbmRvd3MuIENvbXBhY3Qgb3ZlcmxheSBsZXRzIHlvdSBrZWVwIHRoZSBhcHAgaW4gc21hbGwgYW5kIG9uIHRvcCBvZiBvdGhlciB3aW5kb3dzLiBNdWx0aXBsZSBpbnN0YW5jZXMgb2YgdGhlIGFwcCBjYW4gYmUgdXNlZCBhdCBvbmNlLg=="
