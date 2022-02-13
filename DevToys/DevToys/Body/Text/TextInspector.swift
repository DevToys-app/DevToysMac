//
//  TextInspector.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class TextInspectorViewController: NSViewController {
    private let cell = TextInspectorView()
    
    @RestorableState("textin.input") private var input = "Hello World"
    @RestorableState("textin.output") private var output = "hello_world"
    @RestorableState("textin.convert") private var convertType: ConvertType = .camelCase
    @RestorableState("textin.info") private var information: String = ""
    
    override func loadView() { self.view = cell }
    
    private func updateInfo() {
        var result = ""
        func append(_ label: String, data: Any) {
            result += "\(label): ".padding(toLength: 24, withPad: " ", startingAt: 0)
            result += "\(data)"
            result += "\n"
        }
        
        append("Charactors".localized(), data: input.count)
        append("Words".localized(), data: input.split(separator: " ").count)
        append("Lines".localized(), data: input.split(separator: "\n").count)
        append("Bytes".localized(), data: input.data(using: .utf8)!.count)
        
        self.information = result
    }
    
    override func viewDidLoad() {
        self.$input
            .sink{[unowned self] in cell.inputSection.string = $0 }.store(in: &objectBag)
        self.$output
            .sink{[unowned self] in cell.outputSection.string = $0 }.store(in: &objectBag)
        self.$convertType.map{ ConvertType.allCases.firstIndex(of: $0) }
            .sink{[unowned self] in cell.tagCloudView.selectedItem = $0 }.store(in: &objectBag)
        self.$information
            .sink{[unowned self] in cell.informationView.string = $0 }.store(in: &objectBag)
        
        self.cell.inputSection.stringPublisher
            .sink{[unowned self] in self.input = $0; generate(); updateInfo() }.store(in: &objectBag)
        self.cell.tagCloudView.selectPublisher.map{ ConvertType.allCases[$0] }
            .sink{[unowned self] in self.convertType = $0; generate() }.store(in: &objectBag)
        
        self.updateInfo()
    }
    
    private func generate() {
        switch self.convertType {
        case .originalCase: self.output = input
        case .sentenceCase: self.output = input.capitalizingFirstLetter()
        case .lowerCase: self.output = input.lowercased()
        case .upperCase: self.output = input.uppercased()
        case .titleCase: self.output = input.capitalized
        case .camelCase: self.output = input.capitalized.split(separator: " ").joined().lowercaseFirstLetter()
        case .pascalCase: self.output = input.capitalized.split(separator: " ").joined()
        case .snakeCase: self.output = input.lowercased().split(separator: " ").joined(separator: "_")
        case .constantCase: self.output = input.uppercased().split(separator: " ").joined(separator: "_")
        case .kebabCase: self.output = input.lowercased().split(separator: " ").joined(separator: "-")
        case .cobolCase: self.output = input.uppercased().split(separator: " ").joined(separator: "-")
        case .trainCase: self.output = input.capitalized.split(separator: " ").joined(separator: "-")
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String { prefix(1).capitalized + dropFirst() }
    func lowercaseFirstLetter() -> String { prefix(1).lowercased() + dropFirst() }
}


private enum ConvertType: String, CaseIterable {
    case originalCase = "OriginalCase"
    case sentenceCase = "Sentence case"
    case lowerCase = "lower case"
    case upperCase = "UPPER CASE"
    case titleCase = "Title Case"
    case camelCase = "camelCase"
    case pascalCase = "PascalCase"
    case snakeCase = "snake_case"
    case constantCase = "CONSTANT_CASE"
    case kebabCase = "kebab-case"
    case cobolCase = "COBOL-CASE"
    case trainCase = "Traint-Case"
}

final class TextInspectorView: Page {
    let inputSection = TextViewSection(title: "Input".localized(), options: .defaultInput)
    let tagCloudView = TagCloudView()
    let outputSection = TextViewSection(title: "Output".localized(), options: .defaultOutput)
    let informationView = NSTextView()
    
    override func layout() {
        super.layout()
    
        self.outputSection.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 360))
        }
    }
    
    override func onAwake() {
        let convertSection = Section(title: "Convert".localized(), items: [tagCloudView])
        self.addSection(convertSection)
        self.tagCloudView.items = ConvertType.allCases.map{ $0.rawValue }
        self.tagCloudView.isSelectable = true
        
        self.addSection2(inputSection, outputSection)

        self.tagCloudView.snp.remakeConstraints{ make in
            make.height.equalTo(68)
            make.width.equalToSuperview()
        }
        
        self.informationView.font = .monospacedSystemFont(ofSize: R.Size.controlTitleFontSize, weight: .regular)
        
        self.informationView.snp.makeConstraints{ make in
            make.height.equalTo(100)
        }
        self.informationView.backgroundColor = .clear
        self.informationView.isEditable = false
        self.addSection(Section(title: "Information".localized(), items: [
            informationView
        ]))
    }
}
