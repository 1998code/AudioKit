//
//  mix.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// Mix together two parameters
///
/// - returns: AKOperation
/// - parameter first: First parameter
/// - parameter second: Second parameter
/// - parameter t: Value from zero to one indicating balance between first (0) and second (1) (Default: 0.5)
///
public func mix(first: AKParameter, _ second: AKParameter, t: AKParameter = 0.5) -> AKOperation {
    let firstRatio = 1 - t
    return AKOperation("(\(firstRatio * first) \(t * second) +)")
}