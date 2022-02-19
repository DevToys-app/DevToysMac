//
//  ColorPickerView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil


final class ColorPickerViewController: NSViewController {
    private let cell = ColorPickerView()
    
    @Observable var color: Color = .default
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$color
            .sink{[unowned self] in
                cell.colorBox.color = $0
                cell.hueBar.color = $0
                cell.opacityBar.color = $0
            }
            .store(in: &objectBag)
        
        self.cell.colorBox.valuePublisher
            .sink{[unowned self] in self.color = Color(hue: color.hue, saturation: $0.saturation, brightness: $0.brightness, alpha: color.alpha) }.store(in: &objectBag)
        self.cell.hueBar.huePublisher
            .sink{[unowned self] in self.color.hue = $0 }.store(in: &objectBag)
        self.cell.opacityBar.opacityPublisher
            .sink{[unowned self] in self.color.alpha = $0 }.store(in: &objectBag)
    }
}

final class ColorPickerView: Page {
    let colorBox = ColorBoxView()
    let hueBar = HueBarView()
    let opacityBar = OpacityBarView()
    
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
    }
}


