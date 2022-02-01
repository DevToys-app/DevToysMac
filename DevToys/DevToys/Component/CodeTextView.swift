//
//  CodeTextView.swift
//  DevToys
//
//  Created by yuki on 2022/01/29.
//

import CoreUtil
import Highlightr

final class TextView: NSLoadView {
    
    private class _TextView: NSTextView {
        let stringPublisher = PassthroughSubject<String, Never>()
        var sendingValue = false
        override var string: String {
            get { super.string } set { if !sendingValue { super.string = newValue } }
        }
        override func didChangeText() {
            self.sendingValue = true
            stringPublisher.send(string)
            self.sendingValue = false
        }
    }
    
    var string: String { get { textView.string } set { textView.string = newValue } }
    var stringPublisher: AnyPublisher<String, Never> { textView.stringPublisher.eraseToAnyPublisher() }
    
    var isEditable: Bool { get { textView.isEditable } set { textView.isEditable = newValue } }
    var isSelectable: Bool { get { textView.isSelectable } set { textView.isSelectable = newValue } }
    
    private let scrollView = _TextView.scrollableTextView()
    private lazy var textView = scrollView.documentView as! _TextView

    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        
        self.addSubview(scrollView)
        self.textView.allowsUndo = true
        self.textView.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        self.textView.backgroundColor = .quaternaryLabelColor
        self.textView.textContainerInset = [0, 4]
        self.scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
    }
}

final class CodeTextView: NSLoadView {
    
    var string: String { get { textView.string } set { textView.setString(newValue) } }
    var isEditable: Bool { get { textView.isEditable } set { textView.isEditable = newValue } }
    var isSelectable: Bool { get { textView.isSelectable } set { textView.isSelectable = newValue } }
    
    var language: Language = .json { didSet { textStorage.language = language.rawValue } }
    var contentInsets = NSSize.zero {
        didSet { textView?.textContainerInset = contentInsets }
    }
    var stringPublisher: AnyPublisher<String, Never> {
        textView.stringSubject.map{ self.textView.string }.eraseToAnyPublisher()
    }
    
    convenience init(language: Language) {
        self.init()
        setLanguage(language: language)
    }
    private func setLanguage(language: Language) {
        self.language = language
    }
    
    private var textView: _CodeTextView!
    private let highlightr = Highlightr()! => { highlightr in
        highlightr.setTheme(to: "vs2015")
        highlightr.theme.setCodeFont(.monospacedSystemFont(ofSize: 12, weight: .regular))
    }
    private lazy var textStorage = CodeAttributedString(highlightr: highlightr) => {
        $0.language = "Json"
    }
    
    override func onAwake() {
        self.wantsLayer = true
        self.layer?.cornerRadius = R.Size.corner
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: [0, 10000000])
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        textContainer.lineBreakMode = .byWordWrapping
        layoutManager.addTextContainer(textContainer)

        _CodeTextView.textContainer = textContainer
        let scrollView = _CodeTextView.scrollableTextView()
        _CodeTextView.textContainer = nil
        
        self.addSubview(scrollView)
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        let textView = scrollView.documentView as! _CodeTextView
        textView.allowsUndo = true
        self.textView = textView
        
        self.contentInsets = [0, 4]
        self.textView?.backgroundColor = .quaternaryLabelColor
    }
}
 
private class _CodeTextView: NSTextView {
    static var textContainer: NSTextContainer?
    
    let stringSubject = PassthroughSubject<Void, Never>()
    
    var sendingValue = false
    
    func setString(_ string: String) {
        if !sendingValue { self.string = string }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: _CodeTextView.textContainer)
    }
    
    override func didChangeText() {
        sendingValue = true
        stringSubject.send()
        sendingValue = false
    }
    
    override func insertText(_ value: Any, replacementRange: NSRange) {
        guard let string = value as? String, let selectedRange = self.selectedRanges.first?.rangeValue else { return super.insertText(value, replacementRange: replacementRange) }
        
        let singlePairs = ["(": (start: "(", end: ")"), "[": (start: "[", end: "]"), "{": (start: "{", end: "}")]
        let doublePaits = ["\"": (start: "\"", end: "\""), "'": (start: "'", end: "'")]
        
        func pairWords(_ pair: (start: String, end: String)) {
            let nsstring = self.string as NSString
            var selectedWord: String?
            objc_try({ selectedWord = nsstring.substring(with: selectedRange) }, catch: {_ in})
            guard let _selectedWord = selectedWord else {
                return
            }
            let word = pair.start + _selectedWord + pair.end
            super.insertText(word, replacementRange: replacementRange)
            super.setSelectedRange(NSRange(location: selectedRange.location + pair.start.count, length: selectedRange.length))
        }
        
        if let pair = singlePairs[string] { return pairWords(pair) }
        if let pair = doublePaits[string], selectedRange.length > 0 { return pairWords(pair) }
        
        if let selectedRange = self.selectedRanges.first?.rangeValue {
            let nsstring = self.string as NSString
            var _cursorChar: String?
            objc_try({ _cursorChar = nsstring.substring(with: NSRange(location: selectedRange.location - 1, length: 1)) }, catch: {_ in})
            guard let cursorChar = _cursorChar else { return super.insertText(string, replacementRange: replacementRange) }
            if cursorChar == "(", string == ")" { return moveRight(nil) }
            if cursorChar == "{", string == "}" { return moveRight(nil) }
            if cursorChar == "[", string == "]" { return moveRight(nil) }
        }
        
        super.insertText(string, replacementRange: replacementRange)
    }
    
    override func insertNewline(_ sender: Any?) {
        guard let selectedRange = self.selectedRanges.first?.rangeValue else { return super.insertNewline(sender) }
        
        let nsstring = self.string as NSString
        let cursorChar = nsstring.substring(with: NSRange(location: selectedRange.location - 1, length: 1))
        var cursorNextChar: String?
        
        objc_try { cursorNextChar = nsstring.substring(with: NSRange(location: selectedRange.location, length: 1)) } catch: {_ in}
        
        let (line, _) = self.getLine(nsstring, in: selectedRange)
        let indent = self.getIndentOfLine(line, spaceCount: 4)
                
        if (cursorChar == "{" && cursorNextChar == "}") || (cursorChar == "[" && cursorNextChar == "]") {
            self.insertText("\n" + String(repeating: "    ", count: indent+1) + "\n" + String(repeating: "    ", count: indent), replacementRange: selectedRange)
            self.moveUp(nil)
            self.moveToEndOfLine(nil)
        } else {
            self.insertText("\n" + String(repeating: "    ", count: indent), replacementRange: selectedRange)
        }
    }
    
    override func moveToBeginningOfLineAndModifySelection(_ sender: Any?) {
        guard let selectedRange = self.selectedRanges.first?.rangeValue else { return super.moveToBeginningOfLineAndModifySelection(sender) }
        
        let nsstring = self.string as NSString
        let (line, lineRange) = self.getLine(nsstring, in: selectedRange)
        let spaceCount = self.beginningLineWhiteSpaceCount(line)
        let spaceStartLocation = lineRange.location + spaceCount
        
        let isSpaces = selectedRange.location <= spaceStartLocation
        if isSpaces {
            super.moveToBeginningOfLineAndModifySelection(sender)
        } else {
            let lineCount = line.count(where: { $0 != "\n" })
            let range = NSRange(location: selectedRange.location + spaceCount - lineCount, length: lineCount - spaceCount)
            self.setSelectedRange(range)
        }
    }
    
    private func beginningLineWhiteSpaceCount(_ line: String) -> Int {
        var count = 0
        for c in line {
            if c == "\t" || c == " " { count += 1 } else { return count }
        }
        return count
    }
    
    private func getIndentOfLine(_ line: String, spaceCount: Int) -> Int {
        var indent = 0
        var space = 0
        
        for c in line {
            if c == "\t" { indent += 1 } else if c == " " { space += 1 } else {
                return indent
            }
            if space == spaceCount {
                indent += 1
                space = 0
            }
        }
        return indent
    }
    private func getLine(_ nsString: NSString, in range: NSRange) -> (String, NSRange) {
        var start = -1
        var end = -1
        nsString.getLineStart(&start, end: &end, contentsEnd: nil, for: range)
        let range = NSRange(location: start, length: end - start)
        var line: String?
        objc_try({ line = nsString.substring(with: range) }, catch: {_ in })
        return (line ?? "", range)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension CodeTextView {
    enum Language: String {
        case abnf = "abnf"
        case accesslog = "accesslog"
        case actionscript = "actionscript"
        case ada = "ada"
        case angelscript = "angelscript"
        case apache = "apache"
        case applescript = "applescript"
        case arcade = "arcade"
        case cpp = "cpp"
        case arduino = "arduino"
        case armasm = "armasm"
        case xml = "xml"
        case asciidoc = "asciidoc"
        case aspectj = "aspectj"
        case autohotkey = "autohotkey"
        case autoit = "autoit"
        case avrasm = "avrasm"
        case awk = "awk"
        case axapta = "axapta"
        case bash = "bash"
        case basic = "basic"
        case bnf = "bnf"
        case brainfuck = "brainfuck"
        case cal = "cal"
        case capnproto = "capnproto"
        case ceylon = "ceylon"
        case clean = "clean"
        case clojure = "clojure"
        case clojureRepl = "clojure-repl"
        case cmake = "cmake"
        case coffeescript = "coffeescript"
        case coq = "coq"
        case cos = "cos"
        case crmsh = "crmsh"
        case crystal = "crystal"
        case cs = "cs"
        case csp = "csp"
        case css = "css"
        case d = "d"
        case markdown = "markdown"
        case dart = "dart"
        case delphi = "delphi"
        case diff = "diff"
        case django = "django"
        case dns = "dns"
        case dockerfile = "dockerfile"
        case dos = "dos"
        case dsconfig = "dsconfig"
        case dts = "dts"
        case dust = "dust"
        case ebnf = "ebnf"
        case elixir = "elixir"
        case elm = "elm"
        case ruby = "ruby"
        case erb = "erb"
        case erlangRepl = "erlang-repl"
        case erlang = "erlang"
        case excel = "excel"
        case fix = "fix"
        case flix = "flix"
        case fortran = "fortran"
        case fsharp = "fsharp"
        case gams = "gams"
        case gauss = "gauss"
        case gcode = "gcode"
        case gherkin = "gherkin"
        case glsl = "glsl"
        case gml = "gml"
        case go = "go"
        case golo = "golo"
        case gradle = "gradle"
        case groovy = "groovy"
        case haml = "haml"
        case handlebars = "handlebars"
        case haskell = "haskell"
        case haxe = "haxe"
        case hsp = "hsp"
        case htmlbars = "htmlbars"
        case http = "http"
        case hy = "hy"
        case inform7 = "inform7"
        case ini = "ini"
        case irpf90 = "irpf90"
        case isbl = "isbl"
        case java = "java"
        case javascript = "javascript"
        case jbossCli = "jboss-cli"
        case json = "json"
        case julia = "julia"
        case juliaRepl = "julia-repl"
        case kotlin = "kotlin"
        case lasso = "lasso"
        case ldif = "ldif"
        case leaf = "leaf"
        case less = "less"
        case lisp = "lisp"
        case livecodeserver = "livecodeserver"
        case livescript = "livescript"
        case llvm = "llvm"
        case lsl = "lsl"
        case lua = "lua"
        case makefile = "makefile"
        case mathematica = "mathematica"
        case matlab = "matlab"
        case maxima = "maxima"
        case mel = "mel"
        case mercury = "mercury"
        case mipsasm = "mipsasm"
        case mizar = "mizar"
        case perl = "perl"
        case mojolicious = "mojolicious"
        case monkey = "monkey"
        case moonscript = "moonscript"
        case n1ql = "n1ql"
        case nginx = "nginx"
        case nimrod = "nimrod"
        case nix = "nix"
        case nsis = "nsis"
        case objectivec = "objectivec"
        case ocaml = "ocaml"
        case openscad = "openscad"
        case oxygene = "oxygene"
        case parser3 = "parser3"
        case pf = "pf"
        case pgsql = "pgsql"
        case php = "php"
        case plaintext = "plaintext"
        case pony = "pony"
        case powershell = "powershell"
        case processing = "processing"
        case profile = "profile"
        case prolog = "prolog"
        case properties = "properties"
        case protobuf = "protobuf"
        case puppet = "puppet"
        case purebasic = "purebasic"
        case python = "python"
        case q = "q"
        case qml = "qml"
        case r = "r"
        case reasonml = "reasonml"
        case rib = "rib"
        case roboconf = "roboconf"
        case routeros = "routeros"
        case rsl = "rsl"
        case ruleslanguage = "ruleslanguage"
        case rust = "rust"
        case sas = "sas"
        case scala = "scala"
        case scheme = "scheme"
        case scilab = "scilab"
        case scss = "scss"
        case shell = "shell"
        case smali = "smali"
        case smalltalk = "smalltalk"
        case sml = "sml"
        case sqf = "sqf"
        case sql = "sql"
        case stan = "stan"
        case stata = "stata"
        case step21 = "step21"
        case stylus = "stylus"
        case subunit = "subunit"
        case swift = "swift"
        case taggerscript = "taggerscript"
        case yaml = "yaml"
        case tap = "tap"
        case tcl = "tcl"
        case tex = "tex"
        case thrift = "thrift"
        case tp = "tp"
        case twig = "twig"
        case typescript = "typescript"
        case vala = "vala"
        case vbnet = "vbnet"
        case vbscript = "vbscript"
        case vbscriptHtml = "vbscript-html"
        case verilog = "verilog"
        case vhdl = "vhdl"
        case vim = "vim"
        case x86asm = "x86asm"
        case xl = "xl"
        case xquery = "xquery"
        case zephir = "zephir"
    }
}
