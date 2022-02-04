//
//  DatePicker.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

final class DatePicker: NSLoadView {
    
    var date: Date {
        get { datePicker.dateValue } set { datePicker.dateValue = newValue }
    }
    var datePublisher: AnyPublisher<Date, Never> {
        datePicker.actionPublisher.map{ self.datePicker.dateValue }.eraseToAnyPublisher()
    }

    private let datePicker = NSDatePicker()
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func onAwake() {
        
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
    
        self.addSubview(datePicker)
        self.datePicker.isBezeled = false
        self.datePicker.font = .systemFont(ofSize: 14)
        self.datePicker.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(4)
        }
    }
}
