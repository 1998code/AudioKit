//
//  AKStringResonatorAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKStringResonatorAudioUnit.h"
#import "AKStringResonatorDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKStringResonatorAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKStringResonatorDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setFundamentalFrequency:(float)fundamentalFrequency {
    _kernel.setFundamentalFrequency(fundamentalFrequency);
}
- (void)setFeedback:(float)feedback {
    _kernel.setFeedback(feedback);
}

standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(StringResonator)

    // Create a parameter object for the fundamentalFrequency.
    AUParameter *fundamentalFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"fundamentalFrequency"
                                              name:@"Fundamental Frequency (Hz)"
                                           address:fundamentalFrequencyAddress
                                               min:12.0
                                               max:10000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the feedback.
    AUParameter *feedbackAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"feedback"
                                              name:@"Feedback (%)"
                                           address:feedbackAddress
                                               min:0.0
                                               max:1.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    fundamentalFrequencyAUParameter.value = 100;
    feedbackAUParameter.value = 0.95;


    _kernel.setParameter(fundamentalFrequencyAddress, fundamentalFrequencyAUParameter.value);
    _kernel.setParameter(feedbackAddress,             feedbackAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        fundamentalFrequencyAUParameter,
        feedbackAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case fundamentalFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case feedbackAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

	parameterTreeBlock(StringResonator)
}

AUAudioUnitOverrides(StringResonator);

@end


