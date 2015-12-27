//
//  AKParameter.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/26/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// AKParameters are simply arguments that can be passed into AKComputedParameters
/// These could be numbers (floats, doubles, ints) or other operations themselves
/// Since parameters can be audio in mono or stereo format, the protocol 
/// requires that an AKParameter defines method to switch between stereo and mono
public protocol AKParameter: CustomStringConvertible {
    func toMono() -> AKOperation
    func toStereo() -> AKStereoOperation
}

/// Default Implementation methods
extension AKParameter {
    /// Most parameters are mono, so the default is just to return the parameter wrapped in a mono operation
    public func toMono() -> AKOperation {
        return AKOperation("\(self) ")
    }
    
    /// Most parameters are mono, so the dault is to duplicate the parameter in both stereo channels
    public func toStereo() -> AKStereoOperation {
        return AKStereoOperation("\(self) \(self) ")
    }
}

/// Doubles are valid AKParameters
extension Double: AKParameter {}

/// Floats are valid AKParameters
extension Float: AKParameter {}

/// Integers are valid AKParameters
extension Int: AKParameter {}
