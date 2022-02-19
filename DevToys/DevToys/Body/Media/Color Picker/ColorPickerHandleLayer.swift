//
//  ColorPickerHandleLayer.swift
//  DevToys
//
//  Created by yuki on 2022/02/19.
//

import CoreUtil

final class ColorPickerHandleLayer: CALoadLayer {
    
    var color: CGColor = .white {
        didSet { colorLayer.backgroundColor = color }
    }
    
    private let colorLayer = CALayer.animationDisabled()
    
    override func onAwake() {
        self.frame.size = [25, 25]
        self.areAnimationsEnabled = false
        self.cornerRadius = 25/2
        self.borderWidth = 2
        self.borderColor = .white
        self.backgroundColor = R.Color.transparentBackground.cgColor
        
        self.shadowOpacity = 0.2
        self.shadowOffset = .zero
        self.shadowRadius = 1
        
        self.addSublayer(colorLayer)
        
        let colorLayerRect = bounds.slimmed(by: 1.5)
        self.colorLayer.frame = colorLayerRect
        self.colorLayer.cornerRadius = colorLayerRect.height/2
        self.colorLayer.backgroundColor = .white
    }
}
