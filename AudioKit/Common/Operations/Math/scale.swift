//
//  scale.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {


    /// This scales from -1 to 1 to a range defined by a minimum and maximum point in the input and output domain.
    ///
    /// - returns: AKOperation
    /// - parameter minimum: Minimum value to scale to. (Default: 0)
    /// - parameter maximum: Maximum value to scale to. (Default: 1)
    ///
    public func scale(
        minimum minimum: AKParameter = 0,
        maximum: AKParameter = 1
        ) -> AKOperation {
            return AKOperation("(\(self) \(minimum) \(maximum) biscale)")
    }

}