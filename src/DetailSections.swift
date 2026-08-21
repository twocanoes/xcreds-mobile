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
            LabeledOptional(title: "Access Token", value: token.accessToken)
            LabeledOptional(title: "ID Token", value: token.idToken)
            LabeledOptional(title: "Refresh Token", value: token.refreshToken)
            LabeledOptional(title: "Scope", value: token.scope)
            LabeledOptional(title: "Type", value: token.tokenType)
            LabeledOptional(title: "Expires in", value: token.expiresIn)
        }
    }
}

struct JWTDetailSection: View {
    var idToken: IDToken
    var body: some View {
        Section("JWT") {
            LabeledOptional(title: "Full Name", subtitle: "name", value: idToken.name)
            LabeledOptional(title: "Last Name", subtitle: "family_name", value: idToken.family_name)
            LabeledOptional(title: "Unique Name", subtitle: "unique_name", value: idToken.unique_name)
            LabeledOptional(title: "Email Address", subtitle: "email", value: idToken.email)
            LabeledOptional(title: "Issuer", subtitle: "iss", value: idToken.iss)
            LabeledOptional(title: "Subject", subtitle: "sub", value: idToken.sub)
            LabeledOptional(title: "Audience", subtitle: "aud", value: idToken.aud)
            LabeledOptional(title: "Expiration Time", subtitle: "exp", value: idToken.exp)
            LabeledOptional(title: "Issued At", subtitle: "iat", value: idToken.iat)
        }
    }
}

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
