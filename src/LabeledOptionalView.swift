//
//  LabeledOptionalView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/20/26.
//

import SwiftUI


struct LabeledTextualView<T>: View {
    var title: String
    var subtitle: String?
    var value: Optional<T>
    var body: some View {
        LabeledContent {
            content
                .textSelection(.enabled)
        } label: {
            Text(title)
            if let subtitle {
                Text(subtitle)
            }
        }
    }
    @ViewBuilder
    var content: some View {
        if let value {
            textualContentView(unwrapped: value)
        }
        else {
            notAvailable
        }
    }
    @ViewBuilder
    func textualContentView(unwrapped: T) -> some View {
        switch unwrapped {
            case let str as String:
                Text(str)
            case let url as URL:
                Text(url.absoluteString)
            case let array as [String]:
                Text(array.joined(separator: ", "))
            case let strOrArr as StringOrArray:
                stringOrArrayView(content: strOrArr)
            case let i as Int:
                Text("\(i)")
            default:
                notAvailable
        }
    }
    func stringOrArrayView(content: StringOrArray) -> Text {
         return switch content {
            case .string(let str):
                 Text(str)
            case .array(let array):
                Text(array.joined(separator: ", "))
        }
    }
    var notAvailable: Text {
        Text("Not Available")
            .foregroundStyle(.red)
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
        LabeledTextualView(title: "Key", value: "Value")
        LabeledTextualView(title: "Nil Value", value: Optional<String>.none)
        LabeledTextualView(title: "Title", subtitle: "Subtitle", value: "String")
        LabeledTextualView(title: "Array", value: ["1", "2", "3"])
        LabeledTextualView(title: "String Or Array", subtitle: "String", value: StringOrArray.string("String inside"))
        LabeledTextualView(title: "String Or Array", subtitle: "array", value: StringOrArray.array(["1", "2", "3"]))
        LabeledTextualView(title: "Array", value: ["1", "2", "3"])
        LabeledTextualView(title: "URL", value: URL(string: "http://www.example.com/")!)
        LabeledTextualView(title: "UUID", subtitle: "Unavailable", value: UUID())
    }
}
