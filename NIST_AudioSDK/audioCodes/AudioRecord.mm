//
//  AudioRecord.m
//  RecordDemo
//
//  Created by sunyard sunyard on 11-8-29.
//  Copyright 2011年 sunyard . All rights reserved.
//

#import "AudioRecord.h"
#include<string.h>

#import "RecordCircleBuffer.h"
//#import "exten_Variable.h"

//extern unsigned long bufferSize;

static void AQInputCallback(void *aqRecorderState,
                            AudioQueueRef                        inQ,
                            AudioQueueBufferRef                  inBuffer,
                            const AudioTimeStamp                 *timestamp,
                            UInt32                               inNumPackets,
                            const AudioStreamPacketDescription   *mDataFormat);

static AudioRecorder *audioRec = nil;

@interface AudioRecorder ()
{
    
    CFURLRef audioFileURL ;
    AudioFileID                  mAudioFile;
    SInt64                       mCurrentPacket;
    
    CircleBuffer *circleBuffer;
    NSLock *lock;
    
    RecordState recordState;
}


@end

@implementation AudioRecorder
@synthesize recordState;

+(AudioRecorder *)shareAudioRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioRec = [[AudioRecorder alloc] init];
    });
    return audioRec;
}

- (id)init
{
    DebugAudioLog(@"");
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(void)stopRecord
{
    DebugAudioLog(@"");
    if(!recordState.recording)
        return;
    /*
    if(lock != nil)
    {
        [lock lock];
        if(circleBuffer)
        {
            [circleBuffer circleBufferClean];
            [circleBuffer release];
            circleBuffer = nil;
        }
        circleBuffer = nil;
        
        [lock unlock];
        
        [lock release];
        lock = nil;
    }
    else
    {
        if(circleBuffer)
        {
            [circleBuffer circleBufferClean];
            [circleBuffer release];
            circleBuffer = nil;
        }
        circleBuffer = nil;
    }
    
    
    recordState.recording = NO;
    
    AudioQueueFlush(recordState.queue);
    AudioQueueStop(recordState.queue, NO);
    AudioQueueReset(recordState.queue);
    for (int i=0; i<AUDIO_BUFFERS; i++)
    {
        AudioQueueFreeBuffer(recordState.queue,recordState.buffer[i]);
    }
    AudioQueueDispose(recordState.queue, false);
     */
    
    recordState.recording = NO;
    
//    lock = nil;
    
    
    if(circleBuffer)
    {
        [circleBuffer circleBufferClean];
    }
    
//    [[RecordCircleBuffer shareRecordCircleBuffer] cleanBuffer];
//    [[RecordCircleBuffer shareRecordCircleBuffer] release];
    
    AudioQueueFlush(recordState.queue);
    AudioQueueStop(recordState.queue, NO);
    AudioQueueReset(recordState.queue);
    for (int i=0; i<AUDIO_BUFFERS; i++)
    {
        AudioQueueFreeBuffer(recordState.queue,recordState.buffer[i]);
    }
    AudioQueueDispose(recordState.queue, false);
    NSLog(@"***********  stopRecord circleBuffer.pdata = nil ********");
//    circleBuffer.pdata = nil;
    circleBuffer = nil;
}

-(BOOL) record
{
    DebugAudioLog(@"");
    recordState.recording = YES;
	
    float volume = [[MPMusicPlayerController applicationMusicPlayer] volume];
    if(volume < 1.0)
    {
        MPMusicPlayerController *iPod = [MPMusicPlayerController iPodMusicPlayer];
        iPod.volume = 1.0;
    }
    
    /*----------------- FORMAT -------------------*/
    recordState.dataFormat.mSampleRate = 44100;
    recordState.dataFormat.mChannelsPerFrame = 1;   // mono
	recordState.dataFormat.mFramesPerPacket = 1;
    recordState.dataFormat.mBitsPerChannel = 16;
	recordState.dataFormat.mBytesPerFrame = 2;
	recordState.dataFormat.mBytesPerPacket =  2;
    
	recordState.dataFormat.mFormatID = kAudioFormatLinearPCM;
	recordState.dataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
//    unsigned long sizel = self.bufferSize*2;
    unsigned long sizel = 1024*8*1;
    NSLog(@"record bufferSize = 1024*%d",(self.bufferSize/1024));
    recordState.bufferByteSize = sizel;
	// create the queue
    OSStatus status = AudioQueueNewInput(&recordState.dataFormat, AQInputCallback, self, NULL, NULL, 0, &recordState.queue);
    if (status != noErr)
    {
        DebugAudioLog(@"创建录音队列失败 status = %ld",status);
        recordState.recording = NO;
        return NO;
    }
    
    for (int i=0; i<AUDIO_BUFFERS; i++)
    {
        status = AudioQueueAllocateBuffer(recordState.queue, recordState.bufferByteSize, &recordState.buffer[i]);
        if (status != noErr)
        {
            DebugAudioLog(@"创建缓冲区失败 status = %ld",status);
            recordState.recording = NO;
            return NO;
        }
        status = AudioQueueEnqueueBuffer(recordState.queue, recordState.buffer[i], 0, NULL);
        if (status != noErr)
        {
            DebugAudioLog(@"缓冲数据排队加入到AudioQueueRef失败 status = %ld",status);
            recordState.recording = NO;
            return NO;
        }
    }
    // set current packet index and run state
	mCurrentPacket = 0;
    recordState.recording = YES;
	// start the recording
    status = AudioQueueStart(recordState.queue, NULL);
    if (status != noErr)
    {
        DebugAudioLog(@"启动录音线程失败 status = %ld",status);
        recordState.recording = NO;
        return NO;
    }
    
    circleBuffer = [[[CircleBuffer alloc] init] autorelease];
    circleBuffer.bufferSize = self.bufferSize;
    lock = [[[NSLock alloc] init] autorelease];
    if (circleBuffer == nil)
    {
        DebugAudioLog(@"循环队列分配内存失败");
    }
    [self CleanCircleBuffer];
    
    const UInt8 *pFilepath = (const UInt8 *)[[NSHomeDirectory() stringByAppendingPathComponent:@"CurrentRecording.text"] UTF8String];
    
    audioFileURL = CFURLCreateFromFileSystemRepresentation (NULL, pFilepath, strlen((const char*)pFilepath), false);
    
    //[data writeToFile:filePath atomically:YES];
    AudioFileCreateWithURL(audioFileURL,
                           kAudioFileCAFType,
                           &recordState.dataFormat,
                           false,
                           &mAudioFile);
    return YES;
    
}

static void AQInputCallback(void *aqRecorderState,
                            AudioQueueRef                        inQ,
                            AudioQueueBufferRef                  inBuffer,
                            const AudioTimeStamp                 *timestamp,
                            UInt32                               inNumPackets,
                            const AudioStreamPacketDescription   *mDataFormat)
{
    DebugAudioLog(@"");
	
    AudioRecorder *pArs = (AudioRecorder *)aqRecorderState;
	
	if (inNumPackets == 0 && pArs.recordState.dataFormat.mBytesPerPacket != 0)
    {
		inNumPackets = inBuffer->mAudioDataByteSize / pArs.recordState.dataFormat.mBytesPerPacket;
    }
    if (AudioFileWritePackets(pArs->mAudioFile,
                              false, 
                              inBuffer->mAudioDataByteSize,
                              mDataFormat, 
                              pArs->mCurrentPacket, 
                              &inNumPackets,
                              inBuffer->mAudioData) == noErr)
    {
        pArs->mCurrentPacket += inNumPackets;  // advance packet index pointer
    }

    int record_len = inBuffer->mAudioDataByteSize;
    NSLog(@"record_len = %d",record_len);
    NSLog(@"pArs->lock == nil ? %@",pArs->lock == nil?@"YES":@"NO");
    NSLog(@"pArs->recordState.recording ? %@",pArs->recordState.recording?@"YES":@"NO");    
    if (record_len > 0 && pArs->lock && pArs->recordState.recording)
    {
        [pArs->lock lock];
        [pArs->circleBuffer writeCircleBuffer:(unsigned char *)inBuffer->mAudioData length: record_len];
        [pArs->lock unlock];
    }
    
    AudioQueueEnqueueBuffer(pArs.recordState.queue, inBuffer, 0, NULL);
}

- (void)dealloc
{
    DebugAudioLog(@"");
    [super dealloc];
}

//获得循环队列当前的大小
-(unsigned long)getCircleLength
{
    DebugAudioLog(@"");
//    NSLog(@"getCircleLength");
	
    return [circleBuffer getCurrentBufferSize];
//    return [[RecordCircleBuffer shareRecordCircleBuffer] getRecordBufferLength];
}

- (unsigned long)getCircleBuffer:(unsigned char *)tempBuffer length:(unsigned long)tempLength
{
    DebugAudioLog(@"");
	
    return [circleBuffer readCircleBuffer:tempBuffer length:tempLength];
}

- (void)CleanCircleBuffer
{
    DebugAudioLog(@"");
	if(lock)
    {
        [lock lock];
        [circleBuffer ZeroBuffer];
        [lock unlock];
    }
    else
    {
        [circleBuffer ZeroBuffer];
    }
    
//    [[RecordCircleBuffer shareRecordCircleBuffer] cleanBuffer];
}

- (NSData *)getCircle_Length:(unsigned long*)len
{
    DebugAudioLog(@"");
	
    return [circleBuffer readCirclelength:len];
//    return [[RecordCircleBuffer shareRecordCircleBuffer] readBufferlength:len];
}

-(void)reloadBufferSize:(unsigned long) sizeLength
{
    self.bufferSize = sizeLength;
    circleBuffer.bufferSize = sizeLength;
}

@end

