//
//  AUV3DemoAudioUnit.swift
//  AUV3Demo
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import AudioKit

class AUV3DemoAudioUnit: AKAUv3ExtensionAudioUnit, AKMIDIListener {

    var engine = AVAudioEngine()    // each unit needs it's own avaudioEngine
    var conductor = Conductor()     // remember to add Conductor.swift to auv3 target

    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        AKLog("initing auv3 demo unit")
        AudioKit.engine = engine    // AudioKit.engine needs to be set early on
        conductor.setupRoute()      // plug everything in once we have the engine

        do { //this is where the audio unit really starts firing up with the data it needs
            try engine.enableManualRenderingMode(.realtime, format: AudioKit.format, maximumFrameCount: 4096)
            try super.init(componentDescription: componentDescription, options: options)
            try setOutputBusArrays()
        } catch {
            AKLog("Could not init audio unit")
            throw error
        }

        conductor.start()           // once the au is ready to go, you can go ahead and start processing
        setParameterTree()          // init parameterTree for controls
        setInternalRenderingBlock() // set internal rendering block to actually handle the audio buffers
    }

    // MIDI Handling

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        conductor.playNote(noteNumber: noteNumber, velocity: velocity)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        conductor.stop(noteNumber: noteNumber)
    }

    private func setInternalRenderingBlock() {
        self._internalRenderBlock = { (actionFlags, timeStamp, frameCount, outputBusNumber, outputData, renderEvent, pullInputBlock) in
            if let event = renderEvent?.pointee {
                switch event.head.eventType {
                case .parameter:
                    AKLog("receiving parameter")
                case .parameterRamp:
                    AKLog("receiving parameter ramp")
                case .MIDI:
                    self.handleMIDI(midiEventPointer: event.MIDI)
                case .midiSysEx:
                    AKLog("receiving MIDI Sysex")
                @unknown default:
                    AKLog("receiving unknown render event")
                }
            }

            // this is the line that actually produces sound using the buffers, keep it at the end
            _ = self.engine.manualRenderingBlock(frameCount, outputData, nil)
            return noErr
        }
    }

    private func handleMIDI(midiEventPointer: AUMIDIEvent) {
        var rawMIDIEventList: AUMIDIEvent? = midiEventPointer
        var midiEvents = [AUMIDIEvent]()
        while rawMIDIEventList != nil {
            if let rawEvent = rawMIDIEventList {
                midiEvents.append(rawEvent)
                rawMIDIEventList = rawMIDIEventList!.next?.pointee.MIDI
            }
        } // i'm sorry you had to see that...
        for event in midiEvents {
            // if you've made it this far, howdy! handle the raw midi bytes however you need to
            let midiEvent = AKMIDIEvent(data: [event.data.0, event.data.1, event.data.2])
            if midiEvent.status?.type == .noteOn {
                if midiEvent.data[2] == 0 {
                    receivedMIDINoteOff(noteNumber: event.data.1, velocity: event.data.2, channel: midiEvent.channel ?? 0)
                } else {
                    receivedMIDINoteOn(noteNumber: event.data.1, velocity: event.data.2, channel: midiEvent.channel ?? 0)
                }
            } else if midiEvent.status?.type == .noteOff {
                receivedMIDINoteOff(noteNumber: event.data.1, velocity: event.data.2, channel: midiEvent.channel ?? 0)
            }
            AKLog("recd \(midiEvent.description)") //todo: handle all midi types of midi events
        }
    }

    func setParameterTree() {
        _parameterTree = conductor.parameterTree
    }
}
