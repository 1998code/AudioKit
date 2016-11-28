//
//  AKBandRejectButterworthFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandRejectButterworthFilterAudioUnit_h
#define AKBandRejectButterworthFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKBandRejectButterworthFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;

@property double rampTime;

@end

#endif /* AKBandRejectButterworthFilterAudioUnit_h */
