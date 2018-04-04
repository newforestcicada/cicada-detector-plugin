//
//  CicadaDetector.h
//  Cicada Hunt
//
//  Created by acr on 18/12/2012.
//  Copyright (c) 2012 University of Southampton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CicadaDetector : NSObject

-(BOOL)initialiseDetector;
-(BOOL)startDetector;
-(BOOL)stopDetector;
-(void)startWhiteNose;
-(void)stopWhiteNoise;
-(void)startPlayBack;
-(void)stopPlayBack;
-(void)startSurvey;
-(NSArray*)stopSurvey;
-(NSNumber*)getCicada;
-(NSArray*)getFrequencies;
-(NSNumber*)getAmplitude;
-(NSString*)writeSonogramWithURL:(NSURL*)url withX:(int)x andY:(int)y;
-(BOOL)writeRecordingWithURL:(NSURL*)url forDuration:(int)duration;

+(CicadaDetector*)getInstance;

@end

