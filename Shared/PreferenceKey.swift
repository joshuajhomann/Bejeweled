//
//  PreferenceKey.swift
//  Bejeweled
//
//  Created by Joshua Homann
//

import SwiftUI

protocol DictionaryPreferenceKey: PreferenceKey where Value == [Key : DictionaryValue] {
    associatedtype Key: Hashable
    associatedtype DictionaryValue
}

extension DictionaryPreferenceKey {
    static var defaultValue: Value { [:] }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        nextValue().forEach { value[$0] = $1 }
    }
}

struct SquaresPreferenceKey: DictionaryPreferenceKey {
    typealias Key = Int
    typealias DictionaryValue = CGRect
}

