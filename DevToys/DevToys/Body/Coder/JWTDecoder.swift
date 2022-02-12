//
//  JWTDecoder.swift
//  DevToys
//
//  Created by yuki on 2022/02/01.
//

import CoreUtil

final class JWTDecoderViewController: PageViewController {
    private let cell = JWTDecoderView()
    
    @RestorableState("jwt.token") var token = defaultToken
    @RestorableState("jwt.header") var header = defaultHeader
    @RestorableState("jwt.payload") var payload = defaultPayload
    
    override func loadView() { self.view = cell }
    
    override func viewDidLoad() {
        self.$token
            .sink{[unowned self] in self.cell.tokenTextSection.string = $0 }.store(in: &objectBag)
        self.$header
            .sink{[unowned self] in self.cell.headerCodeSection.string = $0 }.store(in: &objectBag)
        self.$payload
            .sink{[unowned self] in self.cell.payloadCodeSection.string = $0 }.store(in: &objectBag)
        
        self.cell.tokenTextSection.stringPublisher
            .sink{[unowned self] in
                self.token = $0
                guard let (header, payload) = self.decodeJWT($0) else {
                    self.header = "[Decode Failed]"
                    self.payload = "[Decode Failed]"
                    return
                }
                
                self.header = header
                self.payload = payload
            }
            .store(in: &objectBag)
    }
    
    private func decodeJWT(_ token: String) -> (header: String, payload: String)? {
        let components = token.split(separator: ".").map{ String($0) }
        
        guard components.count == 3 else { print("not3"); return nil }
        guard let header = self.decodeBase64ToJson(components[0]) else { print("he"); return nil }
        guard let payload = self.decodeBase64ToJson(components[1]) else { print("pa"); return nil }
        
        return (header, payload)
    }
    
    private func decodeBase64ToJson(_ string: String) -> String? {
        guard let data = Data(base64Encoded: string) ?? Data(base64Encoded: string + "=") ?? Data(base64Encoded: string + "==") else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let json = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        return String(data: json, encoding: .utf8)
    }
}

final private class JWTDecoderView: Page {
    
    let tokenTextSection = TextViewSection(title: "JWT Token", options: .defaultInput)
    let headerCodeSection = CodeViewSection(title: "Header", options: .defaultOutput, language: .javascript)
    let payloadCodeSection = CodeViewSection(title: "Header", options: .defaultOutput, language: .javascript)
    
    override func onAwake() {
        self.title = "JWT Decoder"
        
        self.addSection(tokenTextSection)
        self.tokenTextSection.textView.snp.remakeConstraints{ make in
            make.height.equalTo(85)
        }
        self.addSection(headerCodeSection)
        self.headerCodeSection.textView.snp.remakeConstraints{ make in
            make.height.equalTo(100)
        }
        self.addSection(payloadCodeSection)
        self.payloadCodeSection.textView.snp.remakeConstraints{ make in
            make.height.equalTo(100)
        }
    }
}

private let defaultToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkFsaWNlIiwiYWdlIjoxNn0.Ir_wyzMjqDXeeaGWJVgdysutJ6C9E3MX11t38LD2K60"

private let defaultPayload = """
{
  "sub": "1234567890",
  "name": "Alice",
  "age": 16
}
"""

private let defaultHeader = """
{
  "alg": "HS256",
  "typ": "JWT"
}
"""
