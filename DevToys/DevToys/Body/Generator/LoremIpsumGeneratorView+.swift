//
//  LoremIpsumGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class LoremIpsumGeneratorViewController: NSViewController {
    private let cell = LoremIpsumGeneratorView()
    
    @RestorableState("li.type") var generateType = LoremIpsumGenerateType.sentences
    @RestorableState("li.length") var length = 3
    @RestorableState("li.output") var output = "hello world"
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.generate()
        
        self.$generateType.sink{[unowned self] in self.cell.typePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$length.sink{[unowned self] in self.cell.lengthField.value = Double($0) }.store(in: &objectBag)
        self.$output.sink{[unowned self] in self.cell.outputSection.string = $0 }.store(in: &objectBag)
        
        self.cell.typePicker.itemPublisher
            .sink{[unowned self] in self.generateType = $0; generate() }.store(in: &objectBag)
        self.cell.lengthField.valuePublisher.map{ $0.map{ Int($0) } }
            .sink{[unowned self] in
                let next = $0.reduce(self.length).clamped(1...)
                if next != self.length { self.length = next; self.generate() }
            }.store(in: &objectBag)
    }
    
    private func generate() {
        switch self.generateType {
        case .words: self.output = generateWords(length)
        case .sentences: self.output = generateSentences(length)
        case .paragraphs: self.output = generateParagraphs(length)
        }
    }
    
    private func generateParagraphs(_ count: Int) -> String {
        if count < 0 { return "" }
        return (0..<count).map{_ in generateSentences(.random(in: 3...6)) }.joined(separator: "\n\n")
    }
    private func generateSentences(_ count: Int) -> String {
        if count < 0 { return "" }
        return (0..<count).map{_ in generateWords(.random(in: 10...20)) }.map{ $0 + "." }.joined(separator: " ")
    }
    private func generateWords(_ count: Int) -> String {
        if count < 0 { return "" }
        return (0..<count).map{_ in wordSource.randomElement()! }.joined(separator: " ").capitalizingFirstLetter()
    }
}

enum LoremIpsumGenerateType: String, TextItem {
    case words = "Words"
    case sentences = "Sentences"
    case paragraphs = "Paragraphs"
    
    var title: String { rawValue.localized() }
}

final private class LoremIpsumGeneratorView: Page {
    let typePicker = EnumPopupButton<LoremIpsumGenerateType>()
    let lengthField = NumberField()
    
    let outputSection = TextViewSection(title: "Output".localized(), options: [.outputable, .copyable, .inputable])
    
    override func layout() {
        super.layout()
    
        self.outputSection.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 230))
        }
    }
    
    override func onAwake() {        
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.text, title: "Type".localized(), message: "Type of generating Lorem Ipsum".localized(), control: typePicker),
            Area(icon: R.Image.number, title: "Length".localized(), message: "Length of generating Lorem Ipsum".localized(), control: lengthField),
        ]))
        
        self.addSection(outputSection)
    }
}

private let wordSource: Set = ["est", "quis", "ipsum", "labore", "cillum", "velit", "consequat", "dolore", "proident", "non", "sint", "nisi", "in", "officia", "sed", "deserunt", "aute", "pariatur", "aliquip", "eiusmod", "ex", "excepteur", "et", "esse", "sunt", "dolor", "nulla", "lorem", "ullamco", "amet", "culpa", "eu", "adipiscing", "commodo", "ea", "fugiat", "qui", "minim", "enim", "ut", "anim", "cupidatat", "aliqua", "laboris", "ad", "exercitation", "id", "mollit", "tempor", "veniam", "reprehenderit", "occaecat", "sit", "consectetur", "duis", "voluptate", "nostrud", "laborum", "magna", "incididunt", "elit", "irure", "do"]

