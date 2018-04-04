//
//  PlayBackBuffer.c
//  Cicada Hunt
//
//  Created by acr on 08/05/2013.
//  Copyright (c) 2013 University of Southampton. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "PlayBackBuffer.h"

#import <AudioToolbox/AudioToolbox.h>

void PlayBackBuffer_initialise(PlayBackBuffer* playBackBuffer) {
	
	memset(playBackBuffer,0,sizeof(&playBackBuffer));
    
}

void PlayBackBuffer_loadAudio(PlayBackBuffer* playBackBuffer, CFURLRef url) {

    AudioFileID audioFile;
    
    OSStatus err = AudioFileOpenURL(url, kAudioFileReadPermission, 0, &audioFile);
    
    UInt64 numBytes = 0;
    UInt32 dataSize = sizeof(numBytes);
    err = AudioFileGetProperty(audioFile, kAudioFilePropertyAudioDataByteCount, &dataSize, &numBytes);
    
    UInt64 offset = 0;
    UInt32 toRead = numBytes;
    
    if ( numBytes > 2*PLAYBACK_BUFFER_LENGTH ) {
        playBackBuffer->length = PLAYBACK_BUFFER_LENGTH;
        numBytes = 2*PLAYBACK_BUFFER_LENGTH;
    } else {
        playBackBuffer->length = numBytes/2;
    }
    
    err = AudioFileReadBytes(audioFile, true, offset, &toRead, playBackBuffer->buffer);
	
}

SInt16 PlayBackBuffer_getSample(PlayBackBuffer* playBackBuffer) {

    SInt16 sample = playBackBuffer->buffer[playBackBuffer->index];
    
    if ( playBackBuffer->index++ > playBackBuffer->length ) {
        playBackBuffer->index = 0;
    }
    
    return sample;
    
}

