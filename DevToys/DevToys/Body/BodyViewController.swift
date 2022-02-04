//
//  BodyViewController.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil

final class BodyViewController: NSViewController {
    private let placeholderView = NSPlaceholderView()
    private var contentViewController: NSViewController?
    
    private lazy var allToolsController = AllToolCollectionItemViewController()
    private lazy var JSONFormatterController = JSONFormatterViewController()
    private lazy var JSONYamlConverterController = JSONYamlConverterViewController()
    private lazy var numberBaseConverterController = NumberBaseConverterViewController()
    private lazy var HTMLDecoderController = HTMLDecoderViewController()
    private lazy var URLDecoderController = URLDecoderViewController()
    private lazy var base64DecoderController = Base64DecoderViewController()
    private lazy var jwtDecoderController = JWTDecoderViewController()
    private lazy var hashGeneratorController = HashGeneratorViewController()
    private lazy var uuidGeneratorController = UUIDGeneratorViewController()
    private lazy var loremIpsumGeneratorController = LoremIpsumGeneratorViewController()
    private lazy var textInspectorController = TextInspectorViewController()
    private lazy var imageOptimaizerController = ImageOptimaizerViewController()
    private lazy var pdfGeneratorController = PDFGeneratorViewController()
    private lazy var networkInfomationController = NetworkInfomationViewController()
    private lazy var regexTesterController = RegexTesterViewController()
    private lazy var checksumGeneratorController = ChecksumGeneratorViewController()
    
    private lazy var notImplementedController = NotImplementedViewController()
    
    override func loadView() {
        self.view = placeholderView
    }
    
    override func viewDidAppear() {
        appModel.$toolType
            .sink{[unowned self] toolType in
                switch toolType {
                case .allTools: self.replaceContentViewController(allToolsController)
                case .jsonYamlConvertor: self.replaceContentViewController(JSONYamlConverterController)
                case .jsonFormatter: self.replaceContentViewController(JSONFormatterController)
                case .numberBaseConvertor: self.replaceContentViewController(numberBaseConverterController)
                case .htmlDecoder: self.replaceContentViewController(HTMLDecoderController)
                case .urlDecoder: self.replaceContentViewController(URLDecoderController)
                case .base64Decoder: self.replaceContentViewController(base64DecoderController)
                case .jwtDecoder: self.replaceContentViewController(jwtDecoderController)
                case .hashGenerator: self.replaceContentViewController(hashGeneratorController)
                case .uuidGenerator: self.replaceContentViewController(uuidGeneratorController)
                case .leremIpsumGenerator: self.replaceContentViewController(loremIpsumGeneratorController)
                case .caseConverter: self.replaceContentViewController(textInspectorController)
                case .imageCompressor: self.replaceContentViewController(imageOptimaizerController)
                case .pdfGenerator: self.replaceContentViewController(pdfGeneratorController)
                case .networkInfomation: self.replaceContentViewController(networkInfomationController)
                case .regexTester: self.replaceContentViewController(regexTesterController)
                case .checksumGenerator: self.replaceContentViewController(checksumGeneratorController)
                default: self.replaceContentViewController(notImplementedController)
                }
            }
            .store(in: &objectBag)
    }
    
    private func replaceContentViewController(_ viewController: NSViewController) {
        self.contentViewController?.removeFromParent()
        self.addChild(viewController)
        self.contentViewController = viewController
        self.placeholderView.contentView = viewController.view
    }
}

final class NotImplementedViewController: NSViewController {
    class View: NSLoadView {
        let label = NSTextField(labelWithString: "Unimplemented")
        
        override func onAwake() {
            self.addSubview(label)
            self.label.snp.makeConstraints{ make in
                make.center.equalToSuperview()
            }
        }
    }
    
    override func loadView() { self.view = View() }
}
