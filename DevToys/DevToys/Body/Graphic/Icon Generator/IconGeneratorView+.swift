//
//  IconGeneratorView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/26.
//

import CoreUtil

final class IconGeneratorViewController: NSViewController {
    private let cell = IconGeneratorView()
    
    @RestorableState("icongen.exporttype") var exportType: IconExportType = .icns
    @RestorableState("icongen.iosopt") var iosExportOptions = IOSIconGenerator.ExportOptions.iphone
    @RestorableData("icongen.image") var imageItem: ImageItem? = nil
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$imageItem
            .sink{[unowned self] in self.cell.imageDropView.image = $0?.image }.store(in: &objectBag)
        self.$exportType
            .sink{[unowned self] in self.cell.exportTypePicker.selectedItem = $0 }.store(in: &objectBag)
        
        self.cell.clearButton.actionPublisher
            .sink{[unowned self] in self.imageItem = nil }.store(in: &objectBag)
        self.cell.imageDropView.imagePublisher
            .sink{[unowned self] in self.imageItem = $0 }.store(in: &objectBag)
        self.cell.exportTypePicker.itemPublisher
            .sink{[unowned self] in self.exportType = $0 }.store(in: &objectBag)
        self.cell.exportButton.actionPublisher
            .sink{[unowned self] in self.exportIcon() }.store(in: &objectBag)
    }
    
    private func exportIcon() {
        guard let item = imageItem, let filename = exportFilename() else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        guard panel.runModal() == .OK, let url = panel.url else { return }
        
        switch self.exportType {
        case .iconFolder: IconFolderGenerator.make(item: item, to: url) => registerTask(_:)
        case .iosAssets: IOSIconGenerator.make(item: item, options: .iphone, to: url) => registerTask(_:)
        case .icns: IcnsGenerator.make(item: item, to: url) => registerTask(_:)
        case .iconset: IconsetGenerator.make(item: item, to: url) => registerTask(_:)
        }
    }
    
    private func registerTask(_ task: IconGenerateTask) {
        task.complete
            .peekProgressIndicator("Generating Icon...")
            .sinkWithToast({ "Icon Exported!" }, {_ in "Icon Export Failed!" })
    }
    
    private func exportFilename() -> String? {
        guard let item = imageItem else { return nil }

        switch self.exportType {
        case .icns: return "\(item.filenameWithoutExtension).icns"
        case .iconFolder: return item.filenameWithoutExtension
        case .iconset: return "\(item.filenameWithoutExtension).iconset"
        case .iosAssets: return "\(item.filenameWithoutExtension) (iOS Icon)"
        }
    }
}

enum IconExportType: String, TextItem {
    case iconFolder = "Icon Folder"
    case iosAssets = "iOS"
    case icns = "ICNS"
    case iconset = "Icon Set"
    
    var title: String { rawValue }
}

final private class IconGeneratorView: Page {
    let exportTypePicker = EnumPopupButton<IconExportType>()
    let imageDropView = ImageDropView()
    let iosOptionsView = iOSOptionsView()
    let clearButton = SectionButton(title: "Clear".localized(), image: R.Image.clear)
    let exportButton = Button(title: "Export")
    
    override func onAwake() {
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.export, title: "Icon Export Type", control: exportTypePicker)
        ]))
        
        
        let sourceView = Section(title: "Source".localized(), items: [
            imageDropView => {
                $0.snp.makeConstraints{ make in
                    make.height.equalTo(320)
                }
            }
        ], toolbarItems: [clearButton])
        
        let optionsView = NSStackView() => {
            $0.orientation = .vertical
            $0.addArrangedSubview(iosOptionsView)
            $0.addArrangedSubview(exportButton)
            exportButton.snp.makeConstraints{ make in
                make.width.equalToSuperview()
            }
        }
        
        self.addSection2(sourceView, optionsView)
    }
}

final private class iOSOptionsView: Section {
    let iPhoneSwitch = NSSwitch()
    let iPadSwitch = NSSwitch()
    let appleWatchSwitch = NSSwitch()
    let carplaySwitch = NSSwitch()
    let macSwitch = NSSwitch()
    
    override func onAwake() {
        super.onAwake()
        self.addStackItem(Area(title: "iPhone", control: iPhoneSwitch))
        self.addStackItem(Area(title: "iPad", control: iPadSwitch))
        self.addStackItem(Area(title: "Apple Watch", control: appleWatchSwitch))
        self.addStackItem(Area(title: "CarPlay", control: carplaySwitch))
        self.addStackItem(Area(title: "Mac", control: macSwitch))
    }
}

final private class ImageDropView: NSLoadView {
    
    var image: NSImage? {
        get { imageView.image }
        set {
            self.imageView.image = newValue
            self.dropIndicator.isHidden = newValue != nil
        }
    }
    
    let imagePublisher = PassthroughSubject<ImageItem, Never>()
    
    private let backgroundLayer = ControlBackgroundLayer.animationDisabled()
    private let imageView = NSImageView()
    private let dropIndicator = DropIndicatorView(title: "Drop Image Here")
    
    override func layout() {
        super.layout()
        self.backgroundLayer.frame = bounds
    }
    
    override func updateLayer() {
        self.backgroundLayer.update()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation { return .copy }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let images = ImageDropper.images(fromPasteboard: sender.draggingPasteboard)
        guard let image = images.first else { return false }
        
        imagePublisher.send(image)
        
        return true
    }
    
    override func onAwake() {
        self.imageView.unregisterDraggedTypes()
        self.registerForDraggedTypes([.fileURL, .URL, .fileContents])
        self.wantsLayer = true
        self.layer?.addSublayer(backgroundLayer)
        
        self.addSubview(imageView)
        self.imageView.snp.makeConstraints{ make in
            make.width.equalTo(240)
            make.top.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(dropIndicator)
        self.dropIndicator.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
    }
}
