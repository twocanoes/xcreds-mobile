//
//  XCredsError.swift
//  XCreds Mobile
//
//  Created by Steve Brokaw on 5/4/26.
//

import Foundation

struct XCredsError: LocalizedError {
    init(_ errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
    let errorDescription: String?
}
