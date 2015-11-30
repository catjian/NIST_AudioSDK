//
//  AudioPlayer.h
//  PlayDemo
//
//  Created by sunyard sunyard on 11-8-26.
//  Copyright 2011年 sunyard . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AudioDataFactory.h"

#define BYTES_PER_SAMPLE 2
 
#define AUDIO_BUFFERS 3 

@interface AudioPlayer : NSObject

+(AudioPlayer *)shareAudioPlayer;

- (BOOL) AudioPlayData:(NSData *)data;

@end
