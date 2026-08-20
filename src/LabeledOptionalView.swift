//
//  LabeledOptionalView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/20/26.
//

import SwiftUI

struct LabeledOptional<T: CustomStringConvertible>: View {
    var key: String
    var value: T?
    var body: some View {
        if let value {
            LabeledContent(key, value: value.description)
                .textSelection(.enabled)
        }
        else {
            LabeledContent(key) {
                Text("Not Available")
                    .foregroundStyle(.red)
            }
        }
    }
}
extension StringOrArray: CustomStringConvertible {
    var description: String {
        switch self {
            case .array(let a):
                return a.joined(separator: " ")
            case .string(let str):
                return str
        }
    }
}

#Preview(traits:.fixedLayout(width: 300, height: 300)) {
    List {
        LabeledOptional(key: "Key", value: "Value")
        LabeledOptional(key: "Key", value: Optional<String>.none)
    }
}
