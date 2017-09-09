//
//  AudioUnitBase.m
//  TryAVAudioEngine
//
//  Created by Andrew Voelkel on 11/19/16.
//  Copyright © 2016 Andrew Voelkel. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioUnitBase : AUAudioUnit

@property float rampTime;  // Do we really want this at this level?

/**
 Sets the parameter tree. The important piece here is that setting the parameter tree
 triggers the setup of the blocks for observer, provider, and string representation. See
 the .m file. There may be a better way to do what is needed here.
 */

- (void) setParameterTree: (AUParameterTree*) tree;

- (float) getParameterWithAddress:(AUParameterAddress)address;
- (void) setParameterWithAddress:(AUParameterAddress)address value:(AUValue)value;


// Add for compatibility with AKAudioUnit

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isSetUp;

// These three properties are what are in the Apple example code.

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@end

#ifdef __cplusplus

#import <algorithm>

/**
 Base class for DSPKernels. Many of the methods are virtual, because the base AudioUnit class
 does not know the type of the subclass at compile time.
 */

struct DspBase {
    
protected:
    
    /** From Apple Example code */
    int nChannels;
    /** From Apple Example code */
    double sampleRate;
    /** From Apple Example code */
    AudioBufferList* inBufferListPtr = nullptr;
    /** From Apple Example code */
    AudioBufferList* outBufferListPtr = nullptr;
    
    // To support AKAudioUnit functions
    bool _initialized = false;
    bool _playing = false;
    
public:
    
    /** The Render function. */
    virtual void process(uint32_t frameCount, uint32_t bufferOffset) {}
    
    /** Uses the ParameterAddress as a key */
    virtual void setParameter(uint64_t address, float value) {}
    
    /** Uses the ParameterAddress as a key */
    virtual float getParameter(uint64_t address) { return 0.0; }
    
    /** Get the DSP into initialized state */
    virtual void reset() {}
    
    virtual void setBuffers(AudioBufferList* inBufs, AudioBufferList* outBufs) {
        inBufferListPtr = inBufs;
        outBufferListPtr = outBufs;
    }
    
    virtual void init(int nChannels, double sampleRate) {
        this->nChannels = nChannels; this->sampleRate = sampleRate;
    }
    
    // Add for compatibility with AKAudioUnit
    virtual void start() { _playing = true; }
    virtual void stop() { _playing = false; }
    virtual bool isPlaying() { return _playing; }
    virtual bool isSetup() { return _initialized; }

    
    /**
     Handles the event list processing and rendering loop. Should be called from AU renderBlock
     From Apple Example code
     */
    void processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                           AURenderEvent const *events) {
        
        AUEventSampleTime now = AUEventSampleTime(timestamp->mSampleTime);
        AUAudioFrameCount framesRemaining = frameCount;
        AURenderEvent const *event = events;
        
        while (framesRemaining > 0) {
            // If there are no more events, we can process the entire remaining segment and exit.
            if (event == nullptr) {
                AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
                process(framesRemaining, bufferOffset);
                return;
            }
            
            // **** start late events late.
            auto timeZero = AUEventSampleTime(0);
            auto headEventTime = event->head.eventSampleTime;
            AUAudioFrameCount const framesThisSegment = AUAudioFrameCount(std::max(timeZero, headEventTime - now));
            
            // Compute everything before the next event.
            if (framesThisSegment > 0) {
                AUAudioFrameCount const bufferOffset = frameCount - framesRemaining;
                process(framesThisSegment, bufferOffset);
                
                // Advance frames.
                framesRemaining -= framesThisSegment;
                
                // Advance time.
                now += AUEventSampleTime(framesThisSegment);
            }
            
            performAllSimultaneousEvents(now, event);
        }
    }
    
private:
    
    
    /** From Apple Example code */
    void handleOneEvent(AURenderEvent const *event) {
        switch (event->head.eventType) {
            case AURenderEventParameter:
            case AURenderEventParameterRamp: {
                // AUParameterEvent const& paramEvent = event->parameter;
                // startRamp(paramEvent.parameterAddress, paramEvent.value, paramEvent.rampDurationSampleFrames);
                break;
            }
            case AURenderEventMIDI:
                // handleMIDIEvent(event->MIDI);
                break;
            default:
                break;
        }
    }
    
    /** From Apple Example code */
    void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event) {
        do {
            handleOneEvent(event);
            event = event->head.next;
            // While event is not null and is simultaneous (or late).
        } while (event && event->head.eventSampleTime <= now);
    }

};

#endif

