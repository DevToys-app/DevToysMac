//
//  Query.swift
//  CoreUtil
//
//  Created by yuki on 2020/01/13.
//  Copyright © 2020 yuki. All rights reserved.
//

/// 検索時のクエリを表す。検索時の処理を一般化することが目的
///
/// # 大まかな仕様
/// - 空クエリは全てにマッチ
/// - 大文字小文字を考慮せずに検索を行う
/// - 空白文字で区切った文字の全てにマッチするときにマッチする
///
/// # サンプル
/// ```
/// let query = Query("Hello World")
///
/// query.matches(to: "") // true
/// query.matches(to: "Hello whole new world.") // true
/// query.matches(to: "Hello swift.") // false
/// ```
public struct Query {
    
    /// 検索を行う要素
    let components: [String]
    
    /// 文字列で初期化
    public init(_ query: String) {
        self.components = query.components(separatedBy: .whitespaces)
            .map{ $0.lowercased() }
            .filter{ !$0.isEmpty }
    }
    /// 空クエリで初期化
    public init() {
        self.components = []
    }
    
    public var isEmpty: Bool { self.components.isEmpty }
    
    /// マッチ判定を行う。詳細は`Query`のDiscussionを参照。
    public func matches(to contents: String...) -> Bool {
        if self.components.isEmpty { return true }
        
        let contents = contents.map{ $0.lowercased() }
        
        return components.allSatisfy{ component in
            contents.contains{ $0.contains(component) }
        }
    }
}
