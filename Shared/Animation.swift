//
//  Animation.swift
//  Bejeweled
//
//  Created by Joshua Homann
//

import SwiftUI

func animate(with factory: AnimationFactoryProtocol, operation: () -> Void) async -> Void {
    withAnimation(factory.animation) {
        operation()
    }
    try? await Task.sleep(nanoseconds: UInt64(factory.duration * 1e9))
}

protocol AnimationFactoryProtocol {
    var duration: TimeInterval { get }
    var animation: Animation { get }
}

struct AnimationFactory: AnimationFactoryProtocol {
    var duration: TimeInterval
    var animation: Animation
}

extension AnimationFactoryProtocol where Self == AnimationFactory {
    static func linear(duration: TimeInterval) -> AnimationFactoryProtocol {
        AnimationFactory(duration: duration, animation: .linear(duration: duration))
    }
    static func easeInOut(duration: TimeInterval) -> AnimationFactoryProtocol {
        AnimationFactory(duration: duration, animation: .easeInOut(duration: duration))
    }
}
