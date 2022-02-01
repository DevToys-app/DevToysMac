//
//  TextViewSection.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

struct TextSectionOptions: OptionSet {
    let rawValue: UInt64
    
    static let inputable = TextSectionOptions(rawValue: 1 << 0)
    static let clearable = TextSectionOptions(rawValue: 1 << 1)
    static let pastable = TextSectionOptions(rawValue: 1 << 2)
    static let fileImportable = TextSectionOptions(rawValue: 1 << 3)
    static let outputable = TextSectionOptions(rawValue: 1 << 4)
    static let copyable = TextSectionOptions(rawValue: 1 << 5)
    
    static let defaultInput = TextSectionOptions([.inputable, .clearable, .pastable, .fileImportable])
    static let defaultOutput = TextSectionOptions([.outputable, .copyable])
}

protocol TextViewType: NSView {
    var string: String { get set }
    var stringPublisher: AnyPublisher<String, Never> { get }
    
    var isEditable: Bool { get set }
    var isSelectable: Bool { get set }
}

extension TextView: TextViewType {}
extension CodeTextView: TextViewType {}

final class TextViewSection: TextViewSectionBase<TextView> {}
final class CodeViewSection: TextViewSectionBase<CodeTextView> {
    var language: CodeTextView.Language = .json { didSet { textView.language = language } }
    
    convenience init(title: String, options: TextSectionOptions, language: CodeTextView.Language) {
        self.init(title: title, options: options)
        self.setup(language: language)
    }
    private func setup(language: CodeTextView.Language) {
        self.language = language
    }
}

class TextViewSectionBase<TextView: TextViewType>: ControlSection {
    
    var string = "" {
        didSet {
            self.textView.string = string
            self.copyButton.stringContent = string
        }
    }
    var stringPublisher: AnyPublisher<String, Never> {
        textView.stringPublisher.merge(with: pasteButton.stringPublisher.map{ $0 ?? "" }.merge(with: clearButton.actionPublisher.map{ "" }, openButton.fileStringPublisher))
            .eraseToAnyPublisher()
    }
    
    var textSectionOptions = TextSectionOptions.defaultInput { didSet { updateToolbar() } }
    
    fileprivate let textView = TextView()
    
    convenience init(title: String, options: TextSectionOptions) {
        self.init()
        self.title = title
        self.setup(options: options)
    }
    
    private func setup(options: TextSectionOptions) {
        self.textSectionOptions = options
    }
    
    private lazy var pasteButton = PasteSectionButton()
    private lazy var openButton = OpenSectionButton()
    private lazy var clearButton = SectionButton(image: R.Image.clear)
    private lazy var copyButton = CopySectionButton()
    
    private func updateToolbar() {
        self.textView.isEditable = textSectionOptions.contains(.inputable)
        self.textView.isSelectable = textSectionOptions.contains(.outputable)
        
        self.removeAllToolbarItem()
        
        if self.textSectionOptions.contains(.pastable) {
            self.addToolbarItem(pasteButton)
        }
        if self.textSectionOptions.contains(.copyable) {
            self.addToolbarItem(copyButton)
        }
        if self.textSectionOptions.contains(.fileImportable) {
            self.addToolbarItem(openButton)
        }
        if self.textSectionOptions.contains(.clearable) {
            self.addToolbarItem(clearButton)
        }
    }
    
    override func onAwake() {
        super.onAwake()
        self.updateToolbar()
        
        self.addStackItem(textView)
        self.textView.snp.makeConstraints{ make in
            make.height.equalTo(200)
        }
    }
}
