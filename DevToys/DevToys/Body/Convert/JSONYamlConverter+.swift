//
//  JSONYamlConverter+.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil
import Yams

final class JSONYamlConverterViewController: NSViewController {
    private let cell = JSONYamlConverterView()
    
    @RestorableState("jy.type") private var convertionType: JsonConvertionType = .jsonToYaml
    @RestorableState("jy.format") private var formatStyle: FormatStyle = .pretty
    @Observable private var code = ""
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$code
            .sink{[unowned self] in self.cell.codeInput.code = $0 }.store(in: &objectBag)
        self.$convertionType
            .sink{[unowned self] in self.updateConvertionType(convertionType: $0) }.store(in: &objectBag)
        self.$formatStyle.combineLatest($code)
            .sink{[unowned self] in self.process(formatStyle: $0, code: $1) }.store(in: &objectBag)
        self.$convertionType
            .sink{[unowned self] in self.cell.convertionPicker.selectedItem = $0 }.store(in: &objectBag)
        self.$formatStyle
            .sink{[unowned self] in self.cell.formatStylePicker.selectedItem = $0 }.store(in: &objectBag)
        
        self.cell.convertionPicker.itemPublisher
            .sink{[unowned self] in self.convertionType = $0 }.store(in: &objectBag)
        self.cell.formatStylePicker.itemPublisher
            .sink{[unowned self] in self.formatStyle = $0 }.store(in: &objectBag)
        
        self.cell.codeInput.codePublisher
            .sink{[unowned self] in self.code = $0 }.store(in: &objectBag)
        self.cell.pasteButton.stringPublisher.compactMap{ $0 }
            .sink{[unowned self] in self.code = $0 }.store(in: &objectBag)
        self.cell.clearButton.actionPublisher
            .sink{[unowned self] in self.code = "" }.store(in: &objectBag)
        self.cell.openButton.urlPublisher
            .sink{[unowned self] in self.processURL($0) }.store(in: &objectBag)
    }
    
    private func updateConvertionType(convertionType: JsonConvertionType) {
        switch convertionType {
        case .jsonToYaml:
            self.cell.codeInput.language = .javascript
            self.cell.codeOutput.language = .yaml
        case .yamlToJson:
            self.cell.codeInput.language = .yaml
            self.cell.codeOutput.language = .javascript
        }
        
        self.process(formatStyle: formatStyle, code: code)
    }
    
    private func process(formatStyle: FormatStyle, code: String) {
        switch convertionType {
        case .jsonToYaml:
            if let yaml = self.convertJsonToYaml(code: code, formatStyle: formatStyle) {
                self.cell.codeOutput.code = yaml
            }
        case .yamlToJson:
            if let json = self.convertYamlToJson(code: code, formatStyle: formatStyle) {
                self.cell.codeOutput.code = json
            }
        }
    }
    
    private func convertYamlToJson(code: String, formatStyle: FormatStyle) -> String? {
        if code.isEmpty { return "" }
        guard let object = try? Yams.load(yaml: code) else {
            return nil
        }
        
        var options = JSONSerialization.WritingOptions()
        if formatStyle == .pretty { options.insert(.prettyPrinted) }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: options) else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    private func convertJsonToYaml(code: String, formatStyle: FormatStyle) -> String? {
        if code.isEmpty { return "" }
        guard let object = try? JSONSerialization.jsonObject(with: code.data(using: .utf8)!, options: [.mutableContainers]) else {
            return nil
        }
        
        let swiftObject = convertNSObject(object)
        
        return try? Yams.dump(object: swiftObject)
    }
    
    private func convertNSObject(_ object: Any) -> Any {
        if let object = object as? NSDictionary {
            return (object as! [String: Any]).mapValues{ convertNSObject($0) }
        }
        if let object = object as? NSArray { return (object as! [Any]).map{ convertNSObject($0) } }
        if let object = object as? NSString { return object as String }
        if let object = object as? NSNumber {
            switch CFNumberGetType(object) {
            case .cgFloatType, .floatType, .doubleType, .float32Type, .float64Type: return object.doubleValue
            case .longLongType, .longType, .shortType, .intType, .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .cfIndexType, .nsIntegerType: return object.intValue
            case .charType: return object.boolValue
            @unknown default: return object.intValue
            }
        }
        
        return object
    }
    
    private func processURL(_ url: URL) {
        guard let code = try? String(contentsOf: url) else { return NSSound.beep() }
        self.code = code
    }
}

private enum JsonConvertionType: String, TextItem {
    case jsonToYaml = "Json to Yaml"
    case yamlToJson = "Yaml to Json"
    
    var title: String { rawValue }
}

private enum FormatStyle: String, TextItem {
    case pretty = "Pretty"
    case minified = "Minified"
    
    var title: String { rawValue }
}

final private class JSONYamlConverterView: ToolPage {
    
    let convertionPicker = EnumPopupButton<JsonConvertionType>()
    let formatStylePicker = EnumPopupButton<FormatStyle>()
    
    let codeInput = CodeTextView(language: .javascript)
    let codeOutput = CodeTextView(language: .yaml)
    let pasteButton = PasteSectionButton()
    let openButton = OpenSectionButton()
    let clearButton = SectionButton(image: R.Image.clear)
    let copyButton = CopySectionButton()
        
    private lazy var convertionArea = ControlArea(icon: R.Image.spacing, title: "Convertion", message: "Select which convertion mode you want to use", control: convertionPicker)
    private lazy var formatStyleArea = ControlArea(icon: R.Image.format, title: "Format", control: formatStylePicker)
    
    private lazy var configurationSection = ControlSection(title: "Configuration", items: [convertionArea, formatStyleArea])
    
    private lazy var inputSection = ControlSection(title: "Input", items: [codeInput], toolbarItems: [pasteButton, openButton, clearButton])
    private lazy var outputSection = ControlSection(title: "Output", items: [codeOutput], toolbarItems: [copyButton])
    
    override func onAwake() {
        self.title = "JSON <> Yaml Converter"
        
        self.addSection(configurationSection)
        self.addSection2(inputSection, outputSection)
        
        self.codeInput.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
    }
}
