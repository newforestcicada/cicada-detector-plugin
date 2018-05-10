//
//  CicadaDetector.m
//  Cicada Hunt
//
//  Created by acr on 18/12/2012.
//  Copyright (c) 2012 University of Southampton. All rights reserved.
//

#import "CicadaDetector.h"

#import <AudioToolbox/AudioToolbox.h>

#import "HMM.h"
#import "DeviceType.h"
#import "LowPassFilter.h"
#import "GoertzelFilter.h"
#import "PlayBackBuffer.h"
#import "RecordingBuffer.h"

#import "NSData+MBBase64.h"

#define NUMBER_OF_GOERTZEL_FILTERS  20
#define NUMBER_OF_GOERTZEL_RATIOS  2

#define MAX_SURVEY_VALUES  1024

#define MIN_SURVEY_RECORDING_INTERVAL 0.075

#define ROESELS_RATIO_HIGH_FREQUENCY 16
#define CICADA_RATIO_HIGH_FREQUENCY 13
#define CICADA_RATIO_LOW_FREQUENCY 7

static float iPhone3_baseline[] = {95.6, 68.5, 60.6, 57.0, 55.4, 53.1, 51.8, 49.8, 53.6, 50.8, 50.9, 49.5, 44.8, 43.9, 43.2, 42.3, 42.8, 43.1, 43.9, 44.1};

static float iPhone4_baseline[] = {195.0, 155.2, 142.3, 136.3, 132.7, 128.7, 125.2, 120.7, 116.8, 112.7, 106.5, 93.8, 78.7, 72.7, 71.6, 48.1, 19.1, 48.5, 86.6, 114.2};

static float iPhone4s_baseline[] = {155.7, 110.1, 97.9, 91.0, 88.8, 83.7, 78.8, 73.5, 64.1, 53.0, 42.5, 42.3, 52.9, 58.0, 50.8, 34.3, 20.6, 19.3, 16.9, 12.3};

static float iPhone5_baseline[] = {133.6, 85.2, 75.6, 71.2, 66.8, 65.1, 61.2, 57.1, 51.9, 43.6, 30.9, 16.9, 24.5, 44.5, 50.2, 37.5, 39.5, 49.6, 59.1, 36.9};

typedef struct {
	AudioUnit rioUnit;
	AudioStreamBasicDescription asbd;
    bool playBack;
	bool whiteNoise;
	LowPassFilter lowPassFilter;
	GoertzelFilter goerztelFilters[NUMBER_OF_GOERTZEL_FILTERS];
	RecordingBuffer recordingBuffer;
    PlayBackBuffer playBackBuffer;
} DetectorState;

@interface CicadaDetector () {
    
    DetectorState _detectorState;
    
    float _baseline[NUMBER_OF_GOERTZEL_FILTERS];
    
    float _sonogram[MAX_SURVEY_VALUES][NUMBER_OF_GOERTZEL_FILTERS];
    float _ratios[MAX_SURVEY_VALUES][NUMBER_OF_GOERTZEL_RATIOS];
    
    double _surveyUpdateTime;
    
    int _surveyIndex;
    BOOL _surveyRecording;
    
    float _ratioScalingFactor;
    float _sonogramScalingFactor;
    
}

@end

static CicadaDetector *_cicadaDetector;

@implementation CicadaDetector

+(CicadaDetector*)getInstance
{
    
    if ( _cicadaDetector == nil ) {
        
        _cicadaDetector = [[CicadaDetector alloc] init];
        
    }
    
    return _cicadaDetector;
    
}

static BOOL CheckError(OSStatus error, const char *operation)
{
	
	if ( error == noErr ) {
		return NO;
	}
	
	char errorString[20];
	*(UInt32*)(errorString+1) = CFSwapInt32HostToBig(error);
	
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4]) ) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else {
		sprintf(errorString, "%d", (int)error);
	}
	
	NSLog(@"Error: %s (%s)", operation, errorString);
	
	return YES;
	
}

- (id)init
{
    
    self = [super init];
    
    if (self) {
        
        float* baselinePointer;
                
        if ( [DeviceType getDeviceType] == DEVICE_TYPE_IPHONE3 ) {
            
            NSLog(@"iPhone 3");
            
            _ratioScalingFactor = 1.5;
            
            _sonogramScalingFactor = 0.8;
            
            baselinePointer = iPhone3_baseline;
            
        } else if ( [DeviceType getDeviceType] == DEVICE_TYPE_IPHONE4 ) {
            
            NSLog(@"iPhone 4");
            
            _ratioScalingFactor = 0.5;
            
            _sonogramScalingFactor = 0.5;
            
            baselinePointer = iPhone4_baseline;
            
        } else if ( [DeviceType getDeviceType] == DEVICE_TYPE_IPHONE4S ) {
            
            NSLog(@"iPhone 4S");
            
            _ratioScalingFactor = 0.4;
            
            _sonogramScalingFactor = 0.4;
            
            baselinePointer = iPhone4s_baseline;
            
        } else if ( [DeviceType getDeviceType] == DEVICE_TYPE_IPHONE5 ) {

            NSLog(@"iPhone 5");
            
            _ratioScalingFactor = 0.4;
            
            _sonogramScalingFactor = 0.4;
            
            baselinePointer = iPhone5_baseline;
            
        } else {
        
            NSLog(@"iDevice");
            
            _ratioScalingFactor = 0.4;
            
            _sonogramScalingFactor = 0.4;
            
            baselinePointer = iPhone5_baseline;
                        
        }
        
        for ( int i=0; i<NUMBER_OF_GOERTZEL_FILTERS; i++) {
            _baseline[i] = baselinePointer[i];
        }
        
        _surveyIndex = 0;
        _surveyRecording = FALSE;
        
    }
    
    return self;
    
}

-(BOOL)initialiseDetector
{
	
	BOOL error;
	
	error = CheckError(AudioSessionInitialize(NULL, kCFRunLoopDefaultMode,MyInterruptionListener,&_detectorState.rioUnit),"Couldn't initialise the audio session");
	
	if ( error ) {
		return NO;
	}
    
    return YES;
	
}

-(BOOL)startDetector
{
	
	BOOL error;
    
    UInt32 category = kAudioSessionCategory_PlayAndRecord;
	
	error = CheckError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category),
	                   "Couldn't set the category on the audio session");
	
	if ( error ) {
		return NO;
	}
	
	UInt32 inputAvailable;
	UInt32 ui32PropertySize = sizeof(inputAvailable);
	
	error = CheckError(AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &ui32PropertySize, &inputAvailable), "Couldn't get current audio input available property");
	
	if ( error || !inputAvailable ) {
		return NO;
	}
    
	AudioComponentDescription audioCompDesc;
	audioCompDesc.componentType = kAudioUnitType_Output;
	audioCompDesc.componentSubType = kAudioUnitSubType_RemoteIO;
	audioCompDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
	audioCompDesc.componentFlags = 0;
	audioCompDesc.componentFlagsMask = 0;
	
	AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
	
	error = CheckError(AudioComponentInstanceNew(rioComponent, &_detectorState.rioUnit), "Couldn't get RIO unit instance");
	
	if ( error ) {
		return NO;
	}
	
	UInt32 oneFlag = 1;
	
	AudioUnitElement bus0 = 0;
	
	error = CheckError(AudioUnitSetProperty(_detectorState.rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, bus0, &oneFlag, sizeof(oneFlag)), "Couldn't enable RIO output");
	
	if ( error ) {
		return NO;
	}
	
	AudioUnitElement bus1 = 1;
	
	error = CheckError(AudioUnitSetProperty(_detectorState.rioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, bus1, &oneFlag, sizeof(oneFlag)), "Couldn't enable RIO input");
	
	if ( error ) {
		return NO;
	}
	
	AudioStreamBasicDescription myASBD;
	
	memset(&myASBD, 0, sizeof(myASBD));
	
	myASBD.mSampleRate = 44100;
	myASBD.mFormatID = kAudioFormatLinearPCM;
	myASBD.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
	myASBD.mBytesPerPacket = 2;
	myASBD.mFramesPerPacket = 1;
	myASBD.mBytesPerFrame = 2;
	myASBD.mChannelsPerFrame = 1;
	myASBD.mBitsPerChannel = 16;
	
	error = CheckError(AudioUnitSetProperty(_detectorState.rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, bus0, &myASBD, sizeof(myASBD)), "Couldn't set the ABSD for RIO on input scope/bus 0");
	
	if ( error ) {
		return NO;
	}
	
	error = CheckError(AudioUnitSetProperty(_detectorState.rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, bus1, &myASBD, sizeof(myASBD)), "Couldn't set the ABSD for RIO on output scope/bus 1");
	
	if ( error ) {
		return NO;
	}
	
	_detectorState.asbd = myASBD;
    _detectorState.playBack = false;
	_detectorState.whiteNoise = false;
    
    RecordingBuffer_initialise(&_detectorState.recordingBuffer);
    PlayBackBuffer_initialise(&_detectorState.playBackBuffer);
    
	_detectorState.lowPassFilter = LowPassFilter_initialise(1.404746361e+03, 0.9985762554);
    for ( int i=0; i<NUMBER_OF_GOERTZEL_FILTERS; i++) {
        _detectorState.goerztelFilters[i] = GoertzelFilter_initialise(128, 1000.0+(float)i*1000.0, 44100.0);
    }
	
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = InputModulatingRenderCallback;
	callbackStruct.inputProcRefCon = &_detectorState;
	
	error = CheckError(AudioUnitSetProperty(_detectorState.rioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, bus0, &callbackStruct, sizeof(callbackStruct)), "Couldn't set RIO's render callback on bus 0");
    
	if ( error ) {
		return NO;
	}
	
	error = CheckError(AudioSessionSetActive(true), "Couldn't set audio session active");
	
	if ( error ) {
		return NO;
	}
	
	error = CheckError(AudioUnitInitialize(_detectorState.rioUnit), "Couldn't initialise the RIO unit");
	
	if ( error ) {
		return NO;
	}
	
	error = CheckError(AudioOutputUnitStart(_detectorState.rioUnit), "Couldn't start the RIO unit");

	if ( error ) {
		return NO;
	}
    
	return YES;
	
}

-(BOOL)stopDetector
{
	
    BOOL error = CheckError(AudioOutputUnitStop(_detectorState.rioUnit), "Couldn't stop the RIO unit");
    
    if ( error ) {
        return NO;
    }
    
    return YES;
	
}

-(void)startWhiteNose
{
	_detectorState.whiteNoise = true;
}

-(void)stopWhiteNoise
{
	_detectorState.whiteNoise = false;
}

-(void)startPlayBack
{
    NSURL *url = [[NSBundle mainBundle] URLForResource: @"cicada" withExtension:@"wav"];
    //NSURL *url = [[NSBundle mainBundle] URLForResource: @"darkBushCricket" withExtension:@"wav"];
    PlayBackBuffer_loadAudio(&_detectorState.playBackBuffer, (CFURLRef)CFBridgingRetain(url));
    _detectorState.playBack = true;
}

-(void)stopPlayBack
{
    _detectorState.playBack = false;
}

-(NSNumber*)getAmplitude
{
	return [NSNumber numberWithFloat:_detectorState.lowPassFilter.yv1];	
}

-(NSNumber*)getCicada
{
	
	float low = GoertzelFilter_estimate(&_detectorState.goerztelFilters[CICADA_RATIO_LOW_FREQUENCY]);
	float high = GoertzelFilter_estimate(&_detectorState.goerztelFilters[CICADA_RATIO_HIGH_FREQUENCY]);
    
    float value = MAX(0.0,2.0/(1.0+exp(-_ratioScalingFactor*(high/low-1.0))) - 1.0);
	
    return [NSNumber numberWithFloat:value];
	
}

-(NSArray*)getFrequencies
{
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_GOERTZEL_FILTERS];
    
    BOOL updateSonogram = FALSE;
    
    double currentTime = CACurrentMediaTime();
    
    if ( currentTime - _surveyUpdateTime > MIN_SURVEY_RECORDING_INTERVAL ) {
        
        updateSonogram = TRUE;
        
        _surveyUpdateTime = currentTime;
        
    }
    
    for ( int i=0; i<NUMBER_OF_GOERTZEL_FILTERS; i++ ) {
        
        float value = MAX(0.0,2.0/(1.0+exp(-_sonogramScalingFactor*GoertzelFilter_estimate(&_detectorState.goerztelFilters[i])/_baseline[i])) - 1.0);
        
        [array addObject:[NSNumber numberWithFloat:value]];
        
        if (_surveyRecording & updateSonogram) {
            _sonogram[_surveyIndex][i] = value;
        }
        
    }
    
    if (_surveyRecording & updateSonogram) {
        
        float cicada_low = GoertzelFilter_estimate(&_detectorState.goerztelFilters[CICADA_RATIO_LOW_FREQUENCY]);
        float cicada_high = GoertzelFilter_estimate(&_detectorState.goerztelFilters[CICADA_RATIO_HIGH_FREQUENCY]);
        float roesels_high = GoertzelFilter_estimate(&_detectorState.goerztelFilters[ROESELS_RATIO_HIGH_FREQUENCY]);

        _ratios[_surveyIndex][0] = cicada_high/cicada_low;
        _ratios[_surveyIndex][1] = roesels_high/cicada_high;
        
        _surveyIndex++;
    
        if ( _surveyIndex >= MAX_SURVEY_VALUES) {
            _surveyRecording = FALSE;
        }
        
    }
    
    return array;
    
}

-(void)startSurvey
{
    _surveyIndex = 0;
    _surveyRecording = TRUE;
}

-(NSArray*)stopSurvey
{
    _surveyRecording = FALSE;
    
    return [HMM classifyWithFeatures:_ratios andLength:_surveyIndex];
        
}

-(NSString*)writeSonogramWithURL:(NSURL*)url withX:(int)x andY:(int)y;
{

    char* rgba = (char*)malloc(4*x*y);
    
    int index = 0;
    
    float xRatio = (float)(_surveyIndex-1)/(float)(x-1);
    float yRatio = (float)(NUMBER_OF_GOERTZEL_FILTERS-1)/(float)(y-1);
    
    for (int j=0; j<y; j++) {
        
        int yIndex = (int)(0.5+yRatio*(float)j);
        
        for (int i=0; i<x; i++) {
            
            int xIndex = (int)(0.5+xRatio*(float)i);
            
            char value = (char)(20.0+200.0*_sonogram[xIndex][NUMBER_OF_GOERTZEL_FILTERS-yIndex-1]);
            
            for (int i=0; i<4; i++) {
                rgba[index++] = value;
            }
            
        }
        
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba,x,y,8,4*x,colorSpace,kCGImageAlphaPremultipliedLast);
    
    CFRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    
    NSString* serialisedSonogram;
    
    if ( cgImage == NULL ) {
        
        NSLog(@"Couldn't create the sonogram bitmap object.");
        
    } else {
    
        @try {
                        
            UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
            NSData *pngData = UIImagePNGRepresentation(uiImage);
            
            [pngData writeToURL:url atomically:NO];
            
            CFRelease(cgImage);
            CFRelease(bitmapContext);
            
            serialisedSonogram = [pngData base64Encoding];
            
        } @catch (NSException *e) {
           
            NSLog(@"Couldn't write the sonogram to a file.");
            
        }
        
    }

    free(rgba);
    
    return serialisedSonogram;
    
}

-(BOOL)writeRecordingWithURL:(NSURL*)url forDuration:(int)duration;
{
	
	RecordingBuffer_copyMainBuffer(&_detectorState.recordingBuffer);
	
	AudioFileID audioFile;
	
	BOOL error;
	
    error = CheckError(AudioFileCreateWithURL((CFURLRef)CFBridgingRetain(url),kAudioFileWAVEType,&_detectorState.asbd,kAudioFileFlags_EraseFile,&audioFile), "Couldn't open audio file");
	
	if ( error ) {
		return NO;
	}
	
	error = CheckError(RecordingBuffer_writeRecording(&audioFile, &_detectorState.recordingBuffer, duration), "Couldn't write data to audio file");
	
	if ( error ) {
		return NO;
	}
	
	error = CheckError(AudioFileClose(audioFile), "Couldn't close audio file");
	
	if ( error ) {
		return NO;
	}
	
	return YES;
	
}

static void MyInterruptionListener(void *inUserData, UInt32 inInterruptionState)
{
	
	switch (inInterruptionState)
	{
		case kAudioSessionBeginInterruption:
            NSLog(@"Audio interupted. Stopping detector.");
            [[CicadaDetector getInstance] stopDetector];
			break;
		case kAudioSessionEndInterruption:
            NSLog(@"Audio interuption ended. Starting detector.");
            [[CicadaDetector getInstance] startDetector];
			break;
		default:
			break;
	}
	
}

static OSStatus InputModulatingRenderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	
	DetectorState *detectorState = (DetectorState*)inRefCon;
	
	UInt32 bus1 = 1;
	
	CheckError(AudioUnitRender(detectorState->rioUnit, ioActionFlags, inTimeStamp, bus1, inNumberFrames, ioData), "Couldn't render from RemoteIO unit");
	
	SInt16 sample = 0;
	SInt16 silent = 0;
	
	UInt32 bytesPerChannel = detectorState->asbd.mBytesPerFrame / detectorState->asbd.mChannelsPerFrame;
	
	for ( int bufCount = 0; bufCount<ioData->mNumberBuffers; bufCount++) {
		
		AudioBuffer buf = ioData->mBuffers[bufCount];
		
		int currentFrame = 0;
		
		while ( currentFrame < inNumberFrames ) {
			
            for (int currentChannel = 0; currentChannel<buf.mNumberChannels; currentChannel++) {
				
                if ( detectorState->playBack ) {
                
                    sample = PlayBackBuffer_getSample(&detectorState->playBackBuffer);
                    
                } else {
                    
                    memcpy(&sample, buf.mData+(currentFrame*detectorState->asbd.mBytesPerFrame)+(currentChannel*bytesPerChannel), sizeof
                        (SInt16));
				
                }
                
				LowPassFilter_update(sample,&detectorState->lowPassFilter);
				RecordingBuffer_update(sample, &detectorState->recordingBuffer);
                for (int i=0; i<NUMBER_OF_GOERTZEL_FILTERS;i++ ) {
                    GoertzelFilter_update(sample, &detectorState->goerztelFilters[i]);
                }
                
                if ( detectorState->playBack ) {
                    
                    SInt16 amplifiedSample = 16*sample;
                    
                    memcpy(buf.mData+(currentFrame*detectorState->asbd.mBytesPerFrame)+(currentChannel*bytesPerChannel), &amplifiedSample, sizeof(SInt16));
                    
                } else {
				
                    if ( detectorState->whiteNoise ) {
                        
                        SInt16 random = rand();
                        
                        memcpy(buf.mData+(currentFrame*detectorState->asbd.mBytesPerFrame)+(currentChannel*bytesPerChannel), &random, sizeof(SInt16));

                    } else {
                                            
                        memcpy(buf.mData+(currentFrame*detectorState->asbd.mBytesPerFrame)+(currentChannel*bytesPerChannel), &silent, sizeof(SInt16));
                        
                    }
                    
                }
				
			}
			
			currentFrame++;
			
		}
		
	}
	
	return noErr;
	
}

@end
