
#ifndef __FSKMODEM_H__
#define __FSKMODEM_H__

#include "global.h"
#ifdef WIN32
#include <wtypes.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define FSKBUF             64
#define START_FLAG_LENGTH  2            // 标识码长度
#define SYNC_FLAG_LENGTH   2            // 同步码长度
#define START_FLAG         0x55         // 标识码 1111 1111
#define SYNC_FLAG          0x01         // 同步码 0101 0101
#define END_FLAG           0xFF         // 结束码 1111 1111
#define MAX_OUTPUT         2048
#define USER_SEND_COMMAND  0x0001     // 用户发送命令
#define READ_RETURN_DATA   0x0002     // 读取返回数据
    
#define _6100_token_COMMAND 0x0003

extern int   g_count;

/*---------------*/
/*    标识码     */
/*---------------*/
/*    同步码     */
/*---------------*/
/*   数据长度    */
/*---------------*/
/*   采样数据    */
/*---------------*/

typedef struct _tagFSKDataFrame
{
	BYTE   FrameStartFlag[START_FLAG_LENGTH]; // 每个帧的标识码为连续START_FLAG_LENGTH个START_FLAG
	BYTE   FrameSyncFlag[SYNC_FLAG_LENGTH];   // 每个帧的同步码为连续SYNC_FLAG_LENGTH个SYNC_FLAG
	USHORT DataLength;                        // 每个帧的数据长度，其值为所发送的原始数据字节数
}
FSKDataFrame;

typedef struct _tagCOS_DATA
{
	INT    Type;
	SHORT  Status;
	SHORT  Length;
	VOID * Data;
    int   respCode[2][8];
}
COS_DATA;


unsigned char   Demodulation(unsigned char *OutDataBuf, short *InDataBuf,unsigned long lenth,
                             unsigned long *OutLenIndix,unsigned char MobileType,unsigned char TestCommunication);
VOID * BuildFSKDataFrame( CHAR * data, INT len, INT * frame_len );
INT    DemoduleAudioData( VOID * data, INT len ,unsigned char *tempbuf);
VOID   SetSendType( INT type );
INT    GetSendType();
    VOID GetAllReturnData( COS_DATA * data );
    INT GetDataLenth();
VOID   GetReturnData( COS_DATA * data );
VOID   SetJudgementFlag( bool flag );
bool   GetJudgementFlag();
VOID   SetSinuidalFlag( bool flag );
bool   GetSinuidalFlag();
VOID   MobileShieldInit( bool flag, bool style, VOID * obj, VOID * cbf );

#ifdef __cplusplus
}
#endif

#endif


