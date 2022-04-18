//
//  With.swift
//  Bejeweled
//
//  Created by Joshua Homann
//

import Foundation

func with<Value>(_ value: Value, update: (inout Value) throws -> Void) rethrows -> Value {
    var copy = value
    try update(&copy)
    return copy
}
