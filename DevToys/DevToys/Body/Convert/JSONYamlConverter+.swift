//
//  JSONYamlConverter+.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil
import Yams
import SwiftJSONFormatter

final class JSONYamlConverterViewController: ToolPageViewController {
    private let cell = JSONYamlConverterView()
    
    @RestorableState("jy.format") private var formatStyle: FormatStyle = .pretty
    @RestorableState("jy.json") private var jsonCode = defaultJsonCode
    @RestorableState("jy.yaml") private var yamlCode = defaultYamlCode
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$jsonCode
            .sink{[unowned self] in self.cell.jsonSection.string = $0 }.store(in: &objectBag)
        self.$yamlCode
            .sink{[unowned self] in self.cell.yamlSection.string = $0 }.store(in: &objectBag)
        self.$formatStyle
            .sink{[unowned self] in self.cell.formatStylePicker.selectedItem = $0 }.store(in: &objectBag)
     
        self.cell.formatStylePicker.itemPublisher
            .sink{[unowned self] in self.formatStyle = $0 }.store(in: &objectBag)
        self.cell.jsonSection.stringPublisher
            .sink{[unowned self] in
                self.jsonCode = $0
                if let yamlCode = convertJsonToYaml(code: $0, formatStyle: self.formatStyle) {
                    self.yamlCode = yamlCode
                }
            }
            .store(in: &objectBag)
        self.cell.yamlSection.stringPublisher
            .sink{[unowned self] in
                self.yamlCode = $0
                if let jsonCode = convertYamlToJson(code: $0, formatStyle: self.formatStyle) { self.jsonCode = jsonCode }
            }
            .store(in: &objectBag)
    }
    
    private func convertYamlToJson(code: String, formatStyle: FormatStyle) -> String? {
        if code.isEmpty { return "" }
        guard let object = try? Yams.load(yaml: code) else { return nil }
        
        var options = JSONSerialization.WritingOptions()
        options.insert(.sortedKeys)
        if formatStyle == .pretty { options.insert(.prettyPrinted) }
        return try? objc_try {
            guard let data = try? JSONSerialization.data(withJSONObject: object, options: options) else { return nil }
            let json = String(data: data, encoding: .utf8)!
            
            return SwiftJSONFormatter.beautify(json, indent: "    ")
        }
    }
    
    private func convertJsonToYaml(code: String, formatStyle: FormatStyle) -> String? {
        if code.isEmpty { return "" }
        return objc_try({
            guard let object = try? JSONSerialization.jsonObject(with: code.data(using: .utf8)!) else {
                return nil
            }
            
            let swiftObject = convertNSObject(object)
            
            return try? Yams.dump(object: swiftObject)
        }, catch: {_ in
            return nil
        })
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
}

private enum FormatStyle: String, TextItem {
    case pretty = "Pretty"
    case minified = "Minified"
    
    var title: String { rawValue }
}

final private class JSONYamlConverterView: ToolPage {
    
    let formatStylePicker = EnumPopupButton<FormatStyle>()
    
    let jsonSection = CodeViewSection(title: "JSON", options: .all, language: .javascript)
    let yamlSection = CodeViewSection(title: "Yaml", options: .all, language: .yaml)
    
    private lazy var formatStyleArea = ControlArea(icon: R.Image.format, title: "Format", control: formatStylePicker)
    private lazy var configurationSection = ControlSection(title: "Configuration", items: [formatStyleArea])
    private lazy var ioStack = self.addSection2(jsonSection, yamlSection)
    
    override func layout() {
        super.layout()
        
        self.ioStack.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 160))
        }
    }
    
    override func onAwake() {
        self.title = "JSON <> Yaml Converter"
        
        self.addSection(configurationSection)
    }
}

private let defaultJsonCode = """
{
    "type" : "members",
    "members" : [
        {
            "name" : "Alice",
            "age" : 16
        },
        {
            "name" : "Bob",
            "age" : 24
        }
    ],
}
"""

private let defaultYamlCode = """
members:
- age: 16
  name: Alice
- age: 24
  name: Bob
type: members

"""
