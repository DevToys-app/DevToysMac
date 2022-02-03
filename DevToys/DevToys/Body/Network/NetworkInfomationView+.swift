//
//  NetworkInfomationView+.swift
//  DevToys
//
//  Created by yuki on 2022/02/02.
//

import CoreUtil

final class NetworkInfomationViewController: ToolPageViewController {
    private let cell = NetworkInfomationView()
    private let reachability = try! Reachability()
    private let speedTest = NetworkSpeedTest()
    private let formatter = NumberFormatter() => {
        $0.maximumFractionDigits = 2
    }
    
    @Observable var testIsRunning = false
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.reachability.publisher
            .sink{[unowned self] in self.cell.statusLabel.stringValue = $0.connection.description }.store(in: &objectBag)
        self.$testIsRunning
            .sink{[unowned self] in
                self.cell.speedLabel.textColor = $0 ? .tertiaryLabelColor : .labelColor
                self.cell.restartButton.isEnabled = !$0
            }
            .store(in: &objectBag)
        
        self.cell.restartButton.actionPublisher
            .sink{[unowned self] in self.startSpeedCheck() }.store(in: &objectBag)
        
        let localIPAddress = getIFAddresses().first(where: { $0.count(where: { $0 == "." }) == 3 }) ?? "------"
        self.cell.ipaddressLabel.stringValue = localIPAddress
        self.speedTest.delegate = self
        self.startSpeedCheck()
    }
    
    private func startSpeedCheck() {
        if testIsRunning { return }
        testIsRunning = true
        speedTest.networkSpeedTestStart(UrlForTestSpeed: "https://fast.com")
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) {_ in
            self.speedTest.networkSpeedTestStop()
            self.testIsRunning = false
        }
    }
}

extension NetworkInfomationViewController: NetworkSpeedProviderDelegate {
    func networkSpeedUpdated(to megabytesPerSecond: CGFloat?) {
        DispatchQueue.main.async {[self] in
            guard let megabytesPerSecond = megabytesPerSecond else { return }
            let MbPerSec = megabytesPerSecond / 8
            let string = formatter.string(from: NSNumber(value: MbPerSec.native))!
            self.cell.speedLabel.stringValue = "\(string) Mbps"
        }
    }
}

final private class NetworkInfomationView: Page {
    let ipaddressLabel = NSTextField(labelWithString: "0.0.0.0")
    let statusLabel = NSTextField(labelWithString: "fetching...")
    let speedLabel = NSTextField(labelWithString: "0Mbps")
    let restartButton = NSButton(title: "Restart") => { $0.bezelStyle = .rounded }
    
    override func onAwake() {
        self.title = "Network Infomation"
        
        self.addSection(Section(title: "Infomation", items: [
            Area(icon: R.Image.ipaddress, title: "Local IP Address", control: ipaddressLabel),
            Area(icon: R.Image.networkStatus, title: "Status", control: statusLabel),
            Area(icon: R.Image.speed, title: "Network Speed", control: NSStackView() => {
                $0.addArrangedSubview(speedLabel)
                $0.addArrangedSubview(restartButton)
            }),
        ]))
        
        self.ipaddressLabel.isSelectable = true
        self.ipaddressLabel.font = .monospacedSystemFont(ofSize: R.Size.codeFontSize, weight: .regular)
    }
}
