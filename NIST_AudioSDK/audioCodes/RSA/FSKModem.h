/************************************************************************/
/*   
FSKModem.h
xiaotanyu13
2012/11/12
xiaot.yu@sunyard.com

��װ��FSK���ƽ���ĺ�����������ķ�����ʵ��
���ƽ��˵��:
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
#define MODULATE_SAMPLE  (int)(F_S / MODULATE_FREQUENCY)	// ����ʱ������ڵ���

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

	int YH_ModulateByte(BYTE byte,short* retData);				// ���һ���ֽ�
	int YH_ModulateBit(int type,short* retData);				// ��һ�����ص����ݵ��Ƴ���Ƶ����

	BYTE* YH_PackField(BYTE* data,int len,int *outLen);		// �鱨��
	int YH_PackSYNC(BYTE* data);								// ���ͬ����
	int YH_PackLevel(BYTE* data);								// ��Ӽ�����
	int YH_PackLength(int len,BYTE* data);						// ��ӳ�����
	int YH_PackData(BYTE* dataIn,int len,BYTE* data);			// ���������
	int YH_PackCRC(unsigned short crc,BYTE* data);						// ���У����
	int YH_PackEnd(BYTE* data);								// ��ӽ�����

	void YH_DisInterference(short *InDataBuf, unsigned long lenth,BYTE MobileType);				// ȥ��
	void YH_SmoothingWave(short *InDataBuf,unsigned long length, unsigned long LowF, unsigned long HighF, unsigned long SampleRate);							// �˲�
	BYTE YH_GetAllData(BYTE *OutDataBuf, short *InDataBuf,unsigned long lenth, unsigned int *endlen,BYTE MobileType);				// ���ȫ������
	BYTE YH_FindHead(short * InDataBuf,unsigned long lenth, unsigned int *endlen,BYTE MobileType);				// ����ͬ��ͷ
	unsigned long YH_GetN(unsigned long len);					//
	void YH_FindFrame(short *pData, unsigned long len, long *start, long *end);			//

	unsigned short YH_CalculateCRC(BYTE *buf,unsigned short len);					// ����CRC

	short* YH_Modulate(BYTE* data,int len,int* outFrameLen);	// ��������
    
	int	   YH_GetValidData(short *InDataBuf, short *OutDataBuf,unsigned long lenth);				// �ж������Ƿ���Ч
		
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
