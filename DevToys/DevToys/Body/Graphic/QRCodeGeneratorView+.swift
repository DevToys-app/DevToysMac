//
//  QLCodeGeneratorView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/23.
//

import CoreUtil
import CoreImage

final class QRCodeGeneratorViewController: NSViewController {
    private let cell = URLDecoderView()
    
    @RestorableState("qrcode.rawString") var rawString = "Hello World"
    @RestorableState("qrcode.correctionLevel") var correctionLevel: QRInputCorrectionLevel = .default
    @Observable var qrimage: NSImage? = nil
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$rawString
            .sink{[unowned self] in self.cell.inputTextSection.string = $0 }.store(in: &objectBag)
        self.$qrimage
            .sink{[unowned self] in self.cell.imageView.image = $0 }.store(in: &objectBag)
        self.$correctionLevel
            .sink{[unowned self] in self.cell.correctionLevelPicker.selectedItem = $0 }.store(in: &objectBag)
        
        self.cell.inputTextSection.stringPublisher
            .sink{[unowned self] in self.rawString = $0; updateQRCode() }.store(in: &objectBag)
        self.cell.correctionLevelPicker.itemPublisher
            .sink{[unowned self] in self.correctionLevel = $0; updateQRCode() }.store(in: &objectBag)
        self.cell.exportButton.actionPublisher
            .sink{[unowned self] in self.exportImage() }.store(in: &objectBag)
        
        self.updateQRCode()
    }
    
    private func exportImage() {
        guard let qrimage = qrimage?.png else { return NSSound.beep() }
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "QRCode.png"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        
        do {
            try qrimage.write(to: url)
        } catch {
            assertionFailure("\(error)")
        }
    }
    
    private func updateQRCode() {
        self.qrimage = generateQRCode(from: rawString)
    }
    
    private func generateQRCode(from string: String) -> NSImage? {
        if string.isEmpty { return nil }
        
        let data = string.data(using: .utf8)
        
        guard let qrfilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrfilter.setValue(data, forKey: "inputMessage")
        switch correctionLevel {
        case .high: qrfilter.setValue("H", forKey: "inputCorrectionLevel")
        case .default: qrfilter.setValue("Q", forKey: "inputCorrectionLevel")
        case .medium: qrfilter.setValue("M", forKey: "inputCorrectionLevel")
        case .low: qrfilter.setValue("L", forKey: "inputCorrectionLevel")
        }
        
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        guard let output = qrfilter.outputImage?.transformed(by: transform) else { return nil }
        
        let rep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

enum QRInputCorrectionLevel: String, TextItem {
    case high = "High"
    case `default` = "Default"
    case medium = "Medium"
    case low = "Low"
    
    var title: String { rawValue }
}

final private class URLDecoderView: Page {
    let correctionLevelPicker = EnumPopupButton<QRInputCorrectionLevel>()
    let inputTextSection = TextViewSection(title: "Input".localized(), options: .defaultInput)
    let imageView = DragImageView()
    let exportButton = SectionButton(title: "Export".localized(), image: R.Image.export)
    let imageViewDelegate = DragImageViewBlockDelegate{ "QRCode.png" }
    
    override func onAwake() {
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.paramators, title: "Correction Level", control: correctionLevelPicker)
        ]))
        self.addSection(inputTextSection)
        self.inputTextSection.snp.makeConstraints{ make in
            make.height.equalTo(320)
        }
        
        self.imageView.delegate = imageViewDelegate
        
        self.addSection(Section(title: "QR Code", items: [
            NSStackView() => {
                $0.alignment = .centerX
                $0.addArrangedSubview(imageView)
            }
        ], toolbarItems: [exportButton]))
    }
}

