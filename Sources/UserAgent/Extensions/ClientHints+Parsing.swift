//
//  ClientHints+Parsing.swift
//  UserAgent
//

import Foundation

extension ClientHints {

    /// Reads the `Sec-CH-UA-*` headers of a request. Names are matched
    /// ignoring case; a browser that sends none yields ``isAvailable``
    /// false and every field nil.
    public static func parse(headers: [String: String]) -> ClientHints {
        ClientHintsParsing.parse(headers: headers)
    }
}
