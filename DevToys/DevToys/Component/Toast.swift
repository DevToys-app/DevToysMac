//
//  ACToast.swift
//  AxComponents
//
//  Created by yuki on 2021/09/13.
//  Copyright © 2021 yuki. All rights reserved.
//

import Cocoa
import CoreUtil
import DequeModule
import UserNotifications

final public class Toast {
    public var message: String {
        get { toastWindow.toastView.message } set { toastWindow.toastView.message = newValue }
    }
    public var action: Action? {
        get { toastWindow.toastView.action } set { toastWindow.toastView.action = newValue }
    }
    public var color: NSColor? {
        get { toastWindow.toastView.color } set { toastWindow.toastView.color = newValue }
    }
    public var closeHandler: () -> () = {}
    
    public func addAttributeView(_ view: NSView, position: AttributeViewPosition) {
        toastWindow.toastView.addAttributeView(view, position: position)
    }
    
    public enum AttributeViewPosition {
        case left
        case right
    }
    
    private let toastWindow = ToastWindow()
    
    static var showingToast: Toast?
    static var pendingToasts = Deque<Toast>()
    
    public convenience init(message: String, action: Action? = nil, color: NSColor? = nil) {
        self.init()
        self.message = message
        self.action = action
        self.color = color
    }
    
    public func show(with duration: TimeInterval = 2) {
        self.show{ handler in
            DispatchQueue.main.asyncAfter(deadline: .now()+duration) {
                handler()
            }
        }
    }
    public func show(with closeHandler: (@escaping () -> ()) -> ()) {
        if Toast.showingToast != nil {
            Toast.pendingToasts.append(self)
            return
        }
        
        Toast.showingToast = self
        self.toastWindow.show(with: closeHandler) {
            self.closeHandler()
            Toast.showingToast = nil
            guard let nextToast = Toast.pendingToasts.popFirst() else { return }
            nextToast.show()
        }
    }
}

extension Toast {
    public static func show(message: String, action: Action? = nil, with duration: TimeInterval = 2) {
        Toast(message: message, action: action).show(with: duration)
    }
    public static func debugLog(message: Any, action: Action? = nil, with duration: TimeInterval = 10) {
        #if DEBUG
        Toast(message: "\(message)", action: action).show(with: duration)
        #endif
    }
    public static func showError(message: String, error: Any) {
        #if DEBUG
        Toast(message: "\(error)", action: nil, color: .systemRed).show(with: 20)
        #else
        Toast(message: message, action: nil, color: .systemRed).show(with: 2)
        #endif
    }
}

final private class ToastWindow: NSPanel {
    let toastView = ToastView()
    
    func show(with closeHandler: (@escaping () -> ()) -> (), completion: @escaping () -> ()) {
        guard let screen = NSScreen.main else { return NSSound.beep() }
        
        self.layoutIfNeeded()
        let frame = CGRect(centerX: screen.frame.size.width / 2, originY: 120, size: self.frame.size)
        self.setFrame(frame, display: true)
        
        self.level = .floating
        self.appearance = NSAppearance(named: .darkAqua)
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.orderFrontRegardless()
        
        self.alphaValue = 0
        self.animator().alphaValue = 1
        
        closeHandler {
            self.animator().alphaValue = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.close()
                completion()
            }
        }
    }
    
    init() {
        super.init(contentRect: .zero, styleMask: [.nonactivatingPanel, .fullSizeContentView], backing: .buffered, defer: true)
        self.contentView = toastView
        self.hasShadow = false
        self.backgroundColor = .clear
    }
}

final private class ToastView: NSLoadView {
    
    var message: String {
        get { textField.stringValue } set { textField.stringValue = newValue }
    }
    var action: Action? {
        didSet { reloadAction() }
    }
    var color: NSColor? {
        didSet { reloadColor() }
    }
    
    func addAttributeView(_ view: NSView, position: Toast.AttributeViewPosition) {
        switch position {
        case .right: stackView.addArrangedSubview(view)
        case .left: stackView.insertArrangedSubview(view, at: 0)
        }
    }
    
    private func reloadAction() {
        actionButton.isHidden = action == nil
        actionButton.title = action?.title ?? ""
    }
    
    private func reloadColor() {
        colorView.backgroundColor = color ?? .clear
    }
    
    private let stackView = NSStackView()
    private let textField = NSTextField(labelWithString: "")
    private let backgroundView = NSVisualEffectView()
    private let colorView = NSColorView()
    private let actionButton = ToastButton(title: "Search Google")
        
    convenience init(message: String) {
        self.init()
        self.textField.stringValue = message
    }
    
    @objc private func executeAction(_: Any) {
        action?.action()
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = 10

        self.snp.makeConstraints{ make in
            make.width.lessThanOrEqualTo(420)
        }
        
        self.addSubview(backgroundView)
        self.backgroundView.state = .active
        self.backgroundView.material = .sidebar
        self.backgroundView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(colorView)
        self.colorView.alphaValue = 0.85
        self.colorView.backgroundColor = .systemYellow
        self.colorView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(stackView)
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(16)
        }
        
        self.stackView.addArrangedSubview(textField)
        self.textField.alignment = .center
        self.textField.lineBreakMode = .byWordWrapping
        self.textField.textColor = .white
        
        self.stackView.addArrangedSubview(actionButton)
        self.actionButton.bezelStyle = .inline
        self.actionButton.setTarget(self, action: #selector(executeAction))
        
        self.reloadAction()
    }
}

final private class ToastButton: NSLoadButton {
    override var intrinsicContentSize: NSSize {
        super.intrinsicContentSize + [4, 4]
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if isHighlighted {
            NSColor.black.withAlphaComponent(0.3).setFill()
        } else {
            NSColor.black.withAlphaComponent(0.2).setFill()
        }
        NSBezierPath(roundedRect: bounds, xRadius: bounds.height/2, yRadius: bounds.height/2).fill()
        
        let nsString = title as NSString
        nsString.draw(center: bounds, attributes: [
            NSAttributedString.Key.foregroundColor : NSColor.secondaryLabelColor,
            NSAttributedString.Key.font : NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .medium)
        ])
    }
    
    override func onAwake() {
        self.bezelStyle = .inline
    }
}

extension NSString {
    public func draw(centerY rect: CGRect, attributes: [NSAttributedString.Key : Any]? = nil) {
        let actualRect = self.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin], attributes: attributes)
        let originY = rect.minY + (rect.height - actualRect.height) / 2
        let drawRect = CGRect(origin: [rect.minX, originY], size: actualRect.size)
        
        self.draw(with: drawRect, options: .usesLineFragmentOrigin, attributes: attributes)
    }
    public func drawRight(centerY rect: CGRect, attributes: [NSAttributedString.Key : Any]? = nil) {
        let actualRect = self.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin], attributes: attributes)
        let originY = rect.minY + (rect.height - actualRect.height) / 2
        var drawRect = CGRect(origin: [0, originY], size: actualRect.size)
        drawRect.end.x = rect.end.x
        
        self.draw(with: drawRect, options: .usesLineFragmentOrigin, attributes: attributes)
    }
    
    public func draw(center rect: CGRect, attributes: [NSAttributedString.Key : Any]? = nil) {
        let actualRect = self.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin], attributes: attributes)
        let origin = (rect.size - actualRect.size).convertToPoint() / 2
        let drawRect = CGRect(origin: origin, size: actualRect.size)
        
        self.draw(with: drawRect, options: .usesLineFragmentOrigin, attributes: attributes)
    }
}

extension Promise {
    public func peekProgressIndicator(_ message: String) -> Promise<Output, Failure> {
        Toast.showProgressIndicator(message: message, self)
        return self
    }
        
    public func sinkWithToast(_ successMessage: @escaping (Output) -> String) where Failure == Never {
        func neverhandler<T>(_ output: T) -> String { "Never" }
        self.sinkWithToast(successMessage, neverhandler)
    }
    
    public func sinkWithToast(_ successMessage: @escaping (Output) -> String, _ failureMessage: @escaping (Failure) -> String) {
        let toast = Toast()
        self
            .receive(on: .main)
            .sink({ output in
                toast.color = nil
                toast.message = successMessage(output)
                toast.show()
            }, { error in
                toast.color = .systemRed
                toast.message = failureMessage(error)
                toast.show()
            })
    }
}

extension Toast {
    fileprivate static func showProgressIndicator<T, F>(message: String, _ promise: Promise<T, F>) {
        let toast = Toast(message: message)
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.startAnimation(nil)
        indicator.snp.makeConstraints{ make in
            make.size.equalTo(16)
        }
        toast.addAttributeView(indicator, position: .right)
        toast.show(with: { close in promise.receive(on: .main).finally { close() } })
    }
}
