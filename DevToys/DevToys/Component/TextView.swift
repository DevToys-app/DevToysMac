//
//  TextView.swift
//  DevToys
//
//  Created by yuki on 2022/02/03.
//

import CoreUtil

final class TextView: NSLoadView {
    
    private class _TextView: NSTextView {
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
    var isSelectable: Bool { get { textView.isSelectable } set { textView.isSelectable = newValue } }
    
    private let scrollView = _TextView.scrollableTextView()
    private lazy var textView = scrollView.documentView as! _TextView

    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        
        self.addSubview(scrollView)
        self.textView.allowsUndo = true
        self.textView.font = .monospacedSystemFont(ofSize: R.Size.codeFontSize, weight: .medium)
        self.textView.backgroundColor = .quaternaryLabelColor
        self.textView.textContainerInset = [0, 4]
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

