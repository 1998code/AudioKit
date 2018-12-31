//
//  AKFormantFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKFormantFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createFormantFilterDSP(int nChannels, double sampleRate) {
    AKFormantFilterDSP *dsp = new AKFormantFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKFormantFilterDSP::InternalData {
    sp_fofilt *fofilt0;
    sp_fofilt *fofilt1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp decayDurationRamp;
};

AKFormantFilterDSP::AKFormantFilterDSP() : data(new InternalData) {
    data->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    data->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->attackDurationRamp.setTarget(defaultAttackDuration, true);
    data->attackDurationRamp.setDurationInSamples(defaultRampDurationSamples);
    data->decayDurationRamp.setTarget(defaultDecayDuration, true);
    data->decayDurationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKFormantFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKFormantFilterParameterCenterFrequency:
            data->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKFormantFilterParameterAttackDuration:
            data->attackDurationRamp.setTarget(clamp(value, attackDurationLowerBound, attackDurationUpperBound), immediate);
            break;
        case AKFormantFilterParameterDecayDuration:
            data->decayDurationRamp.setTarget(clamp(value, decayDurationLowerBound, decayDurationUpperBound), immediate);
            break;
        case AKFormantFilterParameterRampDuration:
            data->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            data->attackDurationRamp.setRampDuration(value, _sampleRate);
            data->decayDurationRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKFormantFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKFormantFilterParameterCenterFrequency:
            return data->centerFrequencyRamp.getTarget();
        case AKFormantFilterParameterAttackDuration:
            return data->attackDurationRamp.getTarget();
        case AKFormantFilterParameterDecayDuration:
            return data->decayDurationRamp.getTarget();
        case AKFormantFilterParameterRampDuration:
            return data->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKFormantFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_fofilt_create(&data->fofilt0);
    sp_fofilt_init(sp, data->fofilt0);
    sp_fofilt_create(&data->fofilt1);
    sp_fofilt_init(sp, data->fofilt1);
    data->fofilt0->freq = defaultCenterFrequency;
    data->fofilt1->freq = defaultCenterFrequency;
    data->fofilt0->atk = defaultAttackDuration;
    data->fofilt1->atk = defaultAttackDuration;
    data->fofilt0->dec = defaultDecayDuration;
    data->fofilt1->dec = defaultDecayDuration;
}

void AKFormantFilterDSP::deinit() {
    sp_fofilt_destroy(&data->fofilt0);
    sp_fofilt_destroy(&data->fofilt1);
}

void AKFormantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(_now + frameOffset);
            data->attackDurationRamp.advanceTo(_now + frameOffset);
            data->decayDurationRamp.advanceTo(_now + frameOffset);
        }

        data->fofilt0->freq = data->centerFrequencyRamp.getValue();
        data->fofilt1->freq = data->centerFrequencyRamp.getValue();
        data->fofilt0->atk = data->attackDurationRamp.getValue();
        data->fofilt1->atk = data->attackDurationRamp.getValue();
        data->fofilt0->dec = data->decayDurationRamp.getValue();
        data->fofilt1->dec = data->decayDurationRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_fofilt_compute(sp, data->fofilt0, in, out);
            } else {
                sp_fofilt_compute(sp, data->fofilt1, in, out);
            }
        }
    }
}
