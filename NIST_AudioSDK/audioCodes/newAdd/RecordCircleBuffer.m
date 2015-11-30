//
//  RecordCircleBuffer.m
//  YHBAudioCommunicationTest
//
//  Created by zhang jian on 14-7-29.
//  Copyright (c) 2014年 zhang_jian. All rights reserved.
//

#import "RecordCircleBuffer.h"

#define def_MaxLength  1024*512*4

static RecordCircleBuffer *rcBuff = nil;

@interface RecordCircleBuffer()

@property (nonatomic,retain) NSMutableData *recvData;

@property (nonatomic) NSInteger allLength;

@end

@implementation RecordCircleBuffer

+(RecordCircleBuffer *)shareRecordCircleBuffer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rcBuff = [[RecordCircleBuffer alloc] init];
    });
    return rcBuff;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.recvData = [[NSMutableData alloc] initWithCapacity:def_MaxLength];
    }
    return self;
}

-(void)dealloc
{
    [self.recvData release];
    self.recvData = nil;
    [super dealloc];
}

-(BOOL) writeBuffer:(unsigned char *)wtPtr length:(unsigned long )len
{
    if(len <= 0)
    {
        return NO;
    }
    
    if(wtPtr == nil)
    {
        return NO;
    }
    
    if(!self.recvData)
    {
        self.recvData = [[NSMutableData alloc] initWithCapacity:def_MaxLength];
    }
    
//    @synchronized(self.recvData)
    {
        if(self.allLength >= def_MaxLength)
        {
            NSInteger length = self.allLength - len;
            self.recvData = [NSMutableData dataWithData:[self.recvData subdataWithRange:NSMakeRange(length, self.recvData.length - length)]];
            [self.recvData appendBytes:wtPtr length:len];
            return YES;
        }
        else if(self.allLength + len >= def_MaxLength)
        {
            NSInteger length = self.allLength + len - def_MaxLength;
            self.recvData = [NSMutableData dataWithData:[self.recvData subdataWithRange:NSMakeRange(length, self.recvData.length - length)]];
            [self.recvData appendBytes:wtPtr length:len];
            self.allLength += len;
            return YES;
        }
        else
        {
            [self.recvData appendBytes:wtPtr length:len];
            self.allLength += len;
        }
    }
    
    return YES;
}

-(NSInteger)getRecordBufferLength
{
    return self.recvData.length;
}

-(NSData *) readBufferlength:(unsigned long *)len
{
    *len = 0;
    
    NSData *data = nil;
    
//    @synchronized(self.recvData)
    {
        if(self.recvData && self.recvData.length >= 8012)
        {
            data = [NSData dataWithData:[self.recvData subdataWithRange:NSMakeRange(0, 8012)]];
            self.recvData = [NSMutableData dataWithData:[self.recvData subdataWithRange:NSMakeRange(8012, self.recvData.length - 8012)]];
            self.allLength = self.recvData.length;
        }
    }
    
    return data;
}

-(void)cleanBuffer
{
    if(self.recvData)
    {
        [self.recvData release];
        self.recvData = nil;
    }
    self.recvData = [[NSMutableData alloc] initWithCapacity:def_MaxLength];
    self.allLength = 0;
}

@end
