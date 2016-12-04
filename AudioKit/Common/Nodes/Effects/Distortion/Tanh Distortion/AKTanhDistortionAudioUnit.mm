//
//  AKTanhDistortionAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKTanhDistortionAudioUnit.h"
#import "AKTanhDistortionDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKTanhDistortionAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKTanhDistortionDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setPregain:(float)pregain {
    _kernel.setPregain(pregain);
}
- (void)setPostgain:(float)postgain {
    _kernel.setPostgain(postgain);
}
- (void)setPostiveShapeParameter:(float)postiveShapeParameter {
    _kernel.setPostiveShapeParameter(postiveShapeParameter);
}
- (void)setNegativeShapeParameter:(float)negativeShapeParameter {
    _kernel.setNegativeShapeParameter(negativeShapeParameter);
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
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                                  channels:AKSettings.numberOfChannels];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);

        // Create a parameter object for the pregain.
    AUParameter *pregainAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"pregain"
                                              name:@"Pregain"
                                           address:pregainAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the postgain.
    AUParameter *postgainAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"postgain"
                                              name:@"Postgain"
                                           address:postgainAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the postiveShapeParameter.
    AUParameter *postiveShapeParameterAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"postiveShapeParameter"
                                              name:@"Positive Shape Parameter"
                                           address:postiveShapeParameterAddress
                                               min:-10.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the negativeShapeParameter.
    AUParameter *negativeShapeParameterAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"negativeShapeParameter"
                                              name:@"Negative Shape Parameter"
                                           address:negativeShapeParameterAddress
                                               min:-10.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    pregainAUParameter.value = 2.0;
    postgainAUParameter.value = 0.5;
    postiveShapeParameterAUParameter.value = 0.0;
    negativeShapeParameterAUParameter.value = 0.0;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(pregainAddress,                pregainAUParameter.value);
    _kernel.setParameter(postgainAddress,               postgainAUParameter.value);
    _kernel.setParameter(postiveShapeParameterAddress,  postiveShapeParameterAUParameter.value);
    _kernel.setParameter(negativeShapeParameterAddress, negativeShapeParameterAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        pregainAUParameter,
        postgainAUParameter,
        postiveShapeParameterAUParameter,
        negativeShapeParameterAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKTanhDistortionDSPKernel *distortionKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        distortionKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return distortionKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case pregainAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case postgainAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case postiveShapeParameterAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case negativeShapeParameterAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };
    
    _inputBus.init(defaultFormat, 8);
    self.inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeInput
                                                                  busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(TanhDistortion);

@end


