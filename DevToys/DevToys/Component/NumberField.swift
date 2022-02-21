//
//  NumberField.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil
import CoreGraphics

final class NumberField: NSLoadView {
    
    var value: CGFloat = 0 {
        didSet { textField.stringValue = value.formattedString() }
    }
    var valuePublisher: AnyPublisher<Delta<Double>, Never> {
        self.valueSubject.eraseToAnyPublisher()
    }
    var isEnabled: Bool {
        get { textField.isEnabled } set { textField.isEnabled = newValue }
    }
    var showStepper = true {
        didSet {
            self.stepper.isHidden = !showStepper
        }
    }
        
    private let stepper = NumberFieldStepper()
    private let textField = CustomFocusRingTextField()
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    private let valueSubject = PassthroughSubject<Delta<Double>, Never>()
    
    convenience init(autoWidth: Void) {
        self.init(width: 100)
    }
    
    convenience init(width: CGFloat) {
        self.init()
        self.snp.makeConstraints{ make in
            make.width.equalTo(width)
        }
    }
    
    override func layout() {
        self.backgroundLayer.frame = bounds
        let textFieldFrame = CGRect(originX: 8, centerY: bounds.midY, size: [bounds.width - 28, textField.intrinsicContentSize.height])
        
        let focusRingBounds = CGRect(origin: bounds.origin - textFieldFrame.origin, size: bounds.size)
        self.textField.focusRingBounds = focusRingBounds
        self.textField.frame = textFieldFrame
        super.layout()
    }
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    private func receiveString(_ string: String) {
        guard let value = Double(string) else {
            self.textField.stringValue = "0"
            return NSSound.beep()
        }
        self.valueSubject.send(.to(value))
    }
    
    override func onAwake() {
        self.snp.makeConstraints{ make in
            make.height.equalTo(R.Size.controlHeight)
        }
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        self.layer?.addSublayer(backgroundLayer)
        
        self.addSubview(stepper)
        self.stepper.snp.makeConstraints{ make in
            make.right.top.bottom.equalToSuperview()
        }
        
        self.addSubview(textField)
        self.textField.font = .systemFont(ofSize: 12)
        self.textField.stringValue = "0"
        
        self.textField.changeStringPublisher
            .sink{[unowned self] in self.receiveString($0) }.store(in: &objectBag)
        self.stepper.upPublisher
            .sink{[unowned self] in self.valueSubject.send(.by(1)) }.store(in: &objectBag)
        self.stepper.downPublisher
            .sink{[unowned self] in self.valueSubject.send(.by(-1)) }.store(in: &objectBag)
    }
}

final private class NumberFieldStepper: NSLoadControl {
    
    let upPublisher = PassthroughSubject<Void, Never>()
    let downPublisher = PassthroughSubject<Void, Never>()
    
    override var isFlipped: Bool { true }
    
    private let backgroundLayer = CALayer.animationDisabled()
    private let upBackgroundLayer = CALayer.animationDisabled()
    private let downBackgroundLayer = CALayer.animationDisabled()
    
    private let upImageView = NSImageView(image: R.Image.stepperUp)
    private let downImageView = NSImageView(image: R.Image.stepperDown)
    
    private var mouseDownPosition: Position? { didSet { needsDisplay = true } }
    private var highlightPosition: Position? { didSet { needsDisplay = true } }
    
    private enum Position { case up, down }
    
    private func position(of location: CGPoint) -> Position {
        if location.y > bounds.height/2 { return .down } else { return .up }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.mouseDownPosition = position(of: event.location(in: self))
        self.highlightPosition = position(of: event.location(in: self))
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
            timer.invalidate()
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                guard let mouseDownPosition = self.mouseDownPosition else { return timer.invalidate() }
                self.sendPosition(mouseDownPosition)
                NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
                
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if position(of: event.location(in: self)) == mouseDownPosition {
            self.highlightPosition = mouseDownPosition
        } else {
            self.highlightPosition = nil
        }
    }
    override func mouseUp(with event: NSEvent) {
        defer {
            self.highlightPosition = nil
            self.mouseDownPosition = nil
        }
        
        if let position = mouseDownPosition, self.position(of: event.location(in: self)) == position {
            sendPosition(position)
        }
    }
    
    private func sendPosition(_ position: Position) {
        switch position {
        case .up: upPublisher.send()
        case .down: downPublisher.send()
        }
    }
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
        self.upBackgroundLayer.frame = CGRect(origin: [0, 0], size: [bounds.width, bounds.height/2])
        self.downBackgroundLayer.frame = CGRect(origin: [0, bounds.height/2], size: [bounds.width, bounds.height/2])
        
        self.upImageView.frame.center = upBackgroundLayer.frame.center
        self.downImageView.frame.center = downBackgroundLayer.frame.center
    }
    
    override func updateLayer() {
        self.backgroundLayer.backgroundColor = R.Color.controlHighlightedBackgroundColor.cgColor
        
        if highlightPosition == .up {
            self.upBackgroundLayer.backgroundColor = R.Color.controlBackgroundColor.cgColor
        } else {
            self.upBackgroundLayer.backgroundColor = nil
        }
        
        if highlightPosition == .down {
            self.downBackgroundLayer.backgroundColor = R.Color.controlBackgroundColor.cgColor
        } else {
            self.downBackgroundLayer.backgroundColor = nil
        }
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        self.addSubview(upImageView)
        self.upImageView.frame.size = [10, 10]
        self.addSubview(downImageView)
        self.downImageView.frame.size = [10, 10]
        
        self.backgroundLayer.addSublayer(upBackgroundLayer)
        self.backgroundLayer.addSublayer(downBackgroundLayer)
        
        self.snp.makeConstraints{ make in
            make.width.equalTo(20)
        }
    }
}
