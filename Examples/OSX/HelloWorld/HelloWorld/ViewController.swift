//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

class ViewController: NSViewController {

    let audiokit = AKManager.sharedInstance
    let oscillator = AKOscillator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audiokit.audioOutput = oscillator
        audiokit.start()
    }
    
    
    @IBAction func toggleSound(sender: NSButton) {
        if oscillator.amplitude >  0.5 {
            oscillator.amplitude = 0
            sender.title = "Play Sine Wave at 440Hz"
        } else {
            oscillator.amplitude = 1
            sender.title = "Stop Sine Wave at 440Hz"
        }
        sender.setNeedsDisplay()
    }

}

