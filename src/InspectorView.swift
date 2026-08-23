//
//  InspectorView.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 8/18/26.
//

import SwiftUI
import OIDCLite


let hasManagedSettings = false

struct _InspectorView: View {
    var body: some View {
        if hasManagedSettings {
            //AuthenticationView(loadPage: false)
        }
        else {
            InspectorView()
        }
    }
}

typealias Token = OIDCLite.TokenResponse
struct InspectorView: View {
    @State private var discoverURL: URL?
    @State private var clientID: String = ""
    @State private var clientSecret: String = ""
    @State private var redirectURI: URL?
    @State private var scopes: String = ""
    @State private var useROPG: Bool = true
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var resource: String = ""
    @State private var fetchResponse: FetchedToken = .prefetch
    @State private var idToken: IDToken?
    private var isButtonDisabled: Bool {
        if case .fetching = fetchResponse {
            return true
        }
        else {
            return false
        }
    }
    var body: some View {
        NavigationSplitView {
            VStack {
                Text("OIDC Settings")
                    .font(.title)
                Form {
                    TextField(value: $discoverURL, format: .url) {
                        Text("URL")
                    }
                    .onSubmit {
                        // check for nil URL
                    }
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    TextField("Client ID", text: $clientID, prompt: Text("Client ID"))
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    TextField("Client Secret", text: $clientSecret, prompt: Text("Client Secret (Optional)"))
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    TextField(value: $redirectURI, format: .url) {
                        Text("Redirect URI")
                    }
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    TextField("Scopes", text: $scopes, prompt: Text("Scopes"))
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    Toggle("Use ROPG", isOn: $useROPG)
                        .disabled(true)
                    if useROPG {
                        ROPGFields
                    }
                }
                .onChange(of: useROPG) { oldValue, newValue in
                    if newValue == false {
                        resource = ""
                        username = ""
                        password = ""
                    }
                }
                HStack {
                    Button("Reset") {
                        reset()
                    }
                    Spacer()
                    fetchButton
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 20)
                .buttonStyle(.bordered)
            }

        } detail: {
            FetchedTokenView(status: fetchResponse)
        }
        #if DEBUG
        .onAppear {
            try? prepopulate()
        }
        #endif
    }
    var fetchButton: some View {
        Button {
            if useROPG {
                fetchResponse = .fetching
                Task {
                    do {
                        if let response = try await submitROPG() {
                            fetchResponse = .fetched(response)
                        }
                        else {
                            //nil response?
                            TCSLogErrorWithMark("No error, but not")

                        }
                    }
                    catch let OIDCLiteError.authFailure(msg) {
                        fetchResponse =
                            .failed("Authentication Failure")
                        TCSLogErrorWithMark(msg)
                    }
                    catch let OIDCLiteError.tokenError(msg) {
                        fetchResponse =
                            .failed("Token Error")
                        TCSLogErrorWithMark(msg)
                    }
                    catch let error as OIDCLiteError {
                        fetchResponse = .failed(error.errorDescription ?? "Unknown error")
                    }
                    catch {
                        fetchResponse = .failed( "Unexpected error")
                        TCSLogErrorWithMark("Unknown error: \(error)")
                    }
                }
            }
        } label: {
            if isButtonDisabled {
                Image(systemName: "progress.indicator")
                    .symbolEffect(.rotate)
            }
            else {
                Text("Fetch")
            }
        }
        .disabled(isButtonDisabled)
    }
    @ViewBuilder
    var ROPGFields: some View {
        TextField("Resource", text: $resource)
            .autocorrectionDisabled()
            .autocapitalization(.none)
        TextField("User Name", text: $username)
            .autocorrectionDisabled()
            .autocapitalization(.none)
        SecureField("Password", text: $password)
            .autocorrectionDisabled()
            .autocapitalization(.none)
    }
    func reset() {
        discoverURL = nil
        clientID = ""
        clientSecret = ""
        redirectURI = nil
        scopes = ""
        useROPG = true
        username = ""
        password = ""
        resource = ""
        fetchResponse = .prefetch
    }
    func submitROPG() async throws -> OIDCLite.TokenResponse? {
        guard let discoveryURLStr = discoverURL?.absoluteString,
              let redirectURIStr = redirectURI?.absoluteString else { return nil }
        let scopesArray: [String]?
        if scopes.isEmpty { scopesArray = nil }
        else { scopesArray = scopes.components(separatedBy: " ") }
        let obj = OIDCLite(
            discoveryURL: discoveryURLStr,
            clientID: clientID,
            clientSecret: clientSecret,
            redirectURI: redirectURIStr,
            scopes: scopesArray,
            resource: resource)
        do {
            try await obj.getEndpoints()
            return try await obj.requestTokenWithROPG(username: username, password: password, basicAuth: false, overrideErrors: nil)
        }
        catch let error as OIDCLiteError {
            print("Error: \(error.errorDescription ?? "No description")")
            return nil
        }
        catch {
            print("Unknown error: \(error)")
            return nil
        }
    }
}

#if DEBUG
extension InspectorView {
    func prepopulate() throws {
        guard let url = Bundle.main.url(forResource: "creds", withExtension: "plist")
               else {
            return
        }
        let data = try Data(contentsOf: url)
        let obj = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String : Any]
        discoverURL = URL(string: (obj["discoveryURL"] as? String) ?? "")
        clientID = (obj["clientID"] as? String) ?? ""
        clientSecret = (obj["clientSecret"] as? String) ?? ""
        redirectURI = URL(string: (obj["redirectURI"] as? String) ?? "")
        scopes = (obj["scopes"] as? String) ?? ""
        useROPG = (obj["useROPG"] as? Bool) ?? true
        username = (obj["username"] as? String) ?? ""
        password = (obj["password"] as? String) ?? ""
        resource = (obj["resource"] as? String) ?? ""
        fetchResponse = .prefetch
    }
}
#endif

#Preview {
    InspectorView()
}
