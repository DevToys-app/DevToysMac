//
//  XMLFormatter.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

final class XMLFormatterViewController: NSViewController {
    @RestorableState("xml.rawCode") private var rawCode: String = ""
    @RestorableState("xml.formattedCode") private var formattedCode: String = ""
    @RestorableState("xml.documentType") private var documentType: DocumentType = .xmlDocument
    @RestorableState("xml.pretty") private var pretty = true
    @RestorableState("xml.autofix") private var autofix = true
    
    private let cell = XMLFormatterView()
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$rawCode
            .sink{[unowned self] in cell.inputSection.string = $0 }.store(in: &objectBag)
        self.$formattedCode
            .sink{[unowned self] in cell.outputSection.string = $0 }.store(in: &objectBag)
        self.$documentType
            .sink{[unowned self] in cell.documentTypeControl.selectedItem = $0 }.store(in: &objectBag)
        self.$pretty
            .sink{[unowned self] in cell.prettySwitch.isOn = $0 }.store(in: &objectBag)
        self.$autofix
            .sink{[unowned self] in cell.autoFixSwitch.isOn = $0 }.store(in: &objectBag)
        
        self.cell.prettySwitch.isOnPublisher
            .sink{[unowned self] in self.pretty = $0; updateFormattedCode() }.store(in: &objectBag)
        self.cell.autoFixSwitch.isOnPublisher
            .sink{[unowned self] in self.autofix = $0; updateFormattedCode() }.store(in: &objectBag)
        self.cell.documentTypeControl.itemPublisher
            .sink{[unowned self] in self.documentType = $0; updateFormattedCode() }.store(in: &objectBag)
        self.cell.inputSection.stringPublisher
            .sink{[unowned self] in self.rawCode = $0; updateFormattedCode() }.store(in: &objectBag)
        
        self.updateFormattedCode()
    }
    
    private func updateFormattedCode() {
        
        do {
            var options = XMLNode.Options()
            
            if pretty {
                options.insert(.nodePrettyPrint)
            }
            if autofix {
                switch documentType {
                case .htmlDocument: options.insert(.documentTidyHTML)
                case .xmlDocument: options.insert(.documentTidyXML)
                }
            }
            
            let document = try XMLDocument(xmlString: rawCode, options: options)
            
            self.formattedCode = document.xmlString(options: options)
                .replacingOccurrences(of: #"<?xml version="1.0" encoding="UTF-8"?>"#, with: "")
                .replacingOccurrences(of: #"<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">"#, with: "")
                .replacingOccurrences(of: #"<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">"#, with: "")
                .replacingOccurrences(of: #"<html xmlns="http://www.w3.org/1999/xhtml">"#, with: "<html>")
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
        } catch {
            self.formattedCode = "[Invalid Document]"
        }
    }
}
 
private enum DocumentType: String, TextItem {
    case htmlDocument = "HTML Document"
    case xmlDocument = "XML Document"
    
    var title: String { rawValue.localized() }
}

final private class XMLFormatterView: Page {
    let prettySwitch = NSSwitch()
    let autoFixSwitch = NSSwitch()
    let documentTypeControl = EnumPopupButton<DocumentType>()
    let inputSection = CodeViewSection(title: "Input".localized(), options: .defaultInput, language: .xml)
    let outputSection = CodeViewSection(title: "Output".localized(), options: .defaultOutput, language: .xml)
        
    private lazy var configurationSection = Section(title: "Configuration".localized(), items: [
        Area(icon: R.Image.convert, title: "Document Type".localized(), control: documentTypeControl),
        NSStackView() => {
            $0.orientation = .horizontal
            $0.distribution = .fillEqually
            $0.addArrangedSubview(Area(icon: R.Image.format, title: "Auto Fix Document".localized(), control: autoFixSwitch))
            $0.addArrangedSubview(Area(icon: R.Image.format, title: "Pretty Document".localized(), control: prettySwitch))
        }
    ])
    
    private lazy var ioStack = self.addSection2(inputSection, outputSection)
    
    override func layout() {
        super.layout()
        
        self.ioStack.snp.remakeConstraints{ make in
            make.height.equalTo(max(240, self.frame.height - 230))
        }
    }
    
    override func onAwake() {
        self.addSection(configurationSection)
    }
}
