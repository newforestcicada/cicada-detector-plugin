//
//  HMM.m
//  Cicada Hunt
//
//  Created by acr on 05/05/2013.
//  Copyright (c) 2013 University of Southampton. All rights reserved.
//

#import <math.h>

#import "HMM.h"
#import "Insect.h"
#import "DeviceType.h"

@implementation HMM

double normalpdf(double x, double mean, double variance)
{
    return sqrt( 0.5 / M_PI / variance ) * exp( - (x - mean) * (x - mean) / 2.0 / variance );
}

+(NSArray*)classifyWithFeatures:(float[MAX_FEATURE_LENGTH][NUMBER_OF_FEATURES])features andLength:(int)length
{

    double DISTRIBUTION_MEAN[NUMBER_OF_STATES][NUMBER_OF_FEATURES] = {
        {  0.75, 0.4 },
        {  0.75, 0.4 },
        {  8.0,  0.4 },
        {  8.0,  0.4 },
        {  2.5,  1.4 }  };
    
    double DISTRIBUTION_VARIANCE[NUMBER_OF_STATES][NUMBER_OF_FEATURES] =  {
        {  0.125, 0.125 },
        {  0.125, 0.125 },
        { 16.0,   0.125 },
        { 16.0,   0.125 },
        {  0.125, 0.125 } 	};
    
    if ( [DeviceType getDeviceType] == DEVICE_TYPE_IPHONE3 ) {
        
        DISTRIBUTION_MEAN[0][0] = 0.75;
        DISTRIBUTION_MEAN[1][0] = 0.75;
        DISTRIBUTION_MEAN[2][0] = 2.0;
        DISTRIBUTION_MEAN[3][0] = 2.0;
        
        DISTRIBUTION_VARIANCE[0][0] = 0.1;
        DISTRIBUTION_VARIANCE[1][0] = 0.1;
        DISTRIBUTION_VARIANCE[2][0] = 1.0;
        DISTRIBUTION_VARIANCE[3][0] = 1.0;
        
    }

    double TRANSITION_MATRIX[NUMBER_OF_STATES][NUMBER_OF_STATES] = {
        { 0.97,   0.01,   0.00,   0.01,   0.01 },
        { 0.01,   0.89,   0.10,   0.00,   0.00 },
        { 0.00,   0.50,   0.50,   0.00,   0.00 },
        { 0.01,   0.00,   0.00,   0.99,   0.01 },
        { 0.01,   0.00,   0.00,   0.00,   0.99 }   };
    
    double INITIAL_PROBABILITIES[NUMBER_OF_STATES] = { 0.25, 0.20, 0.05, 0.25, 0.25 };
        
    double T1[MAX_FEATURE_LENGTH][NUMBER_OF_STATES];
    int T2[MAX_FEATURE_LENGTH][NUMBER_OF_STATES];
    int Z[MAX_FEATURE_LENGTH];

    float silentValue = 0;
    float cicadaValue = 0;
    float darkBushCricketValue = 0;
    float roselsBushCricketValue = 0;
    
    @try {
    
        for (int i=0; i<length; i++) {
            
            // Calculate the emission probabilities
            
            double emissions[NUMBER_OF_STATES] = {[0 ... NUMBER_OF_STATES-1] = 1.0};

            for (int j=0; j<NUMBER_OF_STATES; j++) {
                for (int n=0; n<NUMBER_OF_FEATURES; n++) {
                    double mean = DISTRIBUTION_MEAN[j][n];
                    double variance = DISTRIBUTION_VARIANCE[j][n];
                    emissions[j] = emissions[j] * normalpdf((double)features[i][n],mean,variance);
                }
            }

            // Normalise them so that none is greater than 100 times another
            
            double max_emission = -1.0;
            for (int j=0; j<NUMBER_OF_STATES; j++) {
                max_emission = MAX(max_emission,emissions[j]);
            }

            max_emission = max_emission/100.0;
            
            for (int j=0; j<NUMBER_OF_STATES; j++) {
                emissions[j] = MAX(max_emission,emissions[j]);
            }
            
            // Enter the forward pass
            
            if (i==0) {
                
                // Initial step
                
                for (int j=0; j<NUMBER_OF_STATES; j++) {
                    T1[0][j] = log(INITIAL_PROBABILITIES[j]) + log(emissions[j]);
                    T2[0][j] = 0;
                }
                
            } else {
                
                // Subsequent steps
                
                for (int j=0; j<NUMBER_OF_STATES; j++) {
                    
                    T1[i][j] = -DBL_MAX;
                    
                    for (int k=0; k<NUMBER_OF_STATES; k++) {
                        
                        double value = T1[i-1][k] + log(TRANSITION_MATRIX[k][j]) + log(emissions[j]);
                        
                        if ( value > T1[i][j] ) {
                            T1[i][j] = value;
                            T2[i][j] = k;
                        }
                    
                    }
                
                }
                
            }

        }
        
        // Do the backward pass
        
        double value = -DBL_MAX;
        for (int j=0; j<NUMBER_OF_STATES; j++) {
            if (T1[length-1][j] > value) {
                value = T1[length-1][j];
                Z[length-1] = j;
            }
        }
        
        for (int i=length-1; i>0; i--) {
            Z[i-1] = T2[i][Z[i]];
        }
        
        // Count up the states
        
        for (int i=0; i<length; i++) {
            switch (Z[i]) {
                case 0:
                    silentValue++;
                    break;
                case 1:
                    darkBushCricketValue++;
                    break;
                case 2:
                    darkBushCricketValue++;
                    break;
                case 3:
                    cicadaValue++;
                    break;
                case 4:
                    roselsBushCricketValue++;
                    break;
            }
        }
        
        silentValue /= (float)length;
        cicadaValue /= (float)length;
        darkBushCricketValue /= (float)length;
        roselsBushCricketValue /=  (float)length;
    
    } @catch (NSException* e) {
        
        NSLog(@"Exception thrown in HMM code. Defaulting to safe sounds interesting case.");
        
        silentValue = 0.5;
        cicadaValue = 0.0;
        darkBushCricketValue = 0.0;
        roselsBushCricketValue = 0.0;
        
    }
    
    NSLog(@"HMM Output - Silent                : %f",silentValue);
    NSLog(@"HMM Output - New Forest Cicada     : %f",cicadaValue);
    NSLog(@"HMM Output - Dark Bush Cricket     : %f",darkBushCricketValue);
    NSLog(@"HMM Output - Roesel's Bush Cricket : %f",roselsBushCricketValue);

    // Calculate the return array
    
    NSMutableArray *array = [[NSMutableArray alloc] init];

    if (cicadaValue>0.20) {
        
        [array addObject:[[Insect alloc] initWithInsect:INSECT_TYPE_CICADA andValue:cicadaValue andFound:TRUE]];
        
    } else if (silentValue < 0.90) {
    
        [array addObject:[[Insect alloc] initWithInsect:INSECT_TYPE_CICADA andValue:cicadaValue andFound:(TRUE ? cicadaValue>0.20 : FALSE)]];
        [array addObject:[[Insect alloc] initWithInsect:INSECT_TYPE_DARK_BUSH_CRICKET andValue:darkBushCricketValue andFound:(TRUE ? darkBushCricketValue>0.20 : FALSE)]];
        [array addObject:[[Insect alloc] initWithInsect:INSECT_TYPE_ROESELS_BUSH_CRICKET andValue:roselsBushCricketValue andFound:(TRUE ? roselsBushCricketValue>0.20 : FALSE)]];
        [array addObject:[[Insect alloc] initWithInsect:INSECT_TYPE_NONE_OF_THESE andValue:0.0 andFound:FALSE]];
        
        [array sortUsingSelector:@selector(compare:)];
        
    }

    return array;
            
}

@end

