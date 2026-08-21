//
//  LabeledOptionalView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/20/26.
//

import SwiftUI

struct LabeledOptional<T: CustomStringConvertible>: View {
    var title: String
    var subtitle: String?
    var value: T?
    var body: some View {
        if let value {
            LabeledContent {
                Text(value.description)
                    .textSelection(.enabled)
            } label: {
                Text(title)
                if let subtitle {
                    Text(subtitle)
                }
            }
        }
        else {
            LabeledContent(title) {
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
        LabeledOptional(title: "Key", value: "Value")
        LabeledOptional(title: "Key", value: Optional<String>.none)
        LabeledOptional(title: "Title", subtitle: "Subtitle", value: "Value")
    }
}
