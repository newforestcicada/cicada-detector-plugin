//
//  LowPassFilter.h
//  Cicada Hunt
//
//  Created by acr on 23/12/2012.
//  Copyright (c) 2012 University of Southampton. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

typedef struct {
	float xv0;
	float xv1;
	float yv0;
	float yv1;
	float GAIN;
	float RATIO;
} LowPassFilter;

LowPassFilter LowPassFilter_initialise(float GAIN, float RATIO);
void LowPassFilter_update(SInt16 sample, LowPassFilter* lowPassFilter);
