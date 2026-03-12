//
//  MemoryBackend.swift
//  InAppKit
//
//  Storage backend options for subscription memory.
//

import Foundation

public enum MemoryBackend: Sendable {
    case keychain
    case iCloud
}
