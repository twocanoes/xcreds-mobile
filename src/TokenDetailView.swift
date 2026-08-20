//
//  TokenDetailView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/19/26.
//

import SwiftUI
import OIDCLite


enum FetchedToken {
    case prefetch
    case fetching
    case fetched(OIDCLite.TokenResponse)
    case failed(String)
}

struct FetchedTokenView: View {
    var status: FetchedToken
    var body: some View {
        switch status {
            case .prefetch:
                ContentUnavailableView("Ready", systemImage: "person.text.rectangle", description: Text("Fill out the OIDC settings and tap Fetch"))
            case .fetching:
                TokenDetailView(token: .placeholder)
                    .redacted(reason: .placeholder)
            case let .fetched(token):
                TokenDetailView(token: token)
            case let .failed(message):
                ContentUnavailableView(
                    "Error Fetching Tokens",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
        }
    }
}
struct TokenDetailView: View {
    var token: OIDCLite.TokenResponse
    var body: some View {
        List {
            labeledOptional(key: "Access Token", value: token.accessToken)
            labeledOptional(key: "ID Token", value: token.idToken)
            labeledOptional(key: "Refresh Token", value: token.refreshToken)
            labeledOptional(key: "Scope", value: token.scope)
            labeledOptional(key: "Type", value: token.tokenType)
            labeledOptional(key: "Expires in", value: token.expiresIn)
        }
        .navigationTitle("Token Details")
    }
    func labeledOptional(key: String, value: (some CustomStringConvertible)?) -> some View {
        if let value {
            LabeledContent(key, value: value.description)
        }
        else {
            LabeledContent(key) {
                Text("Not Available")
                    .foregroundStyle(.red)
            }
        }
    }
}

extension OIDCLite.TokenResponse {
    static var placeholder: OIDCLite.TokenResponse {
        OIDCLite.TokenResponse(accessToken: String(repeating: "x", count: 2208),
                               idToken: String(repeating: "y", count: 871),
                               refreshToken: String(repeating: "z", count: 1365),
                               expiresIn: 5190,
                               tokenType: "Bearer",
                               scope: "User.Read",
                               jsonDict: [:])
    }
}
#Preview("Success") {
    FetchedTokenView(status: .fetched(.placeholder))
}
#Preview("Missing Values") {
    FetchedTokenView(status: .fetched(OIDCLite.TokenResponse()))
}
#Preview("Fetching") {
    FetchedTokenView(status: .fetching)
}
#Preview("prefetch") {
    FetchedTokenView(status: .prefetch)
}
#Preview("Failure") {
    FetchedTokenView(status: .failed("Failure text"))
}

