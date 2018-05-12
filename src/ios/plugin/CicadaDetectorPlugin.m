//
//  CicadaDetectorPlugin.m
//  Cicada Hunt
//
//  Created by acr on 20/12/2012.
//  Copyright (c) 2012 New Forest Cicada Project. All rights reserved.
//

#import "CicadaDetectorPlugin.h"
#import "Insect.h"

@interface CicadaDetectorPlugin () {
    
    CicadaDetector *_cicadaDetector;
    
}

-(NSString*)createFormattedDateString;

@end

@implementation CicadaDetectorPlugin

-(NSString*)createFormattedDateString
{

    NSDateFormatter *formatter;
    NSString        *dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];

    dateString = [formatter stringFromDate:[NSDate date]];

    return dateString;

}


-(void)initialiseDetector:(CDVInvokedUrlCommand*)command
{
	
	[self.commandDelegate runInBackground:^{
        
        NSLog(@"Detector initialised.");
        
		_cicadaDetector = [CicadaDetector getInstance];
        
		BOOL success = [_cicadaDetector initialiseDetector];
        
		CDVPluginResult* pluginResult = nil;
        
		if ( success == YES ) {
            
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            
		} else {
            
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            
		}
        
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
	}];
	
}

-(void)startDetector:(CDVInvokedUrlCommand*)command
{
	
	[self.commandDelegate runInBackground:^{
        
        BOOL success = NO;
	
        if ( _cicadaDetector ) {
            
            NSLog(@"Detector started.");
            
            success = [_cicadaDetector startDetector];
            
            //if (success) {
            //    [_cicadaDetector startPlayBack];
            //}
                    
        }
        
        CDVPluginResult* pluginResult = nil;
        
        if ( success ) {
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        } else {
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
	
}

-(void)stopDetector:(CDVInvokedUrlCommand*)command
{

	BOOL success = NO;
	
	if ( _cicadaDetector ) {
		
		NSLog(@"Detector stopped.");
					
		success = [_cicadaDetector stopDetector];
		
	}
	
	CDVPluginResult* pluginResult = nil;
	
	if ( success ) {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

-(void)startWhiteNoise:(CDVInvokedUrlCommand*)command
{
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
		NSLog(@"White noise started");
	
		[_cicadaDetector startWhiteNose];
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

-(void)stopWhiteNoise:(CDVInvokedUrlCommand*)command
{
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
		NSLog(@"White noise stopped");
	
		[_cicadaDetector stopWhiteNoise];
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
		
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

-(void)startPlayBack:(CDVInvokedUrlCommand*)command
{
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
		NSLog(@"Play back started");
        
		[_cicadaDetector startPlayBack];
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

-(void)stopPlayBack:(CDVInvokedUrlCommand*)command
{
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
		NSLog(@"Play back stopped");
        
		[_cicadaDetector stopPlayBack];
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
		
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
    
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


-(void)getAmplitude:(CDVInvokedUrlCommand*)command
{
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
		NSNumber* amplitude = [_cicadaDetector getAmplitude];
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[amplitude doubleValue]];
	
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

-(void)getFrequencies:(CDVInvokedUrlCommand*)command
{
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
        NSArray* array = [_cicadaDetector getFrequencies];
        		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
		
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	
}

-(void)getInsects:(CDVInvokedUrlCommand *)command
{
	
    CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
        
        float value = [[_cicadaDetector getCicada] floatValue];
        
        NSError *jsonError;
        NSString *objectString = [NSString stringWithFormat:@"{ \"insect\": 0, \"name\": \"New Forest Cicada\", \"value\": %f }", value];
        NSData *objectData = [objectString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        NSArray *array = [NSArray arrayWithObject:dict];
        
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
		
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];    
    
}

-(void)startSurvey:(CDVInvokedUrlCommand*)command
{
    
    [_cicadaDetector startSurvey];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];  
    
}

-(void)stopSurvey:(CDVInvokedUrlCommand*)command
{
    
    NSArray *insectList = [_cicadaDetector stopSurvey];
    
    // Create the sonogram
    
    NSString *fileName = [[self createFormattedDateString] stringByAppendingString:@".png"];
    
    NSString *filePath = [ [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName ];
    
    NSURL *url = [ NSURL fileURLWithPath:filePath];
    
    int xPixels = 420;
    int yPixels = 160;
    
    @try {
        
        xPixels = [[command.arguments objectAtIndex:0] intValue];
    
        yPixels = [[command.arguments objectAtIndex:1] intValue];

    } @catch (NSException *e) {
        
        NSLog(@"Couldn't get sonogram dimensions. Using default values of %d,%d.",xPixels,yPixels);
        
    }

    NSString *sonogramString;
    
    NSString *serialisedSonogramString = [_cicadaDetector writeSonogramWithURL:url withX:xPixels andY:yPixels];
    
    if (serialisedSonogramString==nil) {
        sonogramString = @"none";
    } else {
        sonogramString = filePath;
    }
    
    // Return the JSON object
    
    NSString *returnString;
    
    switch ([insectList count]) {
        case 0:
            returnString = [NSString stringWithFormat:@"{ \"insects\" : [], \"keep_recording\" : false, \"message\" : 0, \"sonogram\" : \"%@\", \"serialised_sonogram\" : \"%@\" }",sonogramString,serialisedSonogramString];
            break;
        case 4:
            returnString = [NSString stringWithFormat:@"{ \"insects\" : [ %@, %@, %@, %@ ], \"keep_recording\" : true, \"message\" : 1, \"sonogram\" : \"%@\", \"serialised_sonogram\" : \"%@\" }",[insectList objectAtIndex:0],[insectList objectAtIndex:1],[insectList objectAtIndex:2],[insectList objectAtIndex:3],sonogramString,serialisedSonogramString];
            break;
        case 1:
            returnString = [NSString stringWithFormat:@"{ \"insects\" : [ %@ ], \"keep_recording\" : true, \"message\" : 2, \"sonogram\" : \"%@\", \"serialised_sonogram\" : \"%@\" }",[insectList objectAtIndex:0],sonogramString,serialisedSonogramString];
            break;
    }
    
    NSError *jsonError;
    NSData *objectData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: dict];
	
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

-(void)getCicada:(CDVInvokedUrlCommand*)command
{
	
    NSNumber* cicada = 0;
	
	CDVPluginResult* pluginResult = nil;
	
	if ( _cicadaDetector ) {
		
		cicada = [_cicadaDetector getCicada];
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[cicada doubleValue]];
		
	} else {
		
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		
	}
	
	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];    
    
}

-(void)writeRecording:(CDVInvokedUrlCommand*)command
{
	
	[self.commandDelegate runInBackground:^{
		
        int duration = 60;
        
        @try {
            
            duration = [[command.arguments objectAtIndex:0] intValue];
            
        } @catch (NSException *e) {
            
            NSLog(@"Couldn't get sonogram dimensions. Using default value of %d.",duration);
            
        }
		
		NSString *fileName = [[self createFormattedDateString] stringByAppendingString:@".wav"];
		
		NSLog(@"File : %@, Duration : %d",fileName,duration);

		NSString *filePath = [ [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName ];
	
		NSURL *url = [ NSURL fileURLWithPath:filePath];
	
		BOOL success = NO;
		
		if ( _cicadaDetector ) {
		
			success = [_cicadaDetector writeRecordingWithURL:url forDuration:duration];
		
		}

		CDVPluginResult* pluginResult = nil;
		
		if ( success ) {
			
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:filePath];
			
		} else {
			
			pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
			
		}
		
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
		
	}];
	
}

-(void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand*)command
{
    
    NSNumber* number = [command.arguments objectAtIndex:0];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [number intValue];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

@end
