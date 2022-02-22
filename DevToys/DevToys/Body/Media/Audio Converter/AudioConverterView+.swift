//
//  AudioConverter.swift
//  DevToys
//
//  Created by yuki on 2022/02/21.
//

import CoreUtil
import Quartz

final class AudioConverterViewController: NSViewController {
    private let cell = AudioConverterView()
    
    @Observable var tasks = [AudioConvertTask]()
    @RestorableData("audio.format") var format: AudioConvertFormat = convertGroups[0].formats[1]
    @RestorableState("audio.removeSource") var removeSource = false
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$tasks
            .sink{[unowned self] in cell.listView.convertTasks = $0 }.store(in: &objectBag)
        self.$format
            .sink{[unowned self] in cell.formatPicker.selectedMenuTitle = $0.title }.store(in: &objectBag)
        self.$removeSource
            .sink{[unowned self] in cell.removeFileSwitch.isOn = $0 }.store(in: &objectBag)
        
        self.cell.formatPublisher
            .sink{[unowned self] in self.format = $0 }.store(in: &objectBag)
        self.cell.removeFileSwitch.isOnPublisher
            .sink{[unowned self] in self.removeSource = $0 }.store(in: &objectBag)
        self.cell.dropPublisher
            .sink{[unowned self] in handleDrop($0) }.store(in: &objectBag)
        self.cell.listView.removePublisher
            .sink{[unowned self] in removeItems($0) }.store(in: &objectBag)
        self.cell.clearButton.actionPublisher
            .sink{[unowned self] in clearTasks() }.store(in: &objectBag)
    }
    
    private func clearTasks() {
        tasks = tasks.filter{ $0.completePromise.state.isSettled }
    }
    
    private func removeItems(_ indexSet: IndexSet) {
        for index in indexSet.reversed() {
            if !tasks[index].completePromise.state.isSettled {
                self.tasks.remove(at: index)
            } else {
                NSSound.beep()
            }
        }
    }
    
    private func handleDrop(_ urls: [URL]) {
        let urls = urls.flatMap{ AudioFileScanner.scan($0) }
        var newTasks = [AudioConvertTask]()
        
        for url in urls {
            let destinationURL = FileConflictAvoider.avoidConflict(url.deletingPathExtension().appendingPathExtension(format.ext))
            let options = AudioConvertOptions(thumbsize: AudioConvertTaskCell.thumbnailSize, removeSourceFile: removeSource)
            let task = AudioConverter.convert(from: url, format: format, options: options, destinationURL: destinationURL)
            newTasks.append(task)
        }
        
        self.tasks.insert(contentsOf: newTasks, at: 0)
    }
}

final private class AudioConverterView: Page {
    let formatPicker = PopupButton()
    let removeFileSwitch = NSSwitch()
    let listView = AudioConvertListView()
    let clearButton = SectionButton(title: "Clear".localized(), image: R.Image.clear)
    
    let formatPublisher = PassthroughSubject<AudioConvertFormat, Never>()
    let dropPublisher = PassthroughSubject<[URL], Never>()
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingPasteboard.canReadTypes([.fileURL]) { return .copy } else { return .none }
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty else { return false }
        dropPublisher.send(urls)
        return true
    }
    
    override func layout() {
        listView.snp.remakeConstraints{ make in
            make.height.equalTo(max(200, self.frame.height - 270))
        }
        super.layout()
    }
    
    override func onAwake() {
        self.registerForDraggedTypes([.fileURL])
        
        self.addSection(Section(title: "Configuration".localized(), items: [
            Area(icon: R.Image.format, title: "Format".localized(), control: formatPicker),
            Area(icon: R.Image.paramators, title: "Remove source file".localized(), message: "Whether to delete the source file after exporting a Audio".localized(), control: removeFileSwitch)
        ]))
        
        self.addSection(Section(title: "Files".localized(), items: [
            listView
        ], toolbarItems: [clearButton]))
        
        self.registerFormats(convertGroups)
    }
    
    private func registerFormats(_ groups: [AudioConvertGroup]) {
        for group in groups {
            let item = NSMenuItem(title: group.title, isSelected: false, isEnabled: true, action: nil)
            let submenu = NSMenu()
            for format in group.formats {
                submenu.addItem(title: format.title, action: {
                    self.formatPublisher.send(format)
                })
            }
            item.submenu = submenu
            formatPicker.menuItems.append(item)
        }
    }
}

final private class AudioConvertListView: NSLoadView, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    let scrollView = NSScrollView()
    let listView = EmptyImageTableView.list()
    let removePublisher = PassthroughSubject<IndexSet, Never>()
    var convertTasks = [AudioConvertTask]() { didSet { listView.reloadData() } }
    
    override func updateLayer() {
        self.layer?.backgroundColor = R.Color.controlBackgroundColor.cgColor
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.hotKey {
        case .space: showQuickLook()
        case .delete: removePublisher.send(listView.selectedRowIndexes)
        default: super.keyDown(with: event)
        }
    }
    
    private func showQuickLook() {
        guard let panel = QLPreviewPanel.shared() else { return }
        panel.dataSource = self
        panel.delegate = self
        panel.makeKeyAndOrderFront(nil)
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
        self.listView.setFileDropEmptyView()
        self.listView.delegate = self
        self.listView.dataSource = self
        self.listView.allowsMultipleSelection = true
        
        let menu = NSMenu()
        menu.addItem(title: "Open in Finder".localized()) { [self] in
            guard let task = convertTasks.at(listView.clickedRow) else { return }
            NSWorkspace.shared.activateFileViewerSelecting([task.destinationURL])
        }
        menu.addItem(title: "Delete".localized()) { [self] in
            if listView.clickedRow >= 0 { removePublisher.send(.init(integer: listView.clickedRow)) }
        }
        menu.addItem(title: "Quick Look".localized()) { [self] in
            self.showQuickLook()
        }
        
        self.listView.menu = menu
    }
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        self.listView.selectedRowIndexes.count
    }
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem {
        let index = self.listView.selectedRowIndexes.map{ $0 }[index]
        return convertTasks[index].destinationURL as QLPreviewItem
    }
    func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        guard let index = convertTasks.firstIndex(where: { item.isEqual($0.destinationURL) }) else { return .zero }
        
        return listView.convertToScreen(listView.rect(ofRow: index))
    }
}

extension AudioConvertListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int { convertTasks.count }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 64 }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = AudioConvertTaskCell()
        let task = convertTasks[row]
        
        cell.titleLabel.stringValue = task.title
        cell.infoLabel.stringValue = "Starting..."
//        cell.thumbnailImageView.image = task.thumbnail
        
        task.fftask
            .receive(on: .main)
            .sink{ task in
                task.$progress
                    .receive(on: DispatchQueue.main, options: nil)
                    .filter{ $0 != 0 }
                    .sink{[unowned cell] in
                        cell.progressView.doubleValue = $0
                        cell.infoLabel.stringValue = "\(Int($0 * 100))%"
                    }
                    .store(in: &cell.objectBag)
                
                task.complete
                    .receive(on: .main)
                    .sink({
                        cell.infoLabel.stringValue = "Complete"
                    }, { error in
                        cell.infoLabel.textColor = .systemRed
                        cell.infoLabel.stringValue = "Convert Failed \(error)"
                    })
            }
        
        return cell
    }
}

final private class AudioConvertTaskCell: NSLoadView {
    
    static let thumbnailSize: CGSize = [50, 50]
    static let thumbnailImageSize: CGSize = thumbnailSize * (NSScreen.main?.backingScaleFactor ?? 1)
    
    let thumbnailImageView = NSImageView()
    let progressView = NSProgressIndicator()
    let titleLabel = NSTextField(labelWithString: "Title")
    let infoLabel = NSTextField(labelWithString: "Title")
    
    private let stackView = NSStackView()
    private let titleStackView = NSStackView()
    
    override func onAwake() {
        self.addSubview(stackView)
        self.stackView.edgeInsets = .init(x: 16, y: 8)
        self.stackView.distribution = .fillProportionally
        self.stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        self.stackView.addArrangedSubview(thumbnailImageView)
        self.thumbnailImageView.isHidden = true
        self.thumbnailImageView.snp.makeConstraints{ make in
            make.size.equalTo(AudioConvertTaskCell.thumbnailSize)
        }
        self.stackView.addArrangedSubview(titleStackView)
        
        self.titleStackView.spacing = 0
        self.titleStackView.orientation = .vertical
        self.titleStackView.alignment = .left
        
        self.titleStackView.addArrangedSubview(titleLabel)
        self.titleLabel.font = .systemFont(ofSize: R.Size.controlTitleFontSize)
        
        self.titleStackView.addArrangedSubview(progressView)
        self.progressView.isIndeterminate = false
        self.progressView.minValue = 0
        self.progressView.maxValue = 1
        self.progressView.usesThreadedAnimation = false
        
        self.titleStackView.addArrangedSubview(infoLabel)
        self.infoLabel.font = .systemFont(ofSize: R.Size.controlFontSize)
    }
}


private let convertGroups = [
    AudioConvertGroup(title: "ACC(M4A)", formats: [
        AudioConvertFormat(title: "ACC 44100Hz 64kbps", ext: "m4a", options: ["-ar", "44100", "-b:a", "64k", "-c:v", "copy"]),
        AudioConvertFormat(title: "ACC 44100Hz 128kbps", ext: "m4a", options: ["-ar", "44100", "-b:a", "128k", "-c:v", "copy"]),
        AudioConvertFormat(title: "ACC 44100Hz 256bps", ext: "m4a", options: ["-ar", "44100", "-b:a", "256k", "-c:v", "copy"])
    ]),
    AudioConvertGroup(title: "FLAC", formats: [
        AudioConvertFormat(title: "FLAC 32000Hz", ext: "flac", options: ["-ar", "32000"]),
        AudioConvertFormat(title: "FLAC 44100Hz", ext: "flac", options: ["-ar", "44100"]),
        AudioConvertFormat(title: "FLAC 48000Hz", ext: "flac", options: ["-ar", "48000"]),
    ]),
    AudioConvertGroup(title: "M4R", formats: [
        AudioConvertFormat(title: "M4R 44100Hz 64kbs", ext: "m4r", options: ["-ar", "44100", "-b:a", "64k"]),
        AudioConvertFormat(title: "M4R 44100Hz 96kbs", ext: "m4r", options: ["-ar", "44100", "-b:a", "96k"]),
        AudioConvertFormat(title: "M4R 44100Hz 128kbs", ext: "m4r", options: ["-ar", "44100", "-b:a", "128k"]),
        AudioConvertFormat(title: "M4R 44100Hz 224kbs", ext: "m4r", options: ["-ar", "44100", "-b:a", "224k"]),
        AudioConvertFormat(title: "M4R 44100Hz 320kbs", ext: "m4r", options: ["-ar", "44100", "-b:a", "320k"]),
    ]),
    AudioConvertGroup(title: "MP3", formats: [
        AudioConvertFormat(title: "MP3 44100Hz 64kbs", ext: "mp3", options: ["-ar", "44100", "-b:a", "64k"]),
        AudioConvertFormat(title: "MP3 44100Hz 96kbs", ext: "mp3", options: ["-ar", "44100", "-b:a", "96k"]),
        AudioConvertFormat(title: "MP3 44100Hz 128kbs", ext: "mp3", options: ["-ar", "44100", "-b:a", "128k"]),
        AudioConvertFormat(title: "MP3 44100Hz 224kbs", ext: "mp3", options: ["-ar", "44100", "-b:a", "224k"]),
        AudioConvertFormat(title: "MP3 44100Hz 256kbs", ext: "mp3", options: ["-ar", "44100", "-b:a", "256k"]),
        AudioConvertFormat(title: "MP3 44100Hz 320kbs", ext: "mp3", options: ["-ar", "44100", "-b:a", "320k"]),
    ]),
    AudioConvertGroup(title: "WAV", formats: [
        AudioConvertFormat(title: "WAV 32000Hz", ext: "wav", options: ["-ar", "32000"]),
        AudioConvertFormat(title: "WAV 44100Hz", ext: "wav", options: ["-ar", "44100"]),
        AudioConvertFormat(title: "WAV 48000Hz", ext: "wav", options: ["-ar", "48000"])
    ])
]
