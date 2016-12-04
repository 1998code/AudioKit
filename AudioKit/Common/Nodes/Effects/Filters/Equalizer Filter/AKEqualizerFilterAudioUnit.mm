//
//  AKEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKEqualizerFilterAudioUnit.h"
#import "AKEqualizerFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKEqualizerFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCenterFrequency:(float)centerFrequency {
    _kernel.setCenterFrequency(centerFrequency);
}
- (void)setBandwidth:(float)bandwidth {
    _kernel.setBandwidth(bandwidth);
}
- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {

    // Initialize a default format for the busses.
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create a parameter object for the centerFrequency.
    AUParameter *centerFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"centerFrequency"
                                              name:@"Center Frequency (Hz)"
                                           address:centerFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the bandwidth.
    AUParameter *bandwidthAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"bandwidth"
                                              name:@"Bandwidth (Hz)"
                                           address:bandwidthAddress
                                               min:0.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the gain.
    AUParameter *gainAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"gain"
                                              name:@"Gain (%)"
                                           address:gainAddress
                                               min:-100.0
                                               max:100.0
                                              unit:kAudioUnitParameterUnit_Percent
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    centerFrequencyAUParameter.value = 1000.0;
    bandwidthAUParameter.value = 100.0;
    gainAUParameter.value = 10.0;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(centerFrequencyAddress, centerFrequencyAUParameter.value);
    _kernel.setParameter(bandwidthAddress,       bandwidthAUParameter.value);
    _kernel.setParameter(gainAddress,            gainAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        centerFrequencyAUParameter,
        bandwidthAUParameter,
        gainAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKEqualizerFilterDSPKernel *filterKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        filterKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return filterKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case centerFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case bandwidthAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case gainAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(EqualizerFilter);

@end


