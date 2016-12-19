//
//  AKStereoFieldLimiterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoFieldLimiterAudioUnit.h"
#import "AKStereoFieldLimiterDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKStereoFieldLimiterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKStereoFieldLimiterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setamount:(float)amount {
    _kernel.setamount(amount);
}


standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(StereoFieldLimiter)

    // Create a parameter object for the amount.
    AUParameter *amountAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"amount"
                                              name:@"Amount of limit"
                                           address:amountAddress
                                               min:0
                                               max:1
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    amountAUParameter.value = 0;

    _kernel.setParameter(amountAddress, amountAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        amountAUParameter
    ]];

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case amountAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };
    parameterTreeBlock(StereoFieldLimiter)
}

AUAudioUnitOverrides(StereoFieldLimiter)

@end


