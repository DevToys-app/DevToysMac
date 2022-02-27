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
    @RestorableState("icongen.iosopt") var iosOptions: IOSIconGenerator.ExportOptions = [.iphone, .ipad]
    @RestorableData("icongen.image") var imageItem: ImageItem? = nil
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$imageItem
            .sink{[unowned self] in self.cell.imageDropView.image = $0?.image }.store(in: &objectBag)
        self.$exportType
            .sink{[unowned self] in self.cell.exportTypePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$iosOptions
            .sink{[unowned self] in self.bindiOSOptionsView($0) }.store(in: &objectBag)
        
        self.cell.clearButton.actionPublisher
            .sink{[unowned self] in self.imageItem = nil }.store(in: &objectBag)
        self.cell.imageDropView.imagePublisher
            .sink{[unowned self] in self.imageItem = $0 }.store(in: &objectBag)
        self.cell.exportTypePicker.itemPublisher
            .sink{[unowned self] in self.exportType = $0; updateOptionView() }.store(in: &objectBag)
        self.cell.exportButton.actionPublisher
            .sink{[unowned self] in self.exportIcon() }.store(in: &objectBag)
        
        self.cell.iosOptionsView.iPhoneSwitch.isOnPublisher
            .sink{[unowned self] in self.iosOptions = $0 ? iosOptions.union(.iphone) : iosOptions.subtracting(.iphone) }.store(in: &objectBag)
        self.cell.iosOptionsView.iPadSwitch.isOnPublisher
            .sink{[unowned self] in self.iosOptions = $0 ? iosOptions.union(.ipad) : iosOptions.subtracting(.ipad) }.store(in: &objectBag)
        self.cell.iosOptionsView.appleWatchSwitch.isOnPublisher
            .sink{[unowned self] in self.iosOptions = $0 ? iosOptions.union(.applewatch) : iosOptions.subtracting(.applewatch) }.store(in: &objectBag)
        self.cell.iosOptionsView.carplaySwitch.isOnPublisher
            .sink{[unowned self] in self.iosOptions = $0 ? iosOptions.union(.carplay) : iosOptions.subtracting(.carplay) }.store(in: &objectBag)
        self.cell.iosOptionsView.macSwitch.isOnPublisher
            .sink{[unowned self] in self.iosOptions = $0 ? iosOptions.union(.mac) : iosOptions.subtracting(.mac) }.store(in: &objectBag)
    }
    
    private func bindiOSOptionsView(_ options: IOSIconGenerator.ExportOptions) {
        self.cell.iosOptionsView.iPhoneSwitch.isOn = options.contains(.iphone)
        self.cell.iosOptionsView.iPadSwitch.isOn = options.contains(.ipad)
        self.cell.iosOptionsView.appleWatchSwitch.isOn = options.contains(.applewatch)
        self.cell.iosOptionsView.carplaySwitch.isOn = options.contains(.carplay)
        self.cell.iosOptionsView.macSwitch.isOn = options.contains(.mac)
    }
    
    private func updateOptionView() {
        self.cell.iosOptionsView.isHidden = true
        switch self.exportType {
        case .iosAssets: self.cell.iosOptionsView.isHidden = false
        default: break
        }
    }
    
    private func exportIcon() {
        guard let item = imageItem, let filename = exportFilename() else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        guard panel.runModal() == .OK, let url = panel.url else { return }
        
        switch self.exportType {
        case .iconFolder: IconFolderGenerator.make(item: item, to: url) => registerTask(_:)
        case .iosAssets: IOSIconGenerator.make(item: item, options: iosOptions, to: url) => registerTask(_:)
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
        
        let optionsView = Section(title: "Options", items: [
            iosOptionsView,
            exportButton
        ])
        
        self.addSection2(sourceView, optionsView)
    }
}

final private class iOSOptionsView: NSLoadStackView {
    let iPhoneSwitch = NSSwitch()
    let iPadSwitch = NSSwitch()
    let appleWatchSwitch = NSSwitch()
    let carplaySwitch = NSSwitch()
    let macSwitch = NSSwitch()
    
    override func onAwake() {
        self.orientation = .vertical
        self.addArrangedSubview(Area(icon: R.Image.iphone, title: "iPhone", control: iPhoneSwitch))
        self.addArrangedSubview(Area(icon: R.Image.iphone, title: "iPad", control: iPadSwitch))
        self.addArrangedSubview(Area(icon: R.Image.appleWatch, title: "Apple Watch", control: appleWatchSwitch))
        self.addArrangedSubview(Area(icon: R.Image.carplay, title: "CarPlay", control: carplaySwitch))
        self.addArrangedSubview(Area(icon: R.Image.mac, title: "Mac", control: macSwitch))
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
            make.width.equalTo(180)
            make.top.bottom.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(dropIndicator)
        self.dropIndicator.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
    }
}
