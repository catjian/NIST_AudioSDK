//
//  CircleBuffer.m
//  TCircleBuffer
//
//  Created by sunyard sunyard on 11-9-4.
//  Copyright 2011年 sunyard . All rights reserved.
//

#import "CircleBuffer.h"
//#import "exten_Variable.h"
#define def_MaxSize  1024*8*6*10

int numbyRecordFile;

//extern unsigned long bufferSize;

//unsigned char pBufferData[def_MaxSize];

unsigned long readSize = 0;


@implementation CircleBuffer

- (id)init
{
    DebugAudioLog(@"");
	
    self = [super init];
    if (self)
    {
        DebugAudioLog(@"");
	
        // Initialization code here.
        
//        pReadPtr = nil;
//        pWritePtr = nil;
        nowsize = 0;
        allSize = def_MaxSize;
//        pReadPtr = pBufferData;
//        pWritePtr = pBufferData;
       
            //DebugAudioLog(@"CircleBuffer alloc failed");
        
    }
    
    return self;
}
-(unsigned long) getCurrentBufferSize
{
    DebugAudioLog(@"");
//    NSLog(@"getCurrentBufferSize");
	
    return nowsize;
}
-(unsigned long) getCurrentBufferMaxSize
{
    DebugAudioLog(@"");
	
    return allSize;
}
-(BOOL) circleBufferClean
{
    DebugAudioLog(@"");
	
//    if(pReadPtr && pWritePtr && pBufferData)
//    {
//        memset(pBufferData,0,def_MaxSize);
//        //free(pReadPtr);
//        pReadPtr = NULL;
//        //free(pWritePtr);
//        pWritePtr = NULL;
//        nowsize = 0;
//    }
//    if(pdata)
    {
//        pdata = nil;
        nowsize = 0;
        readSize = 0;
    }
    
    return true;
}
-(bool) ZeroBuffer
{
    DebugAudioLog(@"ZeroBuffer");
	
    readSize = 0;
//    if(pBufferData)
//    {
//        memset(pBufferData,0,def_MaxSize);
//        
//        nowsize = 0;
//    }
    
    nowsize = 0;
    
//    if(pdata )
//    {
//        pdata = nil;
//    }
    if(self.pdata == nil)
    {
        self.pdata = [[NSMutableData alloc] init];
    }
    
    return true;
}
-(BOOL) writeCircleBuffer:(unsigned char *)wtPtr length:(unsigned long )len
{
    DebugAudioLog(@"");
	
    unsigned long writeLen = 0;
    if (wtPtr == nil)
    {
        DebugAudioLog(@" write CircleBuffer input write buffer was empty");
        [self ZeroBuffer];
        return false;
    }
    if (len <= 0)
    {
        //DebugAudioLog(@" write input length was illegal");
        return false;
    }
    if (nowsize >= allSize)
    {
        DebugAudioLog(@"current circle buffer is full");
        [self ZeroBuffer];
        return false;
    }
    if (len > (allSize - nowsize))
    {
        writeLen = allSize - nowsize;
    }
    else
    {
        writeLen = len;
    }
    
    /*
    if ((pWritePtr + writeLen -1) < (pBufferData + allSize))
    {

        if (pWritePtr == NULL)
        {
            return false;
        }
        memcpy(pWritePtr, wtPtr, writeLen);
        pWritePtr = pWritePtr + writeLen;
        if (pWritePtr == pBufferData + allSize)
        {
            pWritePtr = pBufferData;
        }
    }
     //*/
    
//    @synchronized(pdata)
    {
        [self.pdata appendBytes:wtPtr length:len];
    }
    
    nowsize = nowsize + writeLen;
    
    
    //存储IPos返回的音频数据
//    [self StoreAudioInf:(unsigned char*)pBufferData Length:nowsize Filename:@"ReceiveData.wav"];
    
//    [self StoreAudioInfWithData:pdata Filename:@"ReceiveData.wav"];
    
    return true;
}

-(unsigned long) readCircleBuffer:(unsigned char *)rdPtr length:(unsigned long)len
{
    DebugAudioLog(@"");
	
    unsigned long readLen = 1;
    if (NULL == rdPtr)
    {
        //DebugAudioLog(@"input read buffer was null");
        return 0;
    }
    //if ((len < 0) || (len > allSize)) {
    if (len > allSize)
    {
        //DebugAudioLog(@"input length was illegnal");
        return 0;
    }
    if (0 >= nowsize)
    {
        DebugAudioLog(@"current circle buffer is empty");
        [self ZeroBuffer];
        return 0;
    }
    if (len > nowsize)
    {
        readLen = nowsize;
    }
    else
    {
        readLen = len;
    }
    
    /*
    if ((pReadPtr + readLen -1) < (pBufferData + allSize))
    {
        if (rdPtr == NULL || pReadPtr == NULL)
        {
            return false;
        }
        
        if(readSize > def_MaxSize)
        {
            return false;
        }
 
//        memcpy(rdPtr, pReadPtr, (realLength<readLen?realLength:readLen));
//        memcpy(rdPtr, pReadPtr, readLen);
        for(int i=readSize; i<def_MaxSize; i++)
        {
            if(pBufferData[i] == '\0')
            {
                readSize ++;
            }
            else
            {
                break;
            }
        }
        
        NSData *pdata = [[NSData alloc] initWithBytes:pBufferData length:allSize];
        
        memcpy(rdPtr, [[pdata subdataWithRange:NSMakeRange(readSize, 8000)] bytes], 8000);
        readSize += 8000;
        
        pReadPtr = pReadPtr + readLen;
        if (pReadPtr == (pBufferData + allSize))
        {
            pReadPtr = pBufferData;
        }
    }
     //*/
    
    if(self.pdata.length < readSize+8001)
    {
        [self ZeroBuffer];
        return false;
    }
    memcpy(rdPtr, [[self.pdata subdataWithRange:NSMakeRange(readSize, 8001)] bytes], 8000);
    readSize += 8000;
    
    nowsize = nowsize - 8000;
    return readLen;
}

-(NSData *) readCirclelength:(unsigned long*)len
{
    DebugAudioLog(@"");
	
    if (*len > allSize)
    {
        //DebugAudioLog(@"input length was illegnal");
        return nil;
    }
    if (0 >= nowsize)
    {
        DebugAudioLog(@"current circle buffer is empty");
        [self ZeroBuffer];
        return nil;
    }
    
    if(self.pdata == nil)
    {
//        [self ZeroBuffer];
        
        readSize = 0;
        
        nowsize = 0;
        return nil;
    }
    unsigned long sizel1 = self.bufferSize;        //8000*3*10
    unsigned long sizel2 = self.bufferSize+20;        //8001*3*10
    if(self.pdata.length < readSize+sizel2)
    {
        [self ZeroBuffer];
        return nil;
    }
//    NSLog(@"readCirclelength bufferSize = 1024*%d",(self.bufferSize/1024));
    *len = sizel2;
    readSize += sizel2;
    nowsize = nowsize - sizel2;
    NSData *data;
    @synchronized(self.pdata)
    {
        if(self.pdata == nil || self.pdata.length <= 0)
        {
            [self ZeroBuffer];
            return nil;
        }
        data = [self.pdata subdataWithRange:NSMakeRange(readSize-sizel1+sizel2>self.pdata.length?0:readSize-sizel1, sizel2)];
    }
    return data;
}



-(void)StoreAudioInf:(unsigned char *)inf Length:(int)len Filename:(NSString *)name
{
    NSData *data = [[NSData  alloc] initWithBytes:inf length:len];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
    [data writeToFile:filePath atomically:YES];
    data = nil;
}

-(void)StoreAudioInfWithData:(NSData *)inf Filename:(NSString *)name
{
    NSData *data = [[NSData  alloc] initWithData:inf];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:name];
    
    NSString *filePath = [NSString stringWithFormat:@"%@%d",[documentsDirectory stringByAppendingPathComponent:name],numbyRecordFile];
    [data writeToFile:filePath atomically:YES];
    data = nil;
}

@end
