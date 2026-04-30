//
//  HTTPClient.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 4/30/26.
//

import Foundation

enum HTTPClientError: Error {
    case invalidResponse
    case badStatusCode(Int)
}
extension URLSession {
    func postRequest(to url: URL, data: Data, authorization: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = data
        
        guard case let (data, response as HTTPURLResponse) = try await self.data(for: request) else {
            throw HTTPClientError.invalidResponse
        }
        guard (200..<299).contains(response.statusCode) else {
            throw HTTPClientError.badStatusCode(response.statusCode)
        }
        return data
    }
    // TODO: both functions below need to post serial number and user id
    func postLoginMessage() {
        let message: [String: String] = [
            "event": "login"
        ]
        let auth = "Splunk CF179AE4-3C99-45F5-A7CC-3284AA91CF67"
        let url = URL(string: "http://192.168.1.86:8000")!
        Task {
            do {
                let data = try JSONEncoder().encode(message)
                let responseData = try await URLSession.shared.postRequest(to: url, data: data, authorization: auth)
                TCSLogWithMark("Received webhook response: \(String(data: responseData, encoding: .utf8) ?? "No data")")
            } catch {
                TCSLogWithMark("Error posting webhook: \(error)")
            }
        }
    }
    func postLogoutMessage() {
        let message: [String: String] = [
            "event": "logout"
        ]
        let auth = "Splunk CF179AE4-3C99-45F5-A7CC-3284AA91CF67"
        let url = URL(string: "http://192.168.1.86:8000")!
        Task {
            do {
                let data = try JSONEncoder().encode(message)
                let responseData = try await URLSession.shared.postRequest(to: url, data: data, authorization: auth)
                TCSLogWithMark("Received webhook response: \(String(data: responseData, encoding: .utf8) ?? "No data")")
            } catch {
                TCSLogWithMark("Error posting webhook: \(error)")
            }
        }
    }

}

