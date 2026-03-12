//
//  GracePeriod.swift
//  InAppKit
//
//  User-facing duration type for subscription memory grace periods.
//

import Foundation

public struct GracePeriod: Equatable, Sendable {
    public let duration: TimeInterval

    public init(duration: TimeInterval) {
        self.duration = duration
    }

    public static func hours(_ n: Int) -> GracePeriod {
        GracePeriod(duration: TimeInterval(n) * 3600)
    }

    public static func days(_ n: Int) -> GracePeriod {
        GracePeriod(duration: TimeInterval(n) * 86400)
    }

    public static func weeks(_ n: Int) -> GracePeriod {
        GracePeriod(duration: TimeInterval(n) * 604800)
    }

    public static let none = GracePeriod(duration: 0)
}
