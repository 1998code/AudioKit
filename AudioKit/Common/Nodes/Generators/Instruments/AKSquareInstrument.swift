//
//  AKSquareInstrument.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKSquareInstrument: AKMidiInstrument{
    public init(voiceCount: Int) {
        super.init(voice: AKSquareWaveOscillator(), voiceCount: voiceCount)
    }
    public override func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        let frequency = Int(note).midiNoteToFrequency()
        let amplitude = Double(velocity)/127.0
        let voiceEntity = voices[voice] as! AKSquareWaveOscillator
        voiceEntity.frequency = frequency
        voiceEntity.amplitude = amplitude
        voiceEntity.start()
    }
    public override func stopVoice(voice: Int, note: UInt8, onChannel channel: UInt8) {
        let voiceEntity = voices[voice] as! AKSquareWaveOscillator
        voiceEntity.amplitude = 0
        voiceEntity.stop()
    }
    
    
}
