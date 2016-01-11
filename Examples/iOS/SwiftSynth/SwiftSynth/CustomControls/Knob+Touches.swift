//
//  Knob+Touches.swift
//  Synth UI Spike
//
//  Created by Matthew Fecher on 1/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

extension Knob {

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.locationInView(self)
            checkKnobBounds(touchPoint)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.locationInView(self)
            checkKnobBounds(touchPoint)
        }
    }

}