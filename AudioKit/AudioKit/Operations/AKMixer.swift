//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/19/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Mixer Node */
public class AKMixer: AKOperation {
    private let mixerAU = AVAudioMixerNode()
    
    /** Initialize the delay operation */
    public init(_ inputs: AKOperation...) {
        super.init()
        output = mixerAU
        AKManager.sharedInstance.engine.attachNode(output!)
        for input in inputs {
            connect(input)
        }
    }
    
    public func connect(input: AKOperation) {
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
}