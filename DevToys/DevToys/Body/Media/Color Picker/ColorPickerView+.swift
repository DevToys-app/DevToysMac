//
//  ColorPickerView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil


final class ColorPickerViewController: NSViewController {
    private let cell = ColorPickerView()
    
    @RestorableData("color") var color: Color = .default
    
    @Observable var hex3: String? = nil
    @Observable var hex6: String = "000000"
    @Observable var hex8: String = "00000000"
    
    @Observable var red: CGFloat = 0
    @Observable var green: CGFloat = 0
    @Observable var blue: CGFloat = 0
    
    @Observable var cyan: CGFloat = 0
    @Observable var magenta: CGFloat = 0
    @Observable var yellow: CGFloat = 0
    @Observable var key: CGFloat = 0
    
    override func loadView() { self.view = cell }
    
    private func updateComponents() {
        let (red, green, blue) = color.rgb
        let (cyan, magenta, yellow, key) = color.cmyk
        
        self.hex6 = String(format: "%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
        self.hex3 = self.makeHex3(hex6: hex6)
        self.hex8 = String(format: "%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(color.alpha * 255))
        
        self.red = round(red * 255)
        self.green = round(green * 255)
        self.blue = round(blue * 255)
        
        self.cyan = round(cyan * 100)
        self.magenta = round(magenta * 100)
        self.yellow = round(yellow * 100)
        self.key = round(key * 100)
    }
    
    private func makeHex3(hex6: String) -> String? {
        guard hex6.count == 6 else { return nil }
        let charactors = hex6.map{ $0 }
        guard charactors[0] == charactors[1], charactors[2] == charactors[3], charactors[4] == charactors[5] else { return nil }
        return "\(charactors[0])\(charactors[2])\(charactors[4])"
    }
    
    override func viewDidLoad() {
        self.$hex3.sink{[unowned self] in self.cell.hex3TextField.string = $0 ?? "" }.store(in: &objectBag)
        self.$hex6.sink{[unowned self] in self.cell.hex6TextField.string = $0 }.store(in: &objectBag)
        self.$hex8.sink{[unowned self] in self.cell.hex8TextField.string = $0 }.store(in: &objectBag)
        
        self.$red.sink{[unowned self] in self.cell.redField.value = $0 }.store(in: &objectBag)
        self.$green.sink{[unowned self] in self.cell.greenField.value = $0 }.store(in: &objectBag)
        self.$blue.sink{[unowned self] in self.cell.blueField.value = $0 }.store(in: &objectBag)
        
        self.$cyan.sink{[unowned self] in self.cell.cyanField.value = $0 }.store(in: &objectBag)
        self.$magenta.sink{[unowned self] in self.cell.magentaField.value = $0 }.store(in: &objectBag)
        self.$yellow.sink{[unowned self] in self.cell.yellowField.value = $0 }.store(in: &objectBag)
        self.$key.sink{[unowned self] in self.cell.keyField.value = $0 }.store(in: &objectBag)
        
        self.$color
            .sink{[unowned self] in cell.colorBox.color = $0; cell.hueBar.color = $0; cell.opacityBar.color = $0 }.store(in: &objectBag)
        
        self.cell.hex3TextField.endEditingStringPublisher
            .sink{[unowned self] in self.color = Color(hex3: $0, alpha: color.alpha) ?? color; updateComponents() }.store(in: &objectBag)
        self.cell.hex6TextField.endEditingStringPublisher
            .sink{[unowned self] in self.color = Color(hex6: $0, alpha: color.alpha) ?? color; updateComponents() }.store(in: &objectBag)
        self.cell.hex8TextField.endEditingStringPublisher
            .sink{[unowned self] in self.color = Color(hex8: $0) ?? color; updateComponents() }.store(in: &objectBag)
        
        self.cell.colorBox.valuePublisher
            .sink{[unowned self] in self.color = self.color.withSB($0.saturation, $0.brightness); updateComponents() }.store(in: &objectBag)
        self.cell.hueBar.huePublisher
            .sink{[unowned self] in self.color.hue = $0; updateComponents() }.store(in: &objectBag)
        self.cell.opacityBar.opacityPublisher
            .sink{[unowned self] in self.color.alpha = $0; updateComponents() }.store(in: &objectBag)
        
        self.cell.redField.publisher
            .sink{[unowned self] in self.color = self.color.withRed($0/255); updateComponents() }.store(in: &objectBag)
        self.cell.greenField.publisher
            .sink{[unowned self] in self.color = self.color.withGreen($0/255); updateComponents() }.store(in: &objectBag)
        self.cell.blueField.publisher
            .sink{[unowned self] in self.color = self.color.withBlue($0/255); updateComponents() }.store(in: &objectBag)
        
        self.updateComponents()
    }
}

final private class ColorPickerView: Page {
    let colorBox = ColorBoxView()
    let hueBar = HueBarView()
    let opacityBar = OpacityBarView()
    let hex3TextField = TextField() => { $0.placeholder = "#XXX" }
    let hex6TextField = TextField() => { $0.placeholder = "#XXXXXX" }
    let hex8TextField = TextField() => { $0.placeholder = "#XXXXXXXX" }
        
    let redField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let greenField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let blueField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    
    let cyanField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let magentaField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let yellowField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let keyField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    
    override func onAwake() {
        self.addSection(NSStackView() => {
            $0.orientation = .horizontal
            $0.spacing = 16
            $0.addArrangedSubview(colorBox)
            $0.addArrangedSubview(hueBar)
            $0.addArrangedSubview(opacityBar)
            $0.snp.makeConstraints{ make in
                make.height.equalTo(200)
            }
        })
        
        self.addSection(Section(title: "Color Hex", orientation: .horizontal, items: [
            hex3TextField, hex6TextField, hex8TextField
        ]), fillWidth: false)
                
        self.addSection(Section(title: "RGB", orientation: .horizontal, items: [
            redField, greenField, blueField
        ]), fillWidth: false)
        
        self.addSection(Section(title: "CMYK", orientation: .horizontal, items: [
            cyanField, magentaField, yellowField, keyField
        ]), fillWidth: false)
    }
}

extension NumberField {
    var publisher: AnyPublisher<CGFloat, Never> {
        valuePublisher.map{ CGFloat($0.reduce(self.value.native)) }.eraseToAnyPublisher()
    }
}
