//
//  UUIDGenerator.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class UUIDGeneratorViewController: NSViewController {
    private let cell = UUIDGeneratorView()
    
    @RestorableState("uuid.isHyphened") var isHyphened = true
    @RestorableState("uuid.uppercase") var isUppercase = true
    @RestorableState("uuid.count") var count = 3
    @RestorableState("uuid.uuid") var uuids = "\(UUID().uuidString)\n"
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$isHyphened
            .sink{[unowned self] in self.cell.hyphensSwitch.isOn = $0 }.store(in: &objectBag)
        self.$isUppercase
            .sink{[unowned self] in self.cell.uppercaseSwitch.isOn = $0 }.store(in: &objectBag)
        self.$count
            .sink{[unowned self] in self.cell.generateCount.value = Double($0) }.store(in: &objectBag)
        self.$uuids
            .sink{[unowned self] in self.cell.uuidView.string = $0 }.store(in: &objectBag)
        
        self.cell.hyphensSwitch.isOnPublisher
            .sink{[unowned self] in self.isHyphened = $0 }.store(in: &objectBag)
        self.cell.uppercaseSwitch.isOnPublisher
            .sink{[unowned self] in self.isUppercase = $0 }.store(in: &objectBag)
        self.cell.generateCount.valuePublisher
            .sink{[unowned self] in self.count = $0.map{ Int($0) }.reduce(self.count).clamped(1...) }.store(in: &objectBag)
        self.cell.generateButton.actionPublisher
            .sink{[unowned self] in self.generateUUID() }.store(in: &objectBag)
        self.cell.clearButton.actionPublisher
            .sink{[unowned self] in self.uuids = "" }.store(in: &objectBag)
    }
    
    private func generateUUID() {
        for _ in 0..<count {
            var uuidString = UUID().uuidString
            if !isHyphened {
                uuidString = uuidString.replacingOccurrences(of: "-", with: "")
            }
            if !isUppercase {
                uuidString = uuidString.lowercased()
            }
            uuids.append(uuidString)
            uuids.append("\n")
        }
    }
}

final private class UUIDGeneratorView: ToolPage {
    let hyphensSwitch = NSSwitch()
    let uppercaseSwitch = NSSwitch()
    let generateCount = NumberField()
    let generateButton = Button(title: "Generate UUIDs")
    let uuidView = TextView() => { $0.isEditable = false }
    let clearButton = SectionButton(image: R.Image.clear)
    
    override func layout() {
        super.layout()
        
        self.uuidView.snp.remakeConstraints{ make in
            make.height.equalTo(max(200, self.frame.height - 320))
        }
    }
    
    override func onAwake() {
        self.title = "UUID Generator"
        
        self.addSection(ControlSection(title: "Configuration", items: [
            ControlArea(icon: R.Image.hyphen, title: "Hyphens", control: hyphensSwitch),
            ControlArea(icon: R.Image.format, title: "Uppercase", message: "Whether to use uppercase for generate UUIDs.", control: uppercaseSwitch),
        ]))
        
        self.stackView.addArrangedSubview(NSStackView() => {
            $0.addArrangedSubview(generateCount)
            $0.addArrangedSubview(NSTextField(labelWithString: "x") => {
                $0.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
            })
            $0.addArrangedSubview(generateButton)
        })
        self.addSection(ControlSection(title: "UUIDs", items: [
            uuidView
        ], toolbarItems: [clearButton]))
    }
}
