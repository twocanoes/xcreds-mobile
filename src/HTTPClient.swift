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
    // https://developer.apple.com/forums/thread/723418
    func postWebHook(url: URL, token: String, payload: [String: String]) {
        Task {
            do {
                let data = try JSONEncoder().encode(payload)
                let responseData = try await URLSession.shared.postRequest(to: url, data: data, authorization: token)
                guard !responseData.isEmpty,
                    let responseString = String(data: responseData, encoding: .utf8)
                else { return }
                TCSLogWithMark("Received webhook response: \(responseString)")
            } catch {
                TCSLogWithMark("Error posting webhook: \(error)")
            }
        }
    }
}

