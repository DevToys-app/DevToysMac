//
//  Tool+Default.swift
//  DevToys
//
//  Created by yuki on 2022/02/13.
//

import CoreUtil

extension Tool {
    static let home = Tool(
        title: "tool.home.title".localized(), identifier: "home", category: .home, icon: R.Image.Tool.home,
        toolDescription: "tool.home.description".localized(), showAlways: true, showOnHome: false,
        viewController: HomeViewController()
    )
    static let settings = Tool(
        title: "Settings", identifier: "settings", category: .settings, icon: R.Image.Tool.settings,
        toolDescription: "Setting of application", showAlways: true, showOnHome: true, showOnSidebar: false,
        viewController: SettingViewController()
    )
    
    // MARK: - Converters -
    static let jsonYamlConverter = Tool(
        title: "tool.jsonyaml.title".localized(), identifier: "jsonyaml", category: .converter, icon: R.Image.Tool.jsonConvert,
        sidebarTitle: "tool.jsonyaml.mintitle".localized(), toolDescription: "tool.jsonyaml.description".localized(),
        viewController: JSONYamlConverterViewController()
    )
    static let numberBaseConverter = Tool(
        title: "tool.numbase.title".localized(), identifier: "numbase", category: .converter, icon: R.Image.Tool.numberBaseConvert,
        sidebarTitle: "tool.numbase.mintitle".localized(), toolDescription: "tool.numbase.description".localized(),
        viewController: NumberBaseConverterViewController()
    )
    static let dateConverter = Tool(
        title: "tool.date.title".localized(), identifier: "date.converter", category: .converter, icon: R.Image.Tool.dateConvert,
        sidebarTitle: "tool.date.mintitle".localized(), toolDescription: "tool.date.description".localized(),
        viewController: DateConverterViewController()
    )
    
    // MARK: - Encoder / Decoder -
    static let htmlCoder = Tool(
        title: "tool.html.title".localized(), identifier: "html.converter", category: .encoderDecoder, icon: R.Image.Tool.htmlCoder,
        sidebarTitle: "tool.html.mintitle".localized(), toolDescription: "tool.html.description".localized(),
        viewController: HTMLDecoderViewController()
    )
    static let urlCoder = Tool(
        title: "tool.url.title".localized(), identifier: "url.converter", category: .encoderDecoder, icon: R.Image.Tool.urlCoder,
        sidebarTitle: "tool.url.mintitle".localized(), toolDescription: "tool.url.description".localized(),
        viewController: URLDecoderViewController()
    )
    static let base64Coder = Tool(
        title: "tool.base64.title".localized(), identifier: "base64.converter", category: .encoderDecoder, icon: R.Image.Tool.base64Coder,
        sidebarTitle: "tool.base64.mintitle".localized(), toolDescription: "tool.base64.description".localized(),
        viewController: Base64DecoderViewController()
    )
    static let jwtCoder = Tool(
        title: "tool.jwt.title".localized(), identifier: "jwt.converter", category: .encoderDecoder, icon: R.Image.Tool.jwtCoder,
        sidebarTitle: "tool.jwt.mintitle".localized(), toolDescription: "tool.jwt.description".localized(),
        viewController: JWTDecoderViewController()
    )
    
    // MARK: - Formatter -
    static let jsonFormatter = Tool(
        title: "tool.jsonformat.title".localized(), identifier: "json.formatter", category: .formatter, icon: R.Image.Tool.jsonFormatter,
        sidebarTitle: "tool.jsonformat.mintitle".localized(), toolDescription: "tool.jsonformat.description".localized(),
        viewController: JSONFormatterViewController()
    )
    static let xmlFormatter = Tool(
        title: "tool.xmlformat.title".localized(), identifier: "xml.formatter", category: .formatter, icon: R.Image.Tool.xmlFormatter,
        sidebarTitle: "tool.xmlformat.mintitle".localized(), toolDescription: "tool.xmlformat.description".localized(),
        viewController: XMLFormatterViewController()
    )
    
    // MARK: - Generators -
    static let hashGenerator = Tool(
        title: "tool.hashgen.title".localized(), identifier: "hash.generator", category: .generator, icon: R.Image.Tool.hashGenerator,
        sidebarTitle: "tool.hashgen.mintitle".localized(), toolDescription: "tool.hashgen.description".localized(),
        viewController: HashGeneratorViewController()
    )
    static let uuidGenerator = Tool(
        title: "tool.uuidgen.title".localized(), identifier: "uuid.generator", category: .generator, icon: R.Image.Tool.uuidGenerator,
        sidebarTitle: "tool.uuidgen.mintitle".localized(), toolDescription: "tool.uuidgen.description".localized(),
        viewController: UUIDGeneratorViewController()
    )
    static let loremIpsumGenerator = Tool(
        title: "tool.ligen.title".localized(), identifier: "loremIpsum.generator", category: .generator, icon: R.Image.Tool.loremIpsumGenerator,
        sidebarTitle: "tool.ligen.mintitle".localized(), toolDescription: "tool.ligen.description".localized(),
        viewController: LoremIpsumGeneratorViewController()
    )
    static let checksumGenerator = Tool(
        title: "tool.checksum.title".localized(), identifier: "checksum.generator", category: .generator, icon: R.Image.Tool.hashGenerator,
        sidebarTitle: "tool.checksum.mintitle".localized(), toolDescription: "tool.checksum.description".localized(),
        viewController: ChecksumGeneratorViewController()
    )
    
    // MARK: - Text -
    static let textInspector = Tool(
        title: "tool.textinspect.title".localized(), identifier: "textinspect", category: .text, icon: R.Image.Tool.textInspector,
        sidebarTitle: "tool.textinspect.mintitle".localized(), toolDescription: "tool.textinspect.description".localized(),
        viewController: TextInspectorViewController()
    )
    static let regexTester = Tool(
        title: "tool.regex.title".localized(), identifier: "regex", category: .text, icon: R.Image.Tool.regexTester,
        sidebarTitle: "tool.regex.mintitle".localized(), toolDescription: "tool.regex.description".localized(),
        viewController: RegexTesterViewController()
    )
    static let hyphenationRemover = Tool(
        title: "tool.hyphenremove.title".localized(), identifier: "hyphenremove", category: .text, icon: R.Image.Tool.textInspector,
        sidebarTitle: "tool.hyphenremove.mintitle".localized(), toolDescription: "tool.hyphenremove.description".localized(),
        viewController: HyphenationRemoverViewController()
    )
    
    // MARK: - Graphic -
    static let imageOptimizer = Tool(
        title: "tool.imageoptim.title".localized(), identifier: "imageoptim", category: .graphic, icon: R.Image.Tool.imageCompressor,
        sidebarTitle: "tool.imageoptim.mintitle".localized(), toolDescription: "tool.imageoptim.description".localized(),
        viewController: ImageOptimizerViewController()
    )
    static let pdfGenerator = Tool(
        title: "tool.pdfgen.title".localized(), identifier: "pdfgen", category: .graphic, icon: R.Image.Tool.pdfGenerator,
        sidebarTitle: "tool.pdfgen.mintitle".localized(), toolDescription: "tool.pdfgen.description".localized(),
        viewController: PDFGeneratorViewController()
    )
    static let imageConverter = Tool(
        title: "tool.imageconvert.title".localized(), identifier: "imageconvert", category: .graphic, icon: R.Image.Tool.imageConverter,
        sidebarTitle: "tool.imageconvert.mintitle".localized(), toolDescription: "tool.imageconvert.description".localized(),
        viewController: ImageConverterViewController()
    )
}
