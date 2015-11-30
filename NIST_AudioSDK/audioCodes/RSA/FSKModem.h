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
#ifndef FSKMODEM_H
#define FSKMODEM_H

#include "global.h"

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

typedef struct _tag_YH_FSKDataFrame
{
	BYTE   FrameStartFlag[2];
	BYTE   FrameSyncFlag[2];
	USHORT DataLength;
}
FSK_YH_DataFrame;

typedef struct _tag_YH_COS_DATA
{
	INT    Type;
	SHORT  Status;
	SHORT  Length;
	VOID * Data;
    int   respCode[2][8];
}
COS_DATA_YH;

#ifdef __cplusplus
extern "C" {
#endif

	int YH_ModulateByte(BYTE byte,short* retData);				// 添加一个字节
	int YH_ModulateBit(int type,short* retData);				// 将一个比特的数据调制成音频数据

	BYTE* YH_PackField(BYTE* data,int len,int *outLen);		// 组报文
	int YH_PackSYNC(BYTE* data);								// 添加同步域
	int YH_PackLevel(BYTE* data);								// 添加计数域
	int YH_PackLength(int len,BYTE* data);						// 添加长度域
	int YH_PackData(BYTE* dataIn,int len,BYTE* data);			// 添加数据域
	int YH_PackCRC(unsigned short crc,BYTE* data);						// 添加校验域
	int YH_PackEnd(BYTE* data);								// 添加结束域

	void YH_DisInterference(short *InDataBuf, unsigned long lenth,BYTE MobileType);				// 去扰
	void YH_SmoothingWave(short *InDataBuf,unsigned long length, unsigned long LowF, unsigned long HighF, unsigned long SampleRate);							// 滤波
	BYTE YH_GetAllData(BYTE *OutDataBuf, short *InDataBuf,unsigned long lenth, unsigned int *endlen,BYTE MobileType);				// 解出全部数据
	BYTE YH_FindHead(short * InDataBuf,unsigned long lenth, unsigned int *endlen,BYTE MobileType);				// 查找同步头
	unsigned long YH_GetN(unsigned long len);					//
	void YH_FindFrame(short *pData, unsigned long len, long *start, long *end);			//

	unsigned short YH_CalculateCRC(BYTE *buf,unsigned short len);					// 计算CRC

	short* YH_Modulate(BYTE* data,int len,int* outFrameLen);	// 调制数据
    
	int	   YH_GetValidData(short *InDataBuf, short *OutDataBuf,unsigned long lenth);				// 判断数据是否有效
		
	void YH_SetFrequency(int frequency);
	int YH_GetFrequency();
    
    int  YH_Demodulate(BYTE *OutDataBuf, short *InDataBuf,unsigned long lenth,unsigned int *OutLenIndix,BYTE MobileType);
    
    VOID * YH_BuildFSKDataFrame( CHAR * data, INT len, INT * frame_len );
    
    INT YH_DemoduleAudioData( VOID * data, INT len ,unsigned char *tempbuf);
    
    VOID YH_SetSendType( INT type );
    
    INT YH_GetSendType();
    
    void YH_GetAllReturnData(COS_DATA_YH * data);

#ifdef __cplusplus
}
#endif

#endif
