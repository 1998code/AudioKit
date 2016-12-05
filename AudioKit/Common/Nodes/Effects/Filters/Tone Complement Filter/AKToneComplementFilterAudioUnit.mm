//
//  AKToneComplementFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKToneComplementFilterAudioUnit.h"
#import "AKToneComplementFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKToneComplementFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKToneComplementFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setHalfPowerPoint:(float)halfPowerPoint {
    _kernel.setHalfPowerPoint(halfPowerPoint);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(ToneComplementFilter)

    // Create a parameter object for the halfPowerPoint.
    AUParameter *halfPowerPointAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"halfPowerPoint"
                                              name:@"Half-Power Point (Hz)"
                                           address:halfPowerPointAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    halfPowerPointAUParameter.value = 1000.0;


    _kernel.setParameter(halfPowerPointAddress, halfPowerPointAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        halfPowerPointAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case halfPowerPointAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(ToneComplementFilter)
}

AUAudioUnitOverrides(ToneComplementFilter);

@end


