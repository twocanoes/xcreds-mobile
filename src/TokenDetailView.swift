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
                TokenDetailView(token: .placeholder, placeholder: IDToken.placeholder)
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
    var placeholder: IDToken? = nil
    var tokenDict: [String: Any] = [:]
    var jwt: IDToken? {
        if let placeholder { return placeholder }
        do {
            let creds = Creds(password: nil, tokens: token)
            guard let info = try TokenManager().tokenInfo(fromCredentials: creds) else { return nil }
            let token: IDToken? = info["idToken"] as? IDToken
            return token
        }
        catch {
            return nil
        }
    }
    var body: some View {
        List {
            if let jwt {
                JWTDetailSection(idToken: jwt)
            }
            ResponseDetailSection(token: token)
        }
        .navigationTitle("Token Details")
    }
}

extension IDToken {
    static var placeholder: IDToken {
        IDToken(
            iss: "12345678",
            sub: "12345678",
            aud: .string("12345678"),
            iat: 1000,
            exp: 1000,
            email: "12345678",
            unique_name: "12345678",
            given_name: "12345678",
            family_name: "12345678",
            name: "12345678"
        )
    }
}
extension OIDCLite.TokenResponse {
    static var placeholder: OIDCLite.TokenResponse {
        OIDCLite.TokenResponse(accessToken: String(repeating: "x", count: 2208),
                               idToken: String(repeating: "y", count: 871),
                               refreshToken: String(repeating: "z", count: 1365),
                               expiresIn: 0000,
                               tokenType: "Bearer",
                               scope: "User.Read",
                               jsonDict: [:])
    }
}

#if DEBUG
#Preview("Success") {
    FetchedTokenView(status: .fetched(.preview))
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
#endif
