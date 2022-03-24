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
    @RestorableState("icongen.iosopt") var iosOptions: IosIconGenerator.ExportOptions = [.iphone, .ipad]
    @RestorableState("icongen.scale") var scale: IconSet.Scale = .x1024
    @RestorableData("icongen.image") var imageItem: ImageItem? = nil
    @RestorableData("icongen.templete") var templeteName = "original"
    @Observable var iconTemplete: IconTemplete? = nil { didSet { templeteName = iconTemplete?.identifier ?? "original" } }
    @Observable var previewImage: NSImage? = nil
    
    let iconTempleteManager = IconImageManager.shared
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$previewImage
            .sink{[unowned self] in self.cell.imageDropView.image = $0 }.store(in: &objectBag)
        self.$exportType
            .sink{[unowned self] in self.cell.exportTypePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$iosOptions
            .sink{[unowned self] in self.bindiOSOptionsView($0) }.store(in: &objectBag)
        self.$iconTemplete
            .sink{[unowned self] in self.cell.iconTempletePicker.selectedMenuTitle = $0?.title }.store(in: &objectBag)
        self.$scale
            .sink{[unowned self] in self.cell.scalePicker.selectedItem = $0 }.store(in: &objectBag)
        
        self.cell.clearButton.actionPublisher
            .sink{[unowned self] in self.imageItem = nil; updatePreviewImage() }.store(in: &objectBag)
        self.cell.scalePicker.itemPublisher
            .sink{[unowned self] in self.scale = $0 }.store(in: &objectBag)
        self.cell.imageDropView.imagePublisher
            .sink{[unowned self] in self.imageItem = $0; updatePreviewImage() }.store(in: &objectBag)
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
        
        for templete in self.iconTempleteManager.templetes {
            self.cell.iconTempletePicker.menuItems.append(NSMenuItem(title: templete.title) {
                self.iconTemplete = templete
                self.updatePreviewImage()
            })
        }
        
        self.iconTemplete = self.iconTempleteManager.templete(for: self.templeteName) ?? self.iconTempleteManager.templetes.first
        self.updatePreviewImage()
        self.updateOptionView()
    }
    
    private func updatePreviewImage() {
        guard let imageItem = imageItem else { return previewImage = nil }
        
        if let iconTemplete = iconTemplete {
            self.previewImage = iconTemplete.bake(image: imageItem.image, scale: .x512)
        } else {
            self.previewImage = imageItem.image
        }
    }
    
    private func bindiOSOptionsView(_ options: IosIconGenerator.ExportOptions) {
        self.cell.iosOptionsView.iPhoneSwitch.isOn = options.contains(.iphone)
        self.cell.iosOptionsView.iPadSwitch.isOn = options.contains(.ipad)
        self.cell.iosOptionsView.appleWatchSwitch.isOn = options.contains(.applewatch)
        self.cell.iosOptionsView.carplaySwitch.isOn = options.contains(.carplay)
        self.cell.iosOptionsView.macSwitch.isOn = options.contains(.mac)
    }
    
    private func updateOptionView() {
        self.cell.iosOptionsView.isHidden = true
        self.cell.scalePickerArea.isHidden = true
        switch self.exportType {
        case .iosAssets: self.cell.iosOptionsView.isHidden = false
        case .png, .jpeg, .gif: self.cell.scalePickerArea.isHidden = false
        default: break
        }
    }
    
    private func exportIcon() {
        guard let item = imageItem, let filename = exportFilename(), let templete = iconTemplete else { return }
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename
        guard panel.runModal() == .OK, let url = panel.url else { return }
                
        switch self.exportType {
        case .iconFolder: IconFolderGenerator.make(item: item, templete: templete, to: url) => registerTask(_:)
        case .iosAssets: IosIconGenerator.make(item: item, options: iosOptions, to: url) => registerTask(_:)
        case .icns: IcnsGenerator.make(item: item, templete: templete, to: url) => registerTask(_:)
        case .iconset: IconsetGenerator.make(item: item, templete: templete, to: url) => registerTask(_:)
        case .androidAssets: AndroidIconGenerator.make(item: item, templete: templete, to: url) => registerTask(_:)
        case .ico: IcoGenerator.make(item: item, templete: templete, to: url) => registerTask(_:)
        case .png: PngIconGenerator.make(item: item, templete: templete, scale: scale, to: url) => registerTask(_:)
        case .jpeg: JpegIconGenerator.make(item: item, templete: templete, scale: scale, to: url) => registerTask(_:)
        case .gif: GifIconGenerator.make(item: item, templete: templete, scale: scale, to: url) => registerTask(_:)
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
        case .androidAssets: return "\(item.filenameWithoutExtension) (Android Icon)"
        case .ico: return "\(item.filenameWithoutExtension).ico"
        case .png: return "\(item.filenameWithoutExtension).png"
        case .jpeg: return "\(item.filenameWithoutExtension).jpg"
        case .gif: return "\(item.filenameWithoutExtension).gif"
        }
    }
}

enum IconExportType: String, TextItem {
    case iconFolder = "Icon Folder"
    case iosAssets = "iOS"
    case androidAssets = "Android"
    case icns = "ICNS"
    case iconset = "Icon Set"
    case ico = "ICO"
    case png = "PNG"
    case jpeg = "JPEG"
    case gif = "GIF"
    
    var title: String { rawValue }
}

extension IconSet.Scale: TextItem {
    static let allCases: [IconSet.Scale] = [.x16, .x32, .x64, .x128, .x256, .x512, .x1024]
    
    var title: String {
        switch self {
        case .x16: return "16px"
        case .x32: return "32px"
        case .x64: return "64px"
        case .x128: return "128px"
        case .x256: return "256px"
        case .x512: return "512px"
        case .x1024: return "1024px"
        }
    }
}

final private class IconGeneratorView: Page {
    let exportTypePicker = EnumPopupButton<IconExportType>()
    let iconTempletePicker = PopupButton()
    let imageDropView = ImageDropView()
    let iosOptionsView = iOSOptionsView()
    let scalePicker = EnumPopupButton<IconSet.Scale>()
    lazy var scalePickerArea = Area(icon: R.Image.paramators, title: "Scale", control: scalePicker)
    let clearButton = SectionButton(title: "Clear".localized(), image: R.Image.clear)
    let exportButton = Button(title: "Export")
    
    override func onAwake() {
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.export, title: "Icon Export Type", control: exportTypePicker),
            Area(icon: R.Image.paramators, title: "Templetes", control: iconTempletePicker)
        ]))
        
        self.addSection2(
            Section(title: "Source".localized(), items: [
                imageDropView => {
                    $0.snp.makeConstraints{ make in
                        make.height.equalTo(320)
                    }
                }
            ], toolbarItems: [clearButton]),
            
            Section(title: "Options", items: [
                scalePickerArea,
                iosOptionsView,
                exportButton
            ])
        )
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

