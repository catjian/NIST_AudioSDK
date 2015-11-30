//
//  AudioPlayer.h
//  PlayDemo
//
//  Created by sunyard sunyard on 11-8-26.
//  Copyright 2011年 sunyard . All rights reserved.
//33333333333333333333333333333zuizhong

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CircleBuffer.h"
#include<stdio.h>
#include<string.h>

#import "AudioDataFactory.h"
#import "global.h"

#define AUDIO_BUFFERS 3

@interface AudioRecorder : NSObject

@property RecordState recordState;

@property (nonatomic) unsigned long bufferSize;

+(AudioRecorder *)shareAudioRecorder;

//播放方法定义

-(BOOL) record;
-(void) stopRecord;
- (void)CleanCircleBuffer;
-(unsigned long)getCircleLength;
- (unsigned long)getCircleBuffer:(unsigned char *)tempBuffer length:(unsigned long)tempLength;


- (NSData *)getCircle_Length:(unsigned long*)len;

-(void)reloadBufferSize:(unsigned long) sizeLength;

@end
