//
//  JSONFormatter+.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil
import SwiftJSONFormatter

final class JSONFormatterViewController: NSViewController {
    
    @RestorableState("json.spacingtype") var spacingType: JSONSpacingType = .spaces4
    
    @RestorableState("jq.rawCode") var rawCode: String = #"{ "Hello": "World" }"#
    @RestorableState("jq.formattedCode") var formattedCode: String = "{\n    \"Hello\": \"World\"\n}"
    
    private let cell = JSONFormatterView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        
        print(TextSectionOptions.defaultInput.contains(.inputable))
        
        self.$spacingType
            .sink{[unowned self] in cell.indentControl.selectedItem = $0 }.store(in: &objectBag)
        self.$rawCode
            .sink{[unowned self] in cell.inputSection.string = $0 }.store(in: &objectBag)
        self.$formattedCode
            .sink{[unowned self] in cell.outputSection.string = $0 }.store(in: &objectBag)
        
        self.cell.inputSection.stringPublisher
            .sink{[unowned self] in self.rawCode = $0; updateFormattedCode() }.store(in: &objectBag)
        self.cell.indentControl.itemPublisher
            .sink{[unowned self] in self.spacingType = $0; updateFormattedCode() }.store(in: &objectBag)
    }
    
    private func updateFormattedCode() {
        self.formattedCode = processJSON(rawCode, spacingType: spacingType)
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
    let inputSection = CodeViewSection(title: "Input", options: .defaultInput, language: .javascript)
    let outputSection = CodeViewSection(title: "Output", options: .defaultOutput, language: .javascript)
        
    private lazy var indentArea = ControlArea(icon: R.Image.spacing, title: "Indentation", control: indentControl)
    
    private lazy var configurationSection = ControlSection(title: "Configuration", items: [indentArea])
    
    override func onAwake() {
        self.title = "Json Formatter"
        self.addSection(configurationSection)
        self.addSection2(inputSection, outputSection)
    }
}
