//
//  DIYSeqEngine.h
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#ifndef DIYSeqEngine_h
#define DIYSeqEngine_h
#pragma once
#import "AKAudioUnit.h"

typedef void (^AKCCallback)(void);

@interface AKDIYSeqEngine : AKAudioUnit
@property (nonatomic) float startPoint;
@property (nonatomic) AKCCallback loopCallback;

-(void)setTarget:(AudioUnit)target;
-(void)play;
-(void)stop;

@end

#endif /* DIYSeqEngine_h */
