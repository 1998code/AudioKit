//
//  ModulatedDelay.cpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-03-17.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#include "ModulatedDelay.hpp"
#include "ModulatedDelay_Defines.h"

namespace AudioKitCore
{
    ModulatedDelay::ModulatedDelay(AKModulatedDelayType type)
    : effectType(type)
    , modFreqHz(1.0f)
    , modDepthFraction(0.0f)
    {
    }
    
    void ModulatedDelay::init(int channels, double sampleRate)
    {
        minDelayMs = kChorusMinDelayMs;
        maxDelayMs = kChorusMaxDelayMs;
        switch (effectType) {
            case kFlanger:
                minDelayMs = kFlangerMinDelayMs;
                maxDelayMs = kFlangerMaxDelayMs;
                modOscillator.waveTable.triangle();
                break;
            case kChorus:
            default:
                modOscillator.waveTable.sinusoid();
                break;
        }
        delayRangeMs = 0.5f * (maxDelayMs - minDelayMs);
        midDelayMs = 0.5f * (minDelayMs + maxDelayMs);
        leftDelayLine.init(sampleRate, maxDelayMs);
        rightDelayLine.init(sampleRate, maxDelayMs);
        leftDelayLine.setDelayMs(minDelayMs);
        rightDelayLine.setDelayMs(minDelayMs);
        modOscillator.init(sampleRate, modFreqHz);
    }
    
    void ModulatedDelay::deinit()
    {
        leftDelayLine.deinit();
        rightDelayLine.deinit();
        modOscillator.deinit();
    }
    
    void ModulatedDelay::setModFrequencyHz(float freq)
    {
        modOscillator.setFrequency(freq);
    }
    
    void ModulatedDelay::Render(unsigned channelCount, unsigned sampleCount,
                                float* inBuffers[], float *outBuffers[])
    {
        float *pInLeft   = inBuffers[0];
        float *pInRight  = inBuffers[1];
        float *pOutLeft  = outBuffers[0];
        float *pOutRight = outBuffers[1];
        
        for (int i=0; i < sampleCount; i++)
        {
            float modLeft, modRight;
            modOscillator.getSamples(&modLeft, &modRight);
            
            float leftDelayMs = midDelayMs + delayRangeMs * modDepthFraction * modLeft;
            float rightDelayMs = midDelayMs + delayRangeMs * modDepthFraction * modRight;
            switch (effectType) {
                case kFlanger:
                    leftDelayMs = minDelayMs + delayRangeMs * modDepthFraction * (1.0f + modLeft);
                    rightDelayMs = minDelayMs + delayRangeMs * modDepthFraction * (1.0f + modRight);
                    break;
                    
                case kChorus:
                default:
                    break;
            }
            leftDelayLine.setDelayMs(leftDelayMs);
            rightDelayLine.setDelayMs(rightDelayMs);
            
            float dryFraction = 1.0f - dryWetMix;
            *pOutLeft++ = dryFraction * (*pInLeft) + dryWetMix * leftDelayLine.push(*pInLeft);
            pInLeft++;
            if (channelCount > 1)
            {
                *pOutRight++ = dryFraction * (*pInRight) + dryWetMix * rightDelayLine.push(*pInRight);
                pInRight++;
            }
        }

    }
}
