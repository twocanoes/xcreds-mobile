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
            LabeledOptional(key: "Access Token", value: token.accessToken)
            LabeledOptional(key: "ID Token", value: token.idToken)
            LabeledOptional(key: "Refresh Token", value: token.refreshToken)
            LabeledOptional(key: "Scope", value: token.scope)
            LabeledOptional(key: "Type", value: token.tokenType)
            LabeledOptional(key: "Expires in", value: token.expiresIn)
        }
    }
}
struct JWTDetailSection: View {
    var idToken: IDToken
    var body: some View {
        Section("JWT") {
            LabeledOptional(key: "email", value: idToken.email)
            LabeledOptional(key: "exp", value: idToken.exp)
            LabeledOptional(key: "family_name", value: idToken.family_name)
            LabeledOptional(key: "given_name", value: idToken.given_name)
            LabeledOptional(key: "iat", value: idToken.iat)
            LabeledOptional(key: "iss", value: idToken.iss)
            LabeledOptional(key: "name", value: idToken.name)
            LabeledOptional(key: "sub", value: idToken.sub)
            LabeledOptional(key: "unique_name", value: idToken.unique_name)
            LabeledOptional(key: "aud", value: idToken.aud)
        }
    }
}

#Preview {
    List {
        ResponseDetailSection(token: .preview)
        JWTDetailSection(idToken: .preview)
    }
}
