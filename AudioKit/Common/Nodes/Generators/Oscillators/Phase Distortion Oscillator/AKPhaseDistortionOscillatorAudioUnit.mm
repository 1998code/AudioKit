//
//  AKPhaseDistortionOscillatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKPhaseDistortionOscillatorAudioUnit.h"
#import "AKPhaseDistortionOscillatorDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKPhaseDistortionOscillatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKPhaseDistortionOscillatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFrequency:(float)frequency {
    _kernel.setFrequency(frequency);
}
- (void)setAmplitude:(float)amplitude {
    _kernel.setAmplitude(amplitude);
}
- (void)setPhaseDistortion:(float)phaseDistortion {
    _kernel.setPhaseDistortion(phaseDistortion);
}
- (void)setDetuningOffset:(float)detuningOffset {
    _kernel.setDetuningOffset(detuningOffset);
}
- (void)setDetuningMultiplier:(float)detuningMultiplier {
    _kernel.setDetuningMultiplier(detuningMultiplier);
}

- (void)setupWaveform:(int)size {
    _kernel.setupWaveform((uint32_t)size);
}
- (void)setWaveformValue:(float)value atIndex:(UInt32)index; {
    _kernel.setWaveformValue(index, value);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(PhaseDistortionOscillator)

    // Create a parameter object for the frequency.
    AUParameter *frequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"frequency"
                                              name:@"Frequency (Hz)"
                                           address:frequencyAddress
                                               min:0.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the amplitude.
    AUParameter *amplitudeAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amplitude"
                                              name:@"Amplitude"
                                           address:amplitudeAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the phaseDistortion.
    AUParameter *phaseDistortionAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"phaseDistortion"
                                              name:@"Pulse Width"
                                           address:phaseDistortionAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the detuningOffset.
    AUParameter *detuningOffsetAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"detuningOffset"
                                              name:@"Frequency offset (Hz)"
                                           address:detuningOffsetAddress
                                               min:-1000.0
                                               max:1000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the detuningMultiplier.
    AUParameter *detuningMultiplierAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"detuningMultiplier"
                                              name:@"Frequency detuning multiplier"
                                           address:detuningMultiplierAddress
                                               min:0.5
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    frequencyAUParameter.value = 440;
    amplitudeAUParameter.value = 1.0;
    phaseDistortionAUParameter.value = 0.0;
    detuningOffsetAUParameter.value = 0;
    detuningMultiplierAUParameter.value = 1;

    _kernel.setParameter(frequencyAddress,          frequencyAUParameter.value);
    _kernel.setParameter(amplitudeAddress,          amplitudeAUParameter.value);
    _kernel.setParameter(phaseDistortionAddress,         phaseDistortionAUParameter.value);
    _kernel.setParameter(detuningOffsetAddress,     detuningOffsetAUParameter.value);
    _kernel.setParameter(detuningMultiplierAddress, detuningMultiplierAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        frequencyAUParameter,
        amplitudeAUParameter,
        phaseDistortionAUParameter,
        detuningOffsetAUParameter,
        detuningMultiplierAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case frequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case amplitudeAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case phaseDistortionAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case detuningOffsetAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case detuningMultiplierAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(PhaseDistortionOscillator)
}

AUAudioUnitGeneratorOverrides(PhaseDistortionOscillator)

@end


