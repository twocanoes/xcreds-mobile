//
//  JWTDetailView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/20/26.
//
import OIDCLite
import SwiftUI


struct ResponseDetailSection: View {
    var token: OIDCLite.TokenResponse
    var body: some View {
        Section("Response") {
            LabeledTextualView(title: "Access Token", value: token.accessToken)
            LabeledTextualView(title: "ID Token", value: token.idToken)
            LabeledTextualView(title: "Refresh Token", value: token.refreshToken)
            LabeledTextualView(title: "Scope", value: token.scope)
            LabeledTextualView(title: "Type", value: token.tokenType)
            LabeledTextualView(title: "Expires in", value: token.expiresIn)
        }
    }
}

struct JWTDetailSection: View {
    var idToken: IDToken
    var body: some View {
        Section("JWT") {
            LabeledTextualView(title: "Full Name", subtitle: "name", value: idToken.name)
            LabeledTextualView(title: "Last Name", subtitle: "family_name", value: idToken.family_name)
            LabeledTextualView(title: "Unique Name", subtitle: "unique_name", value: idToken.unique_name)
            LabeledTextualView(title: "Email Address", subtitle: "email", value: idToken.email)
            LabeledTextualView(title: "Issuer", subtitle: "iss", value: idToken.iss)
            LabeledTextualView(title: "Subject", subtitle: "sub", value: idToken.sub)
            LabeledTextualView(title: "Audience", subtitle: "aud", value: idToken.aud)
            LabeledTextualView(title: "Expiration Time", subtitle: "exp", value: idToken.exp)
            LabeledTextualView(title: "Issued At", subtitle: "iat", value: idToken.iat)
        }
    }
}

struct JWTCompleteDetailsSection: View {
    var info: [String: Any]
    var keys: [String] {
        Array(info.keys)
    }
    var body: some View {
        Section("JWT") {
            ForEach(keys, id: \.self) { key in
                LabeledTextualView(title: key, value: info[key])
            }
        }
    }

}

#if DEBUG
#Preview("JWT") {
    List {
        JWTDetailSection(idToken: .preview)
    }
}
#Preview("Combined") {
    List {
        ResponseDetailSection(token: .preview)
        JWTDetailSection(idToken: .preview)
    }
}
#endif
