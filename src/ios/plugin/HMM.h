//
//  HMM.h
//  Cicada Hunt
//
//  Created by acr on 05/05/2013.
//  Copyright (c) 2013 University of Southampton. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_FEATURE_LENGTH  1024
#define NUMBER_OF_STATES    5
#define NUMBER_OF_FEATURES  2

@interface HMM : NSObject

+(NSArray*)classifyWithFeatures:(float[MAX_FEATURE_LENGTH][NUMBER_OF_FEATURES])features andLength:(int)length;

@end
