//
//  CicadaDetectorPlugin.h
//  Cicada Hunt
//
//  Created by acr on 20/12/2012.
//  Copyright (c) 2012 New Forest Cicada Project. All rights reserved.
//

#import <Cordova/CDV.h>
#import "CicadaDetector.h"

@interface CicadaDetectorPlugin : CDVPlugin

-(void)initialiseDetector:(CDVInvokedUrlCommand*)command;
-(void)startDetector:(CDVInvokedUrlCommand*)command;
-(void)stopDetector:(CDVInvokedUrlCommand*)command;
-(void)startWhiteNoise:(CDVInvokedUrlCommand*)command;
-(void)stopWhiteNoise:(CDVInvokedUrlCommand*)command;
-(void)startPlayBack:(CDVInvokedUrlCommand*)command;
-(void)stopPlayBack:(CDVInvokedUrlCommand*)command;
-(void)getAmplitude:(CDVInvokedUrlCommand*)command;
-(void)getCicada:(CDVInvokedUrlCommand*)command;
-(void)getInsects:(CDVInvokedUrlCommand*)command;
-(void)stopSurvey:(CDVInvokedUrlCommand*)command;
-(void)startSurvey:(CDVInvokedUrlCommand*)command;
-(void)getFrequencies:(CDVInvokedUrlCommand*)command;
-(void)writeRecording:(CDVInvokedUrlCommand*)command;
-(void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand*)command;

@end
