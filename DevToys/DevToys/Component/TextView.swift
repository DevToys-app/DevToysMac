//
//  TextView.swift
//  DevToys
//
//  Created by yuki on 2022/02/03.
//

import CoreUtil

final class TextView: NSLoadView {
    class _TextView: NSTextView {
        let stringPublisher = PassthroughSubject<String, Never>()
        var sendingValue = false
        override var string: String {
            get { super.string } set { if !sendingValue { super.string = newValue } }
        }
        override func didChangeText() {
            self.sendingValue = true
            stringPublisher.send(string)
            self.sendingValue = false
        }
    }
    
    var string: String { get { textView.string } set { textView.string = newValue } }
    var stringPublisher: AnyPublisher<String, Never> { textView.stringPublisher.eraseToAnyPublisher() }
    
    var isEditable: Bool { get { textView.isEditable } set { textView.isEditable = newValue } }
    override var isSelectable: Bool { get { textView.isSelectable } set { textView.isSelectable = newValue } }
    
    override func layout() {
        super.layout()
        self.backgroudLayer.frame = bounds
    }
    
    override func updateLayer() {
        self.backgroudLayer.update()
    }
    
    private let scrollView = _TextView.scrollableTextView()
    private let backgroudLayer = ControlBackgroundLayer.animationDisabled()
    lazy var textView = scrollView.documentView as! _TextView

    override func onAwake() {
        self.wantsLayer = true
        self.layer?.addSublayer(backgroudLayer)
        
        self.addSubview(scrollView)
        self.textView.allowsUndo = true
        self.textView.isAutomaticSpellingCorrectionEnabled = false
        self.textView.isAutomaticQuoteSubstitutionEnabled = false
        self.textView.isAutomaticDashSubstitutionEnabled = false
        self.textView.isAutomaticLinkDetectionEnabled = false
        self.textView.font = .monospacedSystemFont(ofSize: R.Size.codeFontSize, weight: .regular)
        self.textView.drawsBackground = false
        self.textView.textContainerInset = [0, 4]
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

