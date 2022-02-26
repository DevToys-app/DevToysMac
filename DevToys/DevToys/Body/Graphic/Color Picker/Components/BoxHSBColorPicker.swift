//
//  BoxColorPicker.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class BoxHSBColorPicker: NSLoadStackView {
    
    var color = Color.default {
        didSet {
            self.colorBox.color = color
            self.hueBar.color = color
            self.opacityBar.color = color
        }
    }
    
    var colorPublisher: AnyPublisher<Color, Never> {
        let p1 = colorBox.valuePublisher.map{ self.color.withSB($0.saturation, $0.brightness) }
        let p2 = hueBar.huePublisher.map{ self.color.withHue($0) }
        let p3 = opacityBar.opacityPublisher.map{ v in self.color <=> { $0.alpha = v } }
        
        return p1.merge(with: p2, p3).eraseToAnyPublisher()
    }
    
    let colorBox = ColorBoxView()
    let hueBar = HueBarView()
    let opacityBar = OpacityBarView()
    
    override func onAwake() {
        self.orientation = .horizontal
        self.spacing = 16
        self.addArrangedSubview(colorBox)
        self.addArrangedSubview(hueBar)
        self.addArrangedSubview(opacityBar)
        self.snp.makeConstraints{ make in
            make.height.equalTo(200)
        }
    }
}
