//
//  RecordCircleBuffer.h
//  YHBAudioCommunicationTest
//
//  Created by zhang jian on 14-7-29.
//  Copyright (c) 2014年 zhang_jian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordCircleBuffer : NSObject

+(RecordCircleBuffer *)shareRecordCircleBuffer;

-(BOOL) writeBuffer:(unsigned char *)wtPtr length:(unsigned long )len;

-(NSData *) readBufferlength:(unsigned long *)len;

-(void)cleanBuffer;

-(NSInteger)getRecordBufferLength;

@end
