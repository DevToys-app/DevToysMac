//
//  ImageConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/04.
//

import CoreUtil

final class ImageConverterViewController: NSViewController {
    private let cell = ImageConverterView()
    
    @RestorableState("imc.format") private var format = ImageFormatType.png
    @RestorableState("imc.scaleMode") private var scaleMode = ImageScaleMode.scaleToFill
    @RestorableState("imc.resize") private var resize = false
    @RestorableState("imc.width") private var width = 1280.0
    @RestorableState("imc.height") private var height = 720.0
    
    @Observable var task: [ImageConvertTask] = []
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$format
            .sink{[unowned self] in cell.formatTypePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$task
            .sink{[unowned self] in cell.listView.convertTasks = $0 }.store(in: &objectBag)
        self.$resize
            .sink{[unowned self] in cell.resizeSwitch.isOn = $0; cell.resizeOptionStack.isHidden = !$0 }.store(in: &objectBag)
        self.$scaleMode
            .sink{[unowned self] in cell.scaleModePicker.selectedItem = $0 }.store(in: &objectBag)
        self.$width
            .sink{[unowned self] in self.cell.widthField.value = $0 }.store(in: &objectBag)
        self.$height
            .sink{[unowned self] in self.cell.heightField.value = $0 }.store(in: &objectBag)
        
        self.cell.resizeSwitch.isOnPublisher
            .sink{[unowned self] in self.resize = $0 }.store(in: &objectBag)
        self.cell.widthField.valuePublisher
            .sink{[unowned self] in self.width = $0.reduce(width).clamped(1...) }.store(in: &objectBag)
        self.cell.heightField.valuePublisher
            .sink{[unowned self] in self.height = $0.reduce(height).clamped(1...) }.store(in: &objectBag)
        self.cell.scaleModePicker.itemPublisher
            .sink{[unowned self] in self.scaleMode = $0 }.store(in: &objectBag)
        self.cell.formatTypePicker.itemPublisher
            .sink{[unowned self] in self.format = $0 }.store(in: &objectBag)
        self.cell.dragPublisher
            .sink{[unowned self] in self.readURLs($0) }.store(in: &objectBag)
    }
    
    private func readURLs(_ pasteboard: NSPasteboard) {
        let newImageItems = ImageDropper.images(fromPasteboard: pasteboard)
        guard !newImageItems.isEmpty else { return }
        
        self.task.append(contentsOf: newImageItems.map{
            ImageConverter.convert($0, format: format, resize: self.resize, size: [CGFloat(width), CGFloat(height)], scale: scaleMode)
        })
        
        self.cell.listView.scrollView.contentView.scrollToBottom()
    }
}

final private class ImageConverterView: Page {
    
    let formatTypePicker = EnumPopupButton<ImageFormatType>()
    let resizeSwitch = NSSwitch()
    let widthField = NumberField()
    let heightField = NumberField()
    let scaleModePicker = EnumPopupButton<ImageScaleMode>()
    let listView = ImageListView()
    let dragPublisher = PassthroughSubject<NSPasteboard, Never>()
    
    lazy var resizeOptionStack = NSStackView() => {
        let spacer = NSView()
        $0.distribution = .fillProportionally
        $0.addArrangedSubview(spacer)
        $0.setCustomSpacing(0, after: spacer)
        $0.addArrangedSubview(Area(title: "Scale".localized(), control: scaleModePicker))
        $0.addArrangedSubview(Area(title: "Size".localized(), control: NSStackView() => {
            $0.addArrangedSubview(widthField => {
                $0.snp.makeConstraints{ make in
                    make.width.equalTo(80)
                }
            })
            $0.addArrangedSubview(NSTextField(labelWithString: "x"))
            $0.addArrangedSubview(heightField => {
                $0.snp.makeConstraints{ make in
                    make.width.equalTo(80)
                }
            })
        }))
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.canReadTypes([.URL, .fileURL, .fileContents]) { return .copy } else { return .none }
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else { return false }
        self.dragPublisher.send(sender.draggingPasteboard)
        return true
    }
    
    override func layout() {
        listView.snp.remakeConstraints{ make in
            make.height.equalTo(max(200, self.frame.height - 380))
        }
        super.layout()
    }
    
    override func onAwake() {
        self.registerForDraggedTypes([.URL, .fileURL, .fileContents])

        self.addSection(
            Section(title: "Configuration".localized(), items: [
                Area(icon: R.Image.format, title: "Image Format".localized(), control: formatTypePicker),
                Area(icon: R.Image.paramators, title: "Resize".localized(), control: resizeSwitch),
                resizeOptionStack
            ])
        )
        
        self.addSection(Section(title: "Converted Images".localized(), items: [listView]))
    }
}

final private class ImageListView: NSLoadView {
    let scrollView = NSScrollView()
    let listView = NSTableView.list()
    var convertTasks = [ImageConvertTask]() { didSet { listView.reloadData() } }
    
    override func updateLayer() {
        self.layer?.backgroundColor = R.Color.controlBackgroundColor.cgColor
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        self.addSubview(scrollView)
        self.scrollView.drawsBackground = false
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.documentView = listView
        self.listView.delegate = self
        self.listView.dataSource = self
        
        let menu = NSMenu()
        menu.addItem(title: "Open in Finder".localized()) { [self] in
            if let task = convertTasks.at(listView.clickedRow) {
                NSWorkspace.shared.activateFileViewerSelecting([task.destinationURL])
            }
        }
        self.listView.menu = menu
    }
}

extension ImageListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int { convertTasks.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 46 }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = ImageListCell()
        let task = convertTasks[row]
        cell.imageView.image = task.image
        cell.titleLabel.stringValue = task.title
        cell.sizeLabel.stringValue = "\(task.size.width.formattedString()) x \(task.size.height.formattedString())"
        task.isDone
            .finally {
                cell.checkImageView.isHidden = false
                cell.progressIndicator.isHidden = true
            }
            .sink({
                cell.checkImageView.image = R.Image.check
                }, {
                    print($0)
                    cell.checkImageView.image = R.Image.error
                }
            )
        
        return cell
    }
}

final private class ImageListCell: NSLoadStackView {
    let imageView = NSImageView()
    let titleLabel = NSTextField(labelWithString: "Sample.png") => {
        $0.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        $0.lineBreakMode = .byTruncatingTail
    }
    let checkImageView = NSImageView()
    let progressIndicator = NSProgressIndicator()
    let sizeLabel = NSTextField(labelWithString: "100 x 100") => {
        $0.font = .systemFont(ofSize: R.Size.controlFontSize)
        $0.textColor = .secondaryLabelColor
        $0.lineBreakMode = .byTruncatingTail
    }
    
    override func updateLayer() {
        imageView.layer?.backgroundColor = NSColor.tertiaryLabelColor.withAlphaComponent(0.05).cgColor
    }
    
    override func onAwake() {
        self.imageView.wantsLayer = true
        self.imageView.layer?.cornerRadius = R.Size.corner
        
        self.addArrangedSubview(checkImageView)
        self.checkImageView.isHidden = true
        self.checkImageView.snp.makeConstraints{ make in
            make.size.equalTo(16)
        }
        
        self.addArrangedSubview(progressIndicator)
        self.progressIndicator.style = .spinning
        self.progressIndicator.startAnimation(nil)
        self.progressIndicator.snp.makeConstraints{ make in
            make.size.equalTo(16)
        }
        
        self.addArrangedSubview(imageView)
        self.spacing = 16
        self.edgeInsets = .init(x: 16, y: 4)
        self.imageView.snp.makeConstraints{ make in
            make.width.equalTo(48)
            make.height.equalTo(28)
        }
        
        let titleStack = NSStackView()
        self.addArrangedSubview(titleStack)
        titleStack.orientation = .vertical
        titleStack.alignment = .left
        titleStack.spacing = 4
        titleStack.distribution = .fillProportionally
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(sizeLabel)
        titleStack.snp.makeConstraints{ make in
            make.right.equalToSuperview().inset(16)
        }
    }
}

private let formatter = NumberFormatter() => { $0.maximumFractionDigits = 2 }

extension CGFloat {
    public func formattedString() -> String { formatter.string(from: NSNumber(value: native)) ?? "0" }
}

extension Double {
    public func formattedString() -> String { formatter.string(from: NSNumber(value: self)) ?? "0" }
}
