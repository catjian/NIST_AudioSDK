/************************************************************************/
/*   
FSKModem.h
xiaotanyu13
2012/11/12
xiaot.yu@sunyard.com

封装了FSK调制解调的函数，采用类的方法来实现
调制解调说明:
the frequency of modulation is constant which is 5.5k
the frequency of demodulation is variable which in the scope from 1 to 9
*/
/************************************************************************/

#import "global.h"

#ifndef BYTE
typedef unsigned char BYTE;
#endif

#ifndef DWORD
typedef unsigned long DWORD;
#endif

#define F_S				44100
#define MODULATE_FREQUENCY	5512.5
#define MODULATE_SAMPLE  (int)(F_S / MODULATE_FREQUENCY)	// 调制时候的周期点数

#ifndef USER_SEND_COMMAND
#define USER_SEND_COMMAND  0x0001
#endif
#ifndef READ_RETURN_DATA
#define READ_RETURN_DATA   0x0002
#endif
#ifndef _6100_token_COMMAND
#define _6100_token_COMMAND 0x0003
#endif

typedef struct _tag_nYH_FSKDataFrame
{
	BYTE   FrameStartFlag[2];
	BYTE   FrameSyncFlag[2];
	USHORT DataLength;
}
FSK_nYH_DataFrame;

typedef struct _tag_nYH_COS_DATA
{
	INT    Type;
	SHORT  Status;
	SHORT  Length;
	VOID * Data;
    int   respCode[2][8];
}
COS_DATA_nYH;


@interface newFSKModem : NSObject

-(int) nYH_ModulateByte:(BYTE)byte recvData:(short*) retData;
-(int) nYH_ModulateBit:(int) type recvData:(short*) retData;

-(BYTE*) nYH_PackField:(BYTE*) data dataLength:(int) len outDataLength:(int *) outLen;
-(int) nYH_PackSYNC:(BYTE*) data;
-(int) nYH_PackLevel:(BYTE*) data;
-(int) nYH_PackLength:(int) len packData:(BYTE*) data;
-(int) nYH_PackData:(BYTE*) dataIn dataLenght:(int) len outData:(BYTE*) data;
-(int) nYH_PackCRC:(unsigned short) crc outData:(BYTE*) data;
-(int) nYH_PackEnd:(BYTE*) data;

-(void) nYH_DisInterference:(short *)InDataBuf dataLength:(unsigned long) lenth mobileType:(BYTE) MobileType;
-(void) nYH_SmoothingWave:(short *)InDataBuf dataLength:(unsigned long) length lowF:(unsigned long) LowF highF:(unsigned long) HighF sampleRate:(unsigned long) SampleRate;
-(BYTE) nYH_GetAllData:(BYTE *)OutDataBuf inDataBuffer:(short *) InDataBuf length:(unsigned long) lenth endlen:(unsigned int *) endlen mobkeType:(BYTE) MobileType;
-(BYTE) nYH_FindHead:(short *) InDataBuf length:(unsigned long) lenth endLen:(unsigned int *) endlen mobileType:(BYTE) MobileType;
-(unsigned long) nYH_GetN:(unsigned long) len;
-(void) nYH_FindFrame:(short *)pData dataLength:(unsigned long) len startPoint:(long *) start endPoint:(long *) end;

-(unsigned short) nYH_CalculateCRC:(BYTE *) buf length:(unsigned short) len;

-(short*) nYH_Modulate:(BYTE*) data length:(int) len outFrameLength:(int*) outFrameLen;

-(int) nYH_GetValidData:(short *) InDataBuf outDataBuffer:(short *) OutDataBuf dataLength:(unsigned long) lenth;
		
-(void) nYH_SetFrequency:(int) frequency;

-(int) nYH_GetFrequency;
    
-(int) nYH_Demodulate:(BYTE *) OutDataBuf inDataBuffer:(short *)InDataBuf length:(unsigned long) lenth outDataLend:(unsigned int *)OutLenIndix moblieType:(BYTE) MobileType;
    
-(VOID *) nYH_BuildFSKDataFrame:(CHAR *) data length:(INT) len frameLength:(INT *) frame_len;

-(INT) nYH_DemoduleAudioData:(VOID *) data length:(INT) len tempBuf:(unsigned char *) tempbuf;
    
-(VOID) nYH_SetSendType:(INT) type;

-(INT) nYH_GetSendType;
    
-(void) nYH_GetAllReturnData:(COS_DATA_nYH *) data;

+(newFSKModem *)shareNewFSKModem;

@end
