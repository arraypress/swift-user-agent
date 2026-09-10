//
//  UserAgentBuilding.swift
//  UserAgent
//
//  The outgoing string, assembled once here instead of in every client.
//

import Foundation

/// Builds `product/version (+contact)`.
enum UserAgentBuilding {

    /// The string, with the product made a token and the contact made a URL.
    ///
    /// A product token cannot contain whitespace or slashes, so those become
    /// hyphens. A contact with `@` and no scheme is an email address and gets
    /// `mailto:`, so an operator can click it either way.
    static func string(product: String, version: String, contact: String?) -> String {
        let token = product
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "/", with: "-")
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: "-")
        let base = "\(token)/\(version.trimmingCharacters(in: .whitespaces))"
        guard let contact = contact?.trimmingCharacters(in: .whitespaces), !contact.isEmpty else {
            return base
        }
        let link = contact.contains("@") && !contact.contains(":") ? "mailto:\(contact)" : contact
        return "\(base) (+\(link))"
    }
}
