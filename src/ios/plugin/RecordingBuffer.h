//
//  RecordingBuffer.h
//  Cicada Hunt
//
//  Created by acr on 24/12/2012.
//  Copyright (c) 2012 University of Southampton. All rights reserved.
//

#define RECORDING_BUFFER_LENGTH 1323008                 // 30 seconds of recording rounded up to nearest multiple of 1024
#define RECORDING_BUFFER_SAMPLES_PER_SECOND 44100

#import <AudioToolbox/AudioToolbox.h>

typedef struct {
	int index;
	int copyIndex;
	SInt16 mainBuffer[RECORDING_BUFFER_LENGTH];
	SInt16 copyBuffer[RECORDING_BUFFER_LENGTH];
} RecordingBuffer;

void RecordingBuffer_initialise(RecordingBuffer* recordingBuffer);
void RecordingBuffer_update(SInt16 sample, RecordingBuffer* recordingBuffer);
void RecordingBuffer_copyMainBuffer(RecordingBuffer* recordingBuffer);
OSStatus RecordingBuffer_writeRecording(AudioFileID* audioFile, RecordingBuffer* recordingBuffer,int duration);

