//
//  AudioPlayer.m
//  PlayDemo
//
//  Created by sunyard sunyard on 11-8-26.
//  Copyright 2011年 sunyard . All rights reserved.
//

#import "AudioPlayer.h"

static AudioPlayer *audioP = nil;


static UInt32 gBufferSizeBytes = 0x100000;

@interface AudioPlayer ()
{
    //音频流描述对象
    AudioStreamBasicDescription dataFormat;
    
    //音频队列
    AudioQueueRef queue;
    
    UInt32 bufferByteSize;
    
    AudioStreamPacketDescription *packetDescs;
    
    AudioQueueBufferRef buffer[1];
    
    PlayState playState;
}
//定义队列为实例属性

@property AudioQueueRef queue;

@property PlayState playState;

@end

@implementation AudioPlayer
@synthesize queue;
@synthesize playState;

+(AudioPlayer *)shareAudioPlayer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioP = [[AudioPlayer alloc]init];
    });
    return audioP;
}

// 回调（Callback）函数的实现



static void BufferCallback(void *inUserData, AudioQueueRef inAQ,AudioQueueBufferRef buffer)
{
    DebugAudioLog(@"");
    AudioQueueStop(audioP.playState.queue, NO);
    for(int i = 0; i < 3; i++)
    {
		AudioQueueFreeBuffer(audioP.playState.queue, audioP.playState.buffer[i]);
    }
    AudioQueueDispose(audioP.playState.queue, YES);
}

- (id)init
{
    DebugAudioLog(@"");
    self = [super init];
    if (self)
    {
        DebugAudioLog(@"");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    }
    return self;
}

- (BOOL)AudioPlayData:(NSData *)data
{
    DebugAudioLog(@"");
    if (data == nil || [data isKindOfClass:[NSNull class]] || [data length]<1)
    {
        return NO;
    }
    if([MPMusicPlayerController applicationMusicPlayer].volume != 1.0)
    {
        [[MPMusicPlayerController applicationMusicPlayer]setVolume:1.0];
    }
	/*
    if (&dataFormat == nil)
    {
        DebugAudioLog(@"dataFormat failed");
    }
    dataFormat.mSampleRate = 44100;
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mFormatFlags = 12;
    dataFormat.mBytesPerPacket = 2;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = 2;
    dataFormat.mChannelsPerFrame = 2;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mReserved = 0;

    AudioTimeStamp time;
    time.mSampleTime = 10;

    // 创建播放用的音频队列
    OSStatus status = AudioQueueNewOutput(&dataFormat, BufferCallback,self, nil, nil, 0, &queue);
    if (status != noErr)
    {
        DebugAudioLog(@"创建音频队列失败 status = %ld",status);
        return NO;
    }

    status = AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffer[0]);
    if (status != noErr)
    {
        DebugAudioLog(@"创建缓冲区 status = %ld",status);
        return NO;
    }

    int length = [data length];
    buffer[0]->mAudioDataByteSize = length;

    memcpy(buffer[0]->mAudioData,[data bytes],length);

    status = AudioQueueEnqueueBuffer(queue, buffer[0],0,nil);
    if (status != noErr)
    {
        DebugAudioLog(@"缓冲数据排队加入到AudioQueueRef失败 status = %ld",status);
        return NO;
    }
    //设置音量

    AudioQueueSetParameter (queue,kAudioQueueParam_Volume,1.0);

    status = AudioQueueStart(queue, nil);
    if (status != noErr)
    {
        DebugAudioLog(@"启动播放线程失败 status = %ld",status);
        return NO;
    }
//     */
    playState.dataFormat.mSampleRate = 44100;
    playState.dataFormat.mFormatID = kAudioFormatLinearPCM;
    playState.dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    playState.dataFormat.mBytesPerPacket = 2;
    playState.dataFormat.mFramesPerPacket = 1;
    playState.dataFormat.mBytesPerFrame = 2;
    playState.dataFormat.mChannelsPerFrame = 1;
    playState.dataFormat.mBitsPerChannel = 16;
    playState.dataFormat.mReserved = 0;
    
    AudioTimeStamp time;
    time.mSampleTime = 10;
    
    // 创建播放用的音频队列
    OSStatus status = AudioQueueNewOutput(&playState.dataFormat, BufferCallback,(__bridge void * _Nullable)(self), nil, nil, 0, &playState.queue);
    if (status != noErr)
    {
        DebugAudioLog(@"创建音频队列失败 status = %ld",status);
        return NO;
    }
    
    status = AudioQueueAllocateBuffer(playState.queue, gBufferSizeBytes, &playState.buffer[0]);
    if (status != noErr)
    {
        DebugAudioLog(@"创建缓冲区失败 status = %ld",status);
        return NO;
    }
    
    int length = [data length];
    playState.buffer[0]->mAudioDataByteSize = length;
    
    memcpy(playState.buffer[0]->mAudioData,[data bytes],length);
    
    status = AudioQueueEnqueueBuffer(playState.queue, playState.buffer[0],0,nil);
    if (status != noErr)
    {
        DebugAudioLog(@"缓冲数据排队加入到AudioQueueRef失败 status = %ld",status);
        return NO;
    }
    //设置音量
    float value;
    AudioQueueGetParameter(playState.queue,kAudioQueueParam_Volume, &value);
//    NSLog(@"kAudioQueueParam_Volume = %f",value);
    AudioQueueSetParameter (playState.queue,kAudioQueueParam_Volume,1.0);
    
    status = AudioQueueStart(playState.queue, nil);
    if (status != noErr)
    {
        DebugAudioLog(@"启动播放线程失败 status = %ld",status);
        return NO;
    }
    return YES;
}
@end
