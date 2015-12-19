//
//  max.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 12/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation


/** Maximum of two operations
 
 - returns: AKOperation
 - parameter left: 1st operation
 - parameter right: 2nd operation
 */
public func max(left: AKOperation, _ right: AKOperation) -> AKOperation {
    return AKOperation("\(left)\(right)max")
}

/** Maximum of two operations
 
 - returns: AKOperation
 - parameter left: Constant Value
 - parameter right: Operation
 */
public func max(left: Double, _ right: AKOperation) -> AKOperation {
    return max(left.ak, right)
}

/** Maximum of two operations
 
 - returns: AKOperation
 - parameter left: Operation
 - parameter right: Constant Value
 */
public func max(left: AKOperation, _ right: Double) -> AKOperation {
    return max(left, right.ak)
}
