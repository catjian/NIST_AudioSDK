//
//  CircleBuffer.h
//  TCircleBuffer
//
//  Created by sunyard sunyard on 11-9-4.
//  Copyright 2011年 sunyard . All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CircleBuffer : NSObject
{
//    unsigned char *pBufferData;
    unsigned char *pReadPtr;
    unsigned char *pWritePtr;
    unsigned long nowsize;
    unsigned long allSize;
}

@property (nonatomic) unsigned long bufferSize;

@property (nonatomic, strong) NSMutableData *pdata;

-(BOOL) circleBufferClean;
-(BOOL) writeCircleBuffer:(unsigned char *)wtPtr length:(unsigned long )len;
-(unsigned long) readCircleBuffer:(unsigned char *)rdPtr length:(unsigned long)len;
-(unsigned long) getCurrentBufferSize;
-(unsigned long) getCurrentBufferMaxSize;
-(bool) ZeroBuffer;

-(NSData *) readCirclelength:(unsigned long *)len;

@end
