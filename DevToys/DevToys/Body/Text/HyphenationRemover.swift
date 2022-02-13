import CoreUtil

final class HyphenationRemoverViewController: NSViewController {
    @RestorableState("hyphenation.rawCode") private var rawCode: String = ""
    @RestorableState("hyphenation.formattedCode") private var formattedCode: String = ""

    private let cell = HyphenationFormatterView()

    override func loadView() { self.view = cell }

    override func viewDidLoad() {
        self.$rawCode
            .sink{[unowned self] in cell.inputSection.string = $0 }.store(in: &objectBag)
        self.$formattedCode
            .sink{[unowned self] in cell.outputSection.string = $0 }.store(in: &objectBag)
        self.cell.inputSection.stringPublisher
            .sink{[unowned self] in self.rawCode = $0; updateFormattedCode() }.store(in: &objectBag)

        self.updateFormattedCode()
    }

    private func updateFormattedCode() {
        self.formattedCode = getFormattedText(rawCode)
    }

    private func getFormattedText(_ input: String) -> String {
        let lines = input
            .components(separatedBy: .newlines)
            .map { $0.replacingOccurrences(of: "- ", with: "") }
        let output = lines
            .joined(separator: " ")
            .replacingOccurrences(of: "  ", with: "\n")
        return output
    }
}

final private class HyphenationFormatterView: Page {
    let inputSection = CodeViewSection(title: "Input", options: .defaultInput, language: .plaintext)
    let outputSection = CodeViewSection(title: "Output", options: .defaultOutput, language: .plaintext)

    private lazy var ioStack = self.addSection2(inputSection, outputSection)

    override func layout() {
        super.layout()
        
        self.ioStack.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 150))
        }
    }

    override func onAwake() {
        self.title = "Hyphenation Remover"
    }
}
