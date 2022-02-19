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
    
    @Observable var hex3: String = "000"
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
        
        self.hex6 = String(format: "%2X%2X%2X", red, green, blue)
        
        self.red = round(red * 225)
        self.green = round(green * 225)
        self.blue = round(blue * 225)
        
        self.cyan = round(cyan * 100)
        self.magenta = round(magenta * 100)
        self.yellow = round(yellow * 100)
        self.key = round(key * 100)
    }
    
    override func viewDidLoad() {
        self.$hex6.sink{[unowned self] in self.cell.hex6TextField.string = $0 }.store(in: &objectBag)
        
        self.$red.sink{[unowned self] in self.cell.redField.value = $0 }.store(in: &objectBag)
        self.$green.sink{[unowned self] in self.cell.greenField.value = $0 }.store(in: &objectBag)
        self.$blue.sink{[unowned self] in self.cell.blueField.value = $0 }.store(in: &objectBag)
        
        self.$cyan.sink{[unowned self] in self.cell.cyanField.value = $0 }.store(in: &objectBag)
        self.$magenta.sink{[unowned self] in self.cell.magentaField.value = $0 }.store(in: &objectBag)
        self.$yellow.sink{[unowned self] in self.cell.yellowField.value = $0 }.store(in: &objectBag)
        self.$key.sink{[unowned self] in self.cell.keyField.value = $0 }.store(in: &objectBag)
        
        self.$color
            .sink{[unowned self] in
                cell.colorBox.color = $0
                cell.hueBar.color = $0
                cell.opacityBar.color = $0
            }
            .store(in: &objectBag)
        
        self.cell.colorBox.valuePublisher
            .sink{[unowned self] in self.color = Color(hue: color.hue, saturation: $0.saturation, brightness: $0.brightness, alpha: color.alpha); updateComponents() }.store(in: &objectBag)
        self.cell.hueBar.huePublisher
            .sink{[unowned self] in self.color.hue = $0; updateComponents() }.store(in: &objectBag)
        self.cell.opacityBar.opacityPublisher
            .sink{[unowned self] in self.color.alpha = $0; updateComponents() }.store(in: &objectBag)
        
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
