//
//  PlayBackBuffer.h
//  Cicada Hunt
//
//  Created by acr on 08/05/2013.
//  Copyright (c) 2013 University of Southampton. All rights reserved.
//

#define PLAYBACK_BUFFER_LENGTH 1323008                 // 30 seconds of recording rounded up to nearest multiple of 1024

#import <AudioToolbox/AudioToolbox.h>

typedef struct {
	int index;
    int length;
	SInt16 buffer[PLAYBACK_BUFFER_LENGTH];
} PlayBackBuffer;

void PlayBackBuffer_initialise(PlayBackBuffer* playBackBuffer);
void PlayBackBuffer_loadAudio(PlayBackBuffer* playBackBuffer, CFURLRef url);
SInt16 PlayBackBuffer_getSample(PlayBackBuffer* playBackBuffer);

