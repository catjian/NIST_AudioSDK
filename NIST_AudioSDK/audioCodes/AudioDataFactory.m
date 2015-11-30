//
//  AudioDataFactory.m
//  SignKeyDemo
//
//  Created by zhang jian on 14-6-13.
//  Copyright (c) 2014年 zhang_jian. All rights reserved.
//

#import "AudioDataFactory.h"
//#import "AudioContoller.h"

static AudioDataFactory *audioDataF = nil;

BOOL decodeSuccess;

unsigned char * adBuffer;

UInt32 adByteSize;

@interface AudioDataFactory ()

@property (nonatomic, retain)  NSOperationQueue *queue;
@property (nonatomic, retain)  NSRecursiveLock *accessLock;

@end

@implementation AudioDataFactory

+(AudioDataFactory *)shareAudioDataFactory
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioDataF = [[AudioDataFactory alloc] init];
    });
    return audioDataF;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        free(_allbuffer);
        _allbuffer = nil;
        _allbuffer = (unsigned char*)calloc(def_MaxSize,sizeof(unsigned char));
        memset(_allbuffer,0,def_MaxSize);
    }
    return self;
}

+(PlayState)GetPlayStateFormat
{
    PlayState playState;
//    playState.dataFormat.mSampleRate = 44100;                   // 采样率
//    playState.dataFormat.mFormatID = kAudioFormatLinearPCM;     // PCM 格式
//    playState.dataFormat.mFormatFlags = 12;
//    playState.dataFormat.mBytesPerPacket = 2;                   
//    playState.dataFormat.mFramesPerPacket = 1;
//    playState.dataFormat.mBytesPerFrame = 2;
//    playState.dataFormat.mChannelsPerFrame = 1;                 // 1:单声道；2:立体声
//    playState.dataFormat.mBitsPerChannel = 16;
//    playState.dataFormat.mReserved = 0;
    playState.dataFormat.mSampleRate = 44100.0f; // 采样率 (立体声 = 8000)
    playState.dataFormat.mFormatID = kAudioFormatLinearPCM; // PCM 格式
    playState.dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    playState.dataFormat.mFramesPerPacket=1;
    playState.dataFormat.mChannelsPerFrame = 1;  // 1:单声道；2:立体声
    playState.dataFormat.mBitsPerChannel = 16;
    playState.dataFormat.mBytesPerFrame = 2;
    playState.dataFormat.mBytesPerPacket =  2;
    playState.dataFormat.mReserved = 0;
    return playState;
}

+(RecordState)GetRecordStateFormat
{
    RecordState recordState;
    recordState.dataFormat.mSampleRate = 48000;                 // 采样率
    recordState.dataFormat.mChannelsPerFrame = 1;               // 1:单声道；2:立体声
	recordState.dataFormat.mFramesPerPacket = 1;
    recordState.dataFormat.mBitsPerChannel = 16;
	recordState.dataFormat.mBytesPerFrame = 2;
	recordState.dataFormat.mBytesPerPacket =  2;
    
	recordState.dataFormat.mFormatID = kAudioFormatLinearPCM;
	recordState.dataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    recordState.bufferByteSize = 1024*8;

    return recordState;
}

//-(void)initQueue
//{
//    self.queue = [[NSOperationQueue alloc]init];
//    [self.queue setMaxConcurrentOperationCount:1];//设置并发数
//    [self.queue setSuspended:NO];
//}
//
//-(void)deallocQueue
//{
//    [self.queue setSuspended:YES];
//    for (NSInvocationOperation *op in self.queue.operations)
//    {
//        [op cancel];
//    }
//    [self.queue cancelAllOperations];
//    [self.queue setSuspended:NO];
//    [self.queue release];
//    self.queue = nil;
//    [self.accessLock release];
//}
//
//- (void) decodeData:(unsigned char *)audioDataBuffer bufferSize:(UInt32)audioDataByteSize
//{
//    DebugAudioLog(@"start decode 开始解码音频数据");
//    if (decodeSuccess)
//        return;
//    
//    if(!self.queue)
//    {
//        [self initQueue];
//    }
//    
//    adBuffer = audioDataBuffer;
//    adByteSize = audioDataByteSize;
//    NSInvocationOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(handleData) object:nil];
//    [self.queue addOperation:op];
//    [op release];
//}
//
//- (void) handleData
//{
//    if (decodeSuccess)
//        return;
//    
//    [[self accessLock]lock];
//    [self countAudioSample:adBuffer bufferSize:adByteSize];
//    [[self accessLock]unlock];
//}
//
//-(void)clearData
//{
//    [self.signListArray removeAllObjects];
//    [self.binaryListArray removeAllObjects];
//    _allbufferLength = 0;
//    memset(_allbuffer, 0, def_MaxSize);
//}
//
////获取音频采样值
//-(void)countAudioSample:(unsigned char *)audioDataBuffer bufferSize:(UInt32)audioDataByteSize
//{
//    //缓冲区数据大小
//    UInt32 charCount = audioDataByteSize/2;
//    if(_allbufferLength < (def_MaxSize - 1024*4) )
//    {
//        unsigned char * buffer = (unsigned char *)malloc(sizeof(unsigned char)*audioDataByteSize);
//        memcpy(buffer, audioDataBuffer, audioDataByteSize);
//        memcpy(_allbuffer+_allbufferLength, audioDataBuffer, audioDataByteSize);
//        _allbufferLength += charCount;
//    }
//    else
//    {
////        [[AudioContoller shareAudioController] ReadData];
//    }
//}

@end
