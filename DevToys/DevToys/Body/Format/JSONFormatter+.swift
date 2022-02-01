//
//  JSONFormatter+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil
import SwiftJSONFormatter

final class JSONFormatterViewController: NSViewController {
    
    @RestorableState("json.spacingtype") var spacingType: JSONSpacingType = .spaces2
    @RestorableState("json.raw") var rawCode: String = #"{ "Hello": "World" }"#
    @Observable var formattedCode: String = #"{ "Hello": "World" }"#
    
    private let contentView = JSONFormatterView()
    
    override func loadView() { self.view = contentView }
    
    override func viewDidLoad() {
//        self.$spacingType
//            .sink{[unowned self] in contentView.indentControl.selectedItem = $0 }.store(in: &objectBag)
//        self.$rawCode.combineLatest($spacingType)
//            .sink{[unowned self] in self.formattedCode = self.processJSON($0, spacingType: $1) }.store(in: &objectBag)
//        self.$rawCode
//            .sink{[unowned self] in self.contentView.codeInput.code = $0 }.store(in: &objectBag)
//        self.$formattedCode
//            .sink{[unowned self] in contentView.codeOutput.code = $0 }.store(in: &objectBag)
//        self.$formattedCode
//            .sink{[unowned self] in contentView.copyButton.stringContent = $0 }.store(in: &objectBag)
//        
//        self.contentView.indentControl.itemPublisher
//            .sink{ self.spacingType = $0 }.store(in: &objectBag)
//        self.contentView.codeInput.codePublisher
//            .sink{[unowned self] in self.rawCode = $0 }.store(in: &objectBag)
//        self.contentView.pasteButton.stringPublisher.compactMap{ $0 }
//            .sink{[unowned self] in self.rawCode = $0 }.store(in: &objectBag)
//        self.contentView.clearButton.actionPublisher
//            .sink{[unowned self] in self.rawCode = "" }.store(in: &objectBag)
//        self.contentView.openButton.urlPublisher
//            .sink{[unowned self] in self.processURL($0) }.store(in: &objectBag)
    }
    
    private func processURL(_ url: URL) {
        guard let code = try? String(contentsOf: url) else { return NSSound.beep() }
        self.rawCode = code
    }
    
    private func processJSON(_ code: String, spacingType: JSONSpacingType) -> String {
        switch spacingType {
        case .spaces2: return SwiftJSONFormatter.beautify(code, indent: "  ")
        case .spaces4: return SwiftJSONFormatter.beautify(code, indent: "    ")
        case .tab1: return SwiftJSONFormatter.beautify(code, indent: "\t")
        case .minified: return SwiftJSONFormatter.minify(code)
        }
    }
}

enum JSONSpacingType: String, TextItem {
    case spaces2 = "2 Spaces"
    case spaces4 = "4 Spaces"
    case tab1 = "1 Tab"
    case minified = "Minified"
    
    var title: String { rawValue }
}

final private class JSONFormatterView: ToolPage {
    
    let indentControl = EnumPopupButton<JSONSpacingType>()
    let codeInput = CodeTextView(language: .javascript)
    let codeOutput = CodeTextView(language: .javascript)
    let pasteButton = PasteSectionButton()
    let openButton = OpenSectionButton()
    let clearButton = SectionButton(image: R.Image.clear)
    let copyButton = CopySectionButton()
        
    private lazy var indentArea = ControlArea(icon: R.Image.spacing, title: "Indentation", control: indentControl)
    
    private lazy var configurationSection = ControlSection(title: "Configuration", items: [indentArea])
    
    private lazy var inputSection = ControlSection(title: "Input", items: [codeInput], toolbarItems: [pasteButton, openButton, clearButton])
    private lazy var outputSection = ControlSection(title: "Output", items: [codeOutput], toolbarItems: [copyButton])
    
    override func onAwake() {
        self.addSection(configurationSection)
        self.addSection2(inputSection, outputSection)
        
        self.codeInput.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
    }
}
