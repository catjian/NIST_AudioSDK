//
//  AudioDataFactory.h
//  SignKeyDemo
//
//  Created by zhang jian on 14-6-13.
//  Copyright (c) 2014年 zhang_jian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define def_MaxSize  1024*20

typedef struct recordState
{
    AudioStreamBasicDescription dataFormat;     //音频的格式
    AudioQueueRef               queue;          //音频队列的对象AudioQueueRef
    AudioQueueBufferRef         buffer[3];     //缓冲区
    UInt32                      bufferByteSize; //缓冲区大小
    BOOL                        recording;      //是否正在录音
} RecordState;

typedef struct  playState
{
    AudioStreamBasicDescription dataFormat;     //输出音频的格式
    AudioQueueRef               queue;          //音频队列的对象AudioQueueRef
    AudioQueueBufferRef         buffer[3];     //缓冲区
    UInt32                      bufferByteSize; //缓冲区大小
    BOOL                        playing;        //是否正在播放
}PlayState;

@interface AudioDataFactory : NSObject

@property (nonatomic,strong) NSMutableArray *signListArray;
@property (nonatomic,strong) NSMutableArray *binaryListArray;


@property (nonatomic) UInt32 allbufferLength;

@property (nonatomic) unsigned char * allbuffer;

+(AudioDataFactory *)shareAudioDataFactory;

+(PlayState)GetPlayStateFormat;

+(RecordState)GetRecordStateFormat;

//- (void) decodeData:(unsigned char *)audioDataBuffer bufferSize:(UInt32)audioDataByteSize;

//-(void)clearData;

@end
