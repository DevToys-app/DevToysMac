//
//  NumberBaseConverter.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class NumberBaseConverterViewController: NSViewController {
    private let cell = NumberBaseConverterView()
    
    @RestorableState("numbase.format") private var formatNumber = true
    @RestorableState("numbase.type") private var inputType = InputType.decimal
    @Observable private var inputValue: Int? = nil
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.cell.inputTypePicker.itemPublisher
            .sink{[unowned self] in self.inputType = $0 }.store(in: &objectBag)
        self.cell.formatSwitch.actionPublisher
            .sink{[unowned self] in self.formatNumber = self.cell.formatSwitch.state == NSControl.StateValue.on }.store(in: &objectBag)
        self.cell.inputTextField.changeStringPublisher.combineLatest($inputType)
            .sink{[unowned self] in processValue($0, inputType: $1) }.store(in: &objectBag)
        
        self.$formatNumber
            .sink{[unowned self] in self.cell.formatSwitch.state = $0 ? .on : .off }.store(in: &objectBag)
        self.$inputType
            .sink{[unowned self] in self.cell.inputTypePicker.selectedItem = $0 }.store(in: &objectBag)
        
        self.$inputValue.combineLatest($formatNumber)
            .sink{[unowned self] in self.cell.hexTextField.string = convertHex($0, format: $1) }.store(in: &objectBag)
        self.$inputValue.combineLatest($formatNumber)
            .sink{[unowned self] in self.cell.decimalTextField.string = convertDecimal($0, format: $1) }.store(in: &objectBag)
        self.$inputValue.combineLatest($formatNumber)
            .sink{[unowned self] in self.cell.octalTextField.string = convertOctal($0, format: $1) }.store(in: &objectBag)
        self.$inputValue.combineLatest($formatNumber)
            .sink{[unowned self] in self.cell.binaryTextField.string = convertBinary($0, format: $1) }.store(in: &objectBag)
    }
    
    private func convertHex(_ value: Int?, format: Bool) -> String {
        guard let value = value else { return "0" }
        
        let string = String(value, radix: 16, uppercase: true)
        if format { return splitString(string, split: 4, separator: " ") } else {  return string }
    }
    private func convertDecimal(_ value: Int?, format: Bool) -> String {
        guard let value = value else { return "0" }
        
        let string = String(value, radix: 10, uppercase: true)
        if format { return splitString(string, split: 3, separator: ",") } else {  return string }
    }
    private func convertOctal(_ value: Int?, format: Bool) -> String {
        guard let value = value else { return "0" }
        
        let string = String(value, radix: 8, uppercase: true)
        if format { return splitString(string, split: 3, separator: " ") } else {  return string }
    }
    private func convertBinary(_ value: Int?, format: Bool) -> String {
        guard let value = value else { return "0" }
        
        let string = String(value, radix: 2, uppercase: true)
        if format { return splitString(string, split: 4, separator: " ") } else {  return string }
    }
    
    private func splitString(_ string: String, split: Int, separator: String) -> String {
        var result = ""
        var count = string.count
        
        for c in string {
            count -= 1
            result.append(c)
            if count != 0, count % split == 0 { result.append(separator) }
        }
        
        return result
    }
    
    private func convert(_ value: Int?, radix: Int) -> String {
        guard let value = value else { return "0" }
        return String(value, radix: radix, uppercase: true)
    }
    
    private func processValue(_ value: String, inputType: InputType) {
        switch inputType {
        case .binary: self.inputValue = Int(value, radix: 2)
        case .octal: self.inputValue = Int(value, radix: 8)
        case .decimal: self.inputValue = Int(value, radix: 10)
        case .hexdecimal: self.inputValue = Int(value, radix: 16)
        }
    }
}

private enum InputType: String, TextItem {
    case binary = "Binary"
    case decimal = "Decimal"
    case octal = "Octal"
    case hexdecimal = "Hexadecimal"
    
    var title: String { rawValue }
}

final private class NumberBaseConverterView: ToolPage {
    let formatSwitch = NSSwitch()
    let inputTypePicker = EnumPopupButton<InputType>()
    
    let pasteButton = PasteSectionButton()
    let inputTextField = TextField(showCopyButton: false)
    
    let hexTextField = TextField()
    let decimalTextField = TextField()
    let octalTextField = TextField()
    let binaryTextField = TextField()
    
    private lazy var formatNumberArea = ControlArea(icon: R.Image.format, title: "Format number", control: formatSwitch)
    private lazy var inputTypeArea = ControlArea(icon: R.Image.convert, title: "Input type", message: "Select which input type you want to use", control: inputTypePicker)
    
    private lazy var configurationSection = ControlSection(title: "Configuration", items: [formatNumberArea, inputTypeArea])
    private lazy var inputSection = ControlSection(title: "Input", items: [inputTextField], toolbarItems: [pasteButton])
    private lazy var hexSection = ControlSection(title: "Hexadecimal", items: [hexTextField]) => { $0.minTitle = true }
    private lazy var decimalSection = ControlSection(title: "Decimal", items: [decimalTextField]) => { $0.minTitle = true }
    private lazy var octalSection = ControlSection(title: "Octal", items: [octalTextField]) => { $0.minTitle = true }
    private lazy var binarySection = ControlSection(title: "Binary", items: [binaryTextField]) => { $0.minTitle = true }
    
    override func onAwake() {
        self.title = "Number Base Converter"
        
        self.addSection(configurationSection)
        
        self.addSection(inputSection)
        self.addSection(hexSection)
        self.addSection(decimalSection)
        self.addSection(octalSection)
        self.addSection(binarySection)
        
        self.hexTextField.isEditable = false
        self.decimalTextField.isEditable = false
        self.octalTextField.isEditable = false
        self.binaryTextField.isEditable = false
        
        
    }
}
