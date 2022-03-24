//
//  ColorPickerView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil


final class ColorPickerViewController: NSViewController {
    private let cell = ColorPickerView()
    
    @RestorableData("colorpick.color") var color: Color = Color(hue: 0.48, saturation: 0.9, brightness: 0.9, alpha: 1)
    @RestorableState("colorpick.pickertype") var pickerType: ColorPickerType = .hsbBox
    @RestorableState("colorpick.copyType") var copyType: ColorCopyType = .webRGBA
    
    @Observable var hex3: String? = nil
    @Observable var hex6: String = ""
    @Observable var hex8: String = ""
    
    @Observable var red: CGFloat = 0
    @Observable var green: CGFloat = 0
    @Observable var blue: CGFloat = 0
    
    @Observable var cyan: CGFloat = 0
    @Observable var magenta: CGFloat = 0
    @Observable var yellow: CGFloat = 0
    @Observable var key: CGFloat = 0
    @Observable var copyValue = ""
    
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
        
        switch copyType {
        case .components: break
        case .iosUIColor: self.copyValue = "UIColor(red: \(red.cf), green: \(green.cf), blue: \(blue.cf), alpha: \(color.alpha.cf))"
        case .macNSColor: self.copyValue = "NSColor(red: \(red.cf), green: \(green.cf), blue: \(blue.cf), alpha: \(color.alpha.cf))"
        case .swiftuiRGBColor: self.copyValue = "Color(red: \(red.cf), green: \(green.cf), blue: \(blue.cf), opacity: \(color.alpha.cf))"
        case .swiftuiHSBColor: self.copyValue = "Color(hue: \(color.hue.cf), saturation: \(color.saturation.cf), brightness: \(color.brightness.cf), opacity: \(color.alpha.cf))"
        case .androidARGB:
            if color.alpha == 1 {
                self.copyValue = "Color.rgb(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)))"
            } else {
                self.copyValue = "Color.argb(\(Int(color.alpha * 255)), \(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)))"
            }
        case .androidHEX:
            if color.alpha == 1 {
                self.copyValue = "Color.parseColor(\"#\(self.hex6)\")"
            } else {
                self.copyValue = "Color.parseColor(\"#\(self.hex8)\")"
            }
        case .androidXML:
            if color.alpha == 1 {
                self.copyValue = "<color name=\"color\">#\(self.hex6)</color>"
            } else {
                self.copyValue = "<color name=\"color\">#\(self.hex8)</color>"
            }
        case .webHEX:
            if color.alpha == 1 {
                self.copyValue = "#\(self.hex6)"
            } else {
                self.copyValue = "#\(self.hex8)"
            }
        case .webRGBA:
            if color.alpha == 1 {
                self.copyValue = "rgb(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)))"
            } else {
                self.copyValue = "rgba(\(Int(red * 255)), \(Int(green * 255)), \(Int(blue * 255)), \(color.alpha.formattedString()))"
            }
        case .webHSLA:
            let (h, s, l) = color.hsl
            if color.alpha == 1 {
                self.copyValue = "hsl(\(Int(h * 360))deg, \(Int(s * 100))%, \(Int(l * 100))%)"
            } else {
                self.copyValue = "hsla(\(Int(h * 360))deg, \(Int(s * 100))%, \(Int(l * 100))%, \(color.alpha.formattedString()))"
            }
        }
    }
    
    private func makeHex3(hex6: String) -> String? {
        guard hex6.count == 6 else { return nil }
        let charactors = hex6.map{ $0 }
        guard charactors[0] == charactors[1], charactors[2] == charactors[3], charactors[4] == charactors[5] else { return nil }
        return "\(charactors[0])\(charactors[2])\(charactors[4])"
    }
    
    private func pickColor() {
        ACPixelPicker().show()
            .peek{[self] in self.color = $0; updateComponents() }
            .catchCancel{}
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
        self.$pickerType.sink{[unowned self] in self.cell.pickerTypePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$copyType.sink{[unowned self] in self.cell.colorCopyTypePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$copyValue.sink{[unowned self] in self.cell.textCopyField.string = $0 }.store(in: &objectBag)
        
        self.$pickerType
            .map{[unowned self] type -> NSView in
                switch type {
                case .hsbBox: return self.cell.boxHSBPicker
                case .hsbCircle: return self.cell.circleBoxHSBPicker
                case .hsbCircleAndBars: return self.cell.circleBarsHSBPicker
                }
            }
            .sink{[unowned self] in self.cell.pickerPlaceholder.contentView = $0 }
            .store(in: &objectBag)
        
        self.$copyType
            .map{[unowned self] type -> NSView in
                switch type {
                case .components: return cell.paramatorsStack
                default: return cell.textCopyField
                }
            }
            .sink{[unowned self] in self.cell.colorCopyPlaceholder.contentView = $0 }
            .store(in: &objectBag)
        
        self.$color
            .sink{[unowned self] in
                cell.boxHSBPicker.color = $0
                cell.circleBoxHSBPicker.color = $0
                cell.circleBarsHSBPicker.color = $0
                cell.colorSampleView.color = $0.cgColor
                cell.alphaField.value = round($0.alpha * 100)
            }
            .store(in: &objectBag)
        
        self.cell.pickerTypePicker.itemPublisher
            .sink{[unowned self] in self.pickerType = $0 }.store(in: &objectBag)
        self.cell.colorCopyTypePicker.itemPublisher
            .sink{[unowned self] in self.copyType = $0; updateComponents() }.store(in: &objectBag)
        self.cell.hex3TextField.endEditingStringPublisher
            .sink{[unowned self] in self.color = Color(hex3: $0, alpha: color.alpha) ?? color; updateComponents() }.store(in: &objectBag)
        self.cell.hex6TextField.endEditingStringPublisher
            .sink{[unowned self] in self.color = Color(hex6: $0, alpha: color.alpha) ?? color; updateComponents() }.store(in: &objectBag)
        self.cell.hex8TextField.endEditingStringPublisher
            .sink{[unowned self] in self.color = Color(hex8: $0) ?? color; updateComponents() }.store(in: &objectBag)
        
        self.cell.boxHSBPicker.colorPublisher.merge(with: cell.circleBoxHSBPicker.colorPublisher, cell.circleBarsHSBPicker.colorPublisher)
            .sink{[unowned self] in self.color = $0; updateComponents() }.store(in: &objectBag)
        
        self.cell.alphaField.publisher
            .sink{[unowned self] in self.color = self.color.withAlpha($0/100); updateComponents() }.store(in: &objectBag)
        self.cell.redField.publisher
            .sink{[unowned self] in self.color = self.color.withRed($0/255); updateComponents() }.store(in: &objectBag)
        self.cell.greenField.publisher
            .sink{[unowned self] in self.color = self.color.withGreen($0/255); updateComponents() }.store(in: &objectBag)
        self.cell.blueField.publisher
            .sink{[unowned self] in self.color = self.color.withBlue($0/255); updateComponents() }.store(in: &objectBag)
        
        self.cell.pixelPickerButton.actionPublisher
            .sink{[unowned self] in self.pickColor() }.store(in: &objectBag)
        
        self.updateComponents()
    }
}

enum ColorPickerType: String, TextItem {
    case hsbBox = "HSB Box"
    case hsbCircle = "HSB Circle"
    case hsbCircleAndBars = "HSB Circle and Bars"
    
    var title: String { rawValue.localized() }
}

enum ColorCopyType: String, TextItem {
    case components = "Components"
    case iosUIColor = "iOS UIColor"
    case macNSColor = "mac NSColor"
    case swiftuiHSBColor = "SwiftUI HSB Color"
    case swiftuiRGBColor = "SwiftUI RGB Color"
    case androidARGB = "Android RGB"
    case androidHEX = "Android HEX"
    case androidXML = "Android XML"
    case webHEX = "Web HEX"
    case webRGBA = "Web RGB"
    case webHSLA = "Web HSL"
    
    var title: String { rawValue }
}

final private class ColorPickerView: Page {
    let pickerTypePicker = EnumPopupButton<ColorPickerType>()
    
    let boxHSBPicker = BoxHSBColorPicker()
    let circleBoxHSBPicker = CircleBoxHSBColorPicker()
    let circleBarsHSBPicker = CircleBarsHSBColorPicker()
    
    let pickerPlaceholder = NSPlaceholderView()
    
    let colorSampleView = ColorSampleView()
    let pixelPickerButton = SectionButton(title: "Pick Color", image: R.Image.spuit)
    let alphaField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    
    let colorCopyTypePicker = EnumPopupButton<ColorCopyType>()
    let colorCopyPlaceholder = NSPlaceholderView()
    
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
    
    let hueField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let saturationField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    let brightnessField = NumberField() => { $0.snp.makeConstraints{ make in make.width.equalTo(100) } }
    
    let textCopyField = TextField()
    
    lazy var paramatorsStack = NSStackView() => { paramatorsStack in
        paramatorsStack.alignment = .top
        paramatorsStack.addArrangedSubview(Section(title: "RGB", orientation: .vertical, items: [
            redField, greenField, blueField
        ]))
        paramatorsStack.addArrangedSubview(Section(title: "HSB", orientation: .vertical, items: [
            hueField, saturationField, brightnessField
        ]))
        paramatorsStack.addArrangedSubview(Section(title: "CMYK", orientation: .vertical, items: [
            cyanField, magentaField, yellowField, keyField
        ]))
    }
    
    override func onAwake() {
        self.addSection(Area(icon: R.Image.settings, title: "Picker Type".localized(), control: pickerTypePicker))
        self.pickerPlaceholder.contentView = circleBarsHSBPicker
        self.addSection(pickerPlaceholder)
        
        let componentsStack = NSStackView()
        componentsStack.orientation = .horizontal
        componentsStack.addArrangedSubview(colorSampleView)
        componentsStack.addArrangedSubview(pixelPickerButton)
        componentsStack.addArrangedSubview(NSView())
        componentsStack.addArrangedSubview(alphaField)
        
        self.addSection(componentsStack)
        
        self.addSection(Section(title: "Color Hex".localized(), orientation: .horizontal, fillWidth: false, items: [
            hex3TextField, hex6TextField, hex8TextField
        ]))
                
        self.addSection(Section(title: "Color Copy".localized(), items: [
            Area(icon: R.Image.copy, title: "Color Copy Type".localized(), control: colorCopyTypePicker),
            self.colorCopyPlaceholder
        ]))

        self.textCopyField.font = .monospacedSystemFont(ofSize: R.Size.controlTitleFontSize, weight: .regular)
    }
}

extension NumberField {
    var publisher: AnyPublisher<CGFloat, Never> {
        valuePublisher.map{ CGFloat($0.reduce(self.value.native)) }.eraseToAnyPublisher()
    }
}


extension CGFloat {
    private static let numberFormatter = NumberFormatter() => {
        $0.maximumFractionDigits = 2
        $0.minimumFractionDigits = 2
    }
    fileprivate var cf: String {
        Self.numberFormatter.string(from: NSNumber(value: native)) ?? "0"
    }
}
