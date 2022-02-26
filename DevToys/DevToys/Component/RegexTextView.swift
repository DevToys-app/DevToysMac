//
//  RegexTextView.swift
//  DevToys
//
//  Created by yuki on 2022/02/03.
//

import CoreUtil

final class RegexTextView: NSLoadView {
    var string: String { get { textView.string } set { textView.string = newValue } }
    var highlightRanges = [NSRange]() { didSet { updateHighlights() } }
    var stringPublisher: AnyPublisher<String, Never> { textView.stringPublisher.eraseToAnyPublisher() }
    
    var isEditable: Bool { get { textView.isEditable } set { textView.isEditable = newValue } }
    override var isSelectable: Bool { get { textView.isSelectable } set { textView.isSelectable = newValue } }
    
    private let scrollView = _TextView.scrollableTextView()
    private lazy var textView = scrollView.documentView as! _TextView
    
    private func updateHighlights() {
        guard let textStorage = textView.textStorage else { return }
        
        objc_try {
            textStorage.removeAttribute(NSAttributedString.Key.backgroundColor, range: NSRange(location: 0, length: textStorage.length))
            
            for range in highlightRanges {
                textStorage.addAttribute(NSAttributedString.Key.backgroundColor, value: NSColor.systemBlue.withAlphaComponent(0.5), range: range)
            }
        } catch: { error in
            print(error)
        }
    }

    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        
        self.addSubview(scrollView)
        self.textView.allowsUndo = true
        self.textView.font = .monospacedSystemFont(ofSize: R.Size.codeFontSize, weight: .regular)
        self.textView.backgroundColor = .quaternaryLabelColor
        self.textView.textContainerInset = [0, 4]
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

final private class _TextView: NSTextView {
    let stringPublisher = PassthroughSubject<String, Never>()
    override func didChangeText() { self.stringPublisher.send(string) }
}
