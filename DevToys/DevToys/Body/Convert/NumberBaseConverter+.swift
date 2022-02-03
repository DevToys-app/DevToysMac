//
//  NumberBaseConverter.swift
//  DevToys
//
//  Created by yuki on 2022/01/30.
//

import CoreUtil

final class NumberBaseConverterViewController: ToolPageViewController {
    private let cell = NumberBaseConverterView()
    
    @RestorableState("numbase.format") private var formatNumber = true
    @RestorableState("numbase.2") private var value2 = "1 0101 1010 0101 0011"
    @RestorableState("numbase.10") private var value10 = "88,659"
    @RestorableState("numbase.8") private var value8 = "255 123"
    @RestorableState("numbase.16") private var value16 = "1 5A53"
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$value2
            .sink{[unowned self] in cell.binarySection.string = $0 }.store(in: &objectBag)
        self.$value8
            .sink{[unowned self] in cell.octalSection.string = $0 }.store(in: &objectBag)
        self.$value10
            .sink{[unowned self] in cell.decimalSection.string = $0 }.store(in: &objectBag)
        self.$value16
            .sink{[unowned self] in cell.hexSection.string = $0 }.store(in: &objectBag)
        self.$formatNumber
            .sink{[unowned self] in cell.formatSwitch.state = $0 ? .on : .off }.store(in: &objectBag)
        
        self.cell.binarySection.stringPublisher
            .sink{[unowned self] in self.updateValue(string: $0, inputRadix: 2) }.store(in: &objectBag)
        self.cell.octalSection.stringPublisher
            .sink{[unowned self] in self.updateValue(string: $0, inputRadix: 8) }.store(in: &objectBag)
        self.cell.decimalSection.stringPublisher
            .sink{[unowned self] in self.updateValue(string: $0, inputRadix: 10) }.store(in: &objectBag)
        self.cell.hexSection.stringPublisher
            .sink{[unowned self] in self.updateValue(string: $0, inputRadix: 16) }.store(in: &objectBag)
        self.cell.formatSwitch.actionPublisher.map{[unowned self] in self.cell.formatSwitch.state == .on }
            .sink{[unowned self] in self.formatNumber = $0; updateFormat() }.store(in: &objectBag)
    }
    
    private func updateFormat() {
        self.updateValue(string: value10, inputRadix: 10)
    }
    private func updateValue(string: String, inputRadix: Int) {
        let value = Int(string.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ""), radix: inputRadix)
        self.value2 = self.convertBinary(value, format: self.formatNumber)
        self.value8 = self.convertOctal(value, format: self.formatNumber)
        self.value10 = self.convertDecimal(value, format: self.formatNumber)
        self.value16 = self.convertHex(value, format: self.formatNumber)
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
}

final private class NumberBaseConverterView: Page {
    let formatSwitch = NSSwitch()
    
    let decimalSection = TextFieldSection(title: "Decimal")
    let hexSection = TextFieldSection(title: "Hexdecimal")
    let octalSection = TextFieldSection(title: "Octal")
    let binarySection = TextFieldSection(title: "Binary")
    
    private lazy var formatNumberArea = Area(icon: R.Image.format, title: "Format number", control: formatSwitch)
    
    private lazy var configurationSection = Section(title: "Configuration", items: [formatNumberArea])
    
    override func onAwake() {
        self.title = "Number Base Converter"
        
        self.addSection(configurationSection)
        
        self.addSection(decimalSection)
        self.addSection(hexSection)
        self.addSection(octalSection)
        self.addSection(binarySection)
    }
}
