//
//  AKMIDINode.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// A version of AKInstrument specifically targeted to instruments that
/// should be triggerable via MIDI or sequenced with the sequencer.
public class AKMIDINode: AKNode, AKMIDIListener {
    
    // MARK: - Properties
    
    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    /// Name of the instrument
    public var name = "AKMIDIInstrument"
    
    internal var internalNode: AKPolyphonicNode
    
    // MARK: - Initialization
    
    /// Initialize the MIDI node
    ///
    /// - parameter node: A polyphonic node that will be triggered via MIDI
    ///
    public init(node: AKPolyphonicNode) {
        internalNode = node
        super.init()
        avAudioNode = internalNode.avAudioNode
    }


    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    ///
    /// - parameter midiClient: A refernce to the midi client
    /// - parameter name: Name to connect with
    ///
    public func enableMIDI(midiClient: MIDIClientRef, name: String) {
        var result: OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    // MARK: - Handling MIDI Data
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 > 0) {
            internalNode.play(note: Int(data2), velocity: Int(data3))
        } else if Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 == 0 {
            internalNode.stop(note: Int(data2))
        } else if Int(status) == AKMIDIStatus.NoteOff.rawValue {
            internalNode.stop(note: Int(data2))
        }
    }
    
    /// Handle MIDI commands that come in externally
    ///
    /// - parameter note: MIDI Note number
    /// - parameter velocity: MIDI velocity
    /// - parameter channel: MIDI channel
    ///
    public func receivedMIDINoteOn(note: Int, velocity: Int, channel: Int) {
        if velocity > 0 {
            internalNode.play(note: note, velocity: velocity)
        } else {
            internalNode.stop(note: note)
        }
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
        let packetCount = Int(packetList.memory.numPackets)
        let packet = packetList.memory.packet as MIDIPacket
        var packetPointer: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
        packetPointer.initialize(packet)
        for _ in 0 ..< packetCount {
            let event = AKMIDIEvent(packet: packetPointer.memory)
            //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
            handleMIDI(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
            packetPointer = MIDIPacketNext(packetPointer)
        }
    }
}
