//
//  CircleBarsHSBColorPicker.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil


final class CircleBarsHSBColorPicker: NSLoadStackView {
    var color = Color.default {
        didSet {
            self.circleHueBar.color = color
            self.opacityBar.color = color
            self.saturationBar.color = color
            self.lightnessBar.color = color
        }
    }
    
    var colorPublisher: AnyPublisher<Color, Never> {
        let p2 = opacityBar.opacityPublisher.map{ v in self.color <=> { $0.alpha = v } }
        let p1 = circleHueBar.huePublisher.map{ self.color.withHue($0) }
        let p3 = saturationBar.saturationPublisher.map{ self.color.withSaturation($0) }
        let p4 = lightnessBar.lightnessPublisher.map{ self.color.withBrightness($0) }
        
        return p1.merge(with: p2, p3, p4).eraseToAnyPublisher()
    }
    
    let circleHueBar = CircleHueBarView()
    let saturationBar = SaturationBarView()
    let lightnessBar = BrightnessBarView()
    let opacityBar = OpacityBarView()
    
    override func onAwake() {
        self.orientation = .horizontal
        self.spacing = 16
        self.addArrangedSubview(circleHueBar)
        self.addArrangedSubview(saturationBar)
        self.addArrangedSubview(lightnessBar)
        self.addArrangedSubview(opacityBar)
        self.snp.makeConstraints{ make in
            make.height.equalTo(250)
        }
    }
}

