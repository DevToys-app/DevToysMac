//
//  TextDiffView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/23.
//

import DiffMatchPatch
import CoreUtil

final class TextDiffViewController: NSViewController {
    
    @RestorableState("textdiff.operation") var operation: TextCheckOperation = .characters
    @RestorableState("textdiff.input1") var input1 = ""
    @RestorableState("textdiff.input2") var input2 = ""
    
    @Observable var diffAttributedString = NSAttributedString()
    
    private let cell = TextDiffView()

    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$operation
            .sink{[unowned self] in self.cell.checkOperationPicker.selectedItem = $0 }.store(in: &objectBag)
        self.$input1
            .sink{[unowned self] in self.cell.input1Section.string = $0 }.store(in: &objectBag)
        self.$input2
            .sink{[unowned self] in self.cell.input2Section.string = $0 }.store(in: &objectBag)
        self.$diffAttributedString
            .sink{[unowned self] in self.cell.outputSection.textView.textView.textStorage?.setAttributedString($0) }.store(in: &objectBag)
        
        self.cell.input1Section.stringPublisher
            .sink{[unowned self] in self.input1 = $0; updateDiff() }.store(in: &objectBag)
        self.cell.input2Section.stringPublisher
            .sink{[unowned self] in self.input2 = $0; updateDiff() }.store(in: &objectBag)
        self.cell.checkOperationPicker.itemPublisher
            .sink{[unowned self] in self.operation = $0; updateDiff() }.store(in: &objectBag)
        
        self.updateDiff()
    }
    
    private func updateDiff() {
        let diffs = TextDifferenceChecker.compare(input1, input2, operation: self.operation)
        self.diffAttributedString = buildAttributedString(from: diffs)
    }
    
    private func buildAttributedString(from diffs: [Difference]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        let defaultAttributes = [
            NSAttributedString.Key.foregroundColor: NSColor.textColor,
            NSAttributedString.Key.font : NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        ]
        
        for diff in diffs {
            switch diff.operation {
            case .equal:
                attributedString.append(NSAttributedString(string: diff.text, attributes: defaultAttributes))
            case .insert:
                attributedString.append(NSAttributedString(string: diff.text, attributes: defaultAttributes.merging([
                    NSAttributedString.Key.backgroundColor : NSColor.systemGreen.withAlphaComponent(0.7)
                ], uniquingKeysWith: { a, _ in a }) ))
            case .delete:
                attributedString.append(NSAttributedString(string: diff.text, attributes: defaultAttributes.merging([
                    NSAttributedString.Key.backgroundColor : NSColor.systemRed.withAlphaComponent(0.7)
                ], uniquingKeysWith: { a, _ in a }) ))
            }
        }
        
        return attributedString
    }
}

extension TextCheckOperation: TextItem {
    public static let allCases: [TextCheckOperation] = [.characters, .words, .lines]
    
    var title: String {
        switch self {
        case .characters: return "Characters"
        case .words: return "Words"
        case .lines: return "Lines"
        }
    }
}

final private class TextDiffView: Page {
    let checkOperationPicker = EnumPopupButton<TextCheckOperation>()
    
    let input1Section = CodeViewSection(title: "Input 1".localized(), options: .defaultInput, language: .plaintext)
    let input2Section = CodeViewSection(title: "Input 2".localized(), options: .defaultInput, language: .plaintext)
    let outputSection = TextViewSection(title: "Output".localized(), options: .defaultOutput)

    override func layout() {
        super.layout()
        
    }
    
    override func onAwake() {
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.format, title: "Diff Style", control: checkOperationPicker)
        ]))
        
        self.addSection2(input1Section, input2Section)
        self.input1Section.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
        
        self.addSection(outputSection)
        self.outputSection.textView.textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        self.outputSection.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
        
    }
}

