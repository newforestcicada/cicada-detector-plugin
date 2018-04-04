//
//  GoertzelFilter.c
//  Cicada Hunt
//
//  Created by acr on 23/12/2012.
//  Copyright (c) 2012 University of Southampton. All rights reserved.
//

#include <stdio.h>

#include "GoertzelFilter.h"

GoertzelFilter GoertzelFilter_initialise(int N, float centralFrequency, float samplingFreqency) {
	
	GoertzelFilter temp;

	temp.N = N;
	
	float bandpassWidth = 4.0 * samplingFreqency / (float)N;
	temp.k = 4.0 * centralFrequency / bandpassWidth;
	
	for ( int n=0; n<N; n++ ) {
		temp.hammingFactor[n] = 0.54 - 0.46 * cos(2*M_PI*n/(float)N);
	}
	
	temp.realW = 2.0*cos(2.0*M_PI*temp.k/(float)temp.N);

	
	temp.y = 0;
	temp.d1 = 0;
	temp.d2 = 0;
	
	temp.index = 0;
	
	temp.kalmanFilter = KalmanFilter_initialise(0.01, 5.0, 1.0, 1.0);

	return temp;
	
}

void GoertzelFilter_update(SInt16 sample, GoertzelFilter* goertzelFilter) {
	
	goertzelFilter->y = goertzelFilter->hammingFactor[goertzelFilter->index]*sample + goertzelFilter->realW*goertzelFilter->d1 - goertzelFilter->d2;
	goertzelFilter->d2 = goertzelFilter->d1;
	goertzelFilter->d1 = goertzelFilter->y;
	
	if ( goertzelFilter->index++ == goertzelFilter->N ) {
		
		goertzelFilter->index = 0;
		
		float amplitude = sqrt(goertzelFilter->d1*goertzelFilter->d1 + goertzelFilter->d2*goertzelFilter->d2 - goertzelFilter->d1*goertzelFilter->d2*goertzelFilter->realW);
		
		KalmanFilter_update(amplitude, &goertzelFilter->kalmanFilter);
		
		goertzelFilter->y = 0;
		goertzelFilter->d1 = 0;
		goertzelFilter->d2 = 0;
		
	}
	
}

float GoertzelFilter_estimate(GoertzelFilter *goertzelFilter) {
	
	return KalmanFilter_estimate(&goertzelFilter->kalmanFilter);
	
}

