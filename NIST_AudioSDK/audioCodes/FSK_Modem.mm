
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <memory.h>
#include <string.h>
#include <math.h>
#include "FSK_Modem.h"
#include "MobileShield.h"
#ifdef WIN32
#include <wtypes.h>
#endif
#include "global.h"

#ifdef __cplusplus
extern "C" {
#endif

#define AMP                    1000            // ∑˘∂»
#define FB                     1200            // –≈∫≈ÀŸ¬  Baud
#define F1                     1200            // ‘ÿ∆µ1
#define F2                     2200            // ‘ÿ∆µ2
#define FS                     9600            // ≤…∆µ
#define PI                     3.1415926
#define SAMP_SIZE              ( FS / FB * 8 ) //(√ø◊÷Ω⁄8Œª * √øŒª≤…—˘µ„ ˝)
#define SIN_AMP                1024 * 24
#define MAX_QUEUE_LEN          1024 * 1
#define BUFFER_SIZE            4 * 1024
#define MIN_BUFFER_NUM         2

#define MAX_RET_DATA_LENGTH    64
#define DEMODULATION_FINISHED   1
#define CRC_VERIFY_ERROR        2
#define NEED_MORE_DATA          3
#define NO_FIND_FRAME_HEADER    4
#define NULL_POINTER            5
#define FATAL_ERROR             6


SHORT Buffer_Queue[ MAX_QUEUE_LEN ];
unsigned char OutData[ MAX_OUTPUT ];

INT   g_total     = 0;
INT   g_start     = 0;
INT   g_startflag = 0;
INT   g_count     = 0;
unsigned int   g_length    = 0;
INT   g_SendType  = USER_SEND_COMMAND;   // ±Í ∂∑¢ÀÕ√¸¡Ó¿‡–Õ
bool  g_Judgement = TRUE;                // ±Í ∂ «∑Ò≈–∂œ≥ˆ“Ù∆µ ˝æ›Œ™’˝œ“≤®
bool  g_Sinuidal  = TRUE;                // ±Í ∂ «∑Ò «’˝œ“≤®
unsigned long end_off;
SHORT ZVALUEREF   = 0;
unsigned long frameFlag = 0;
unsigned long nStart = 0;
unsigned long head_begin = 0;
unsigned long unuseFlag = 0;
    
int flag_proc = 0;

SHORT sin_bit0[ FS / FB ];
SHORT sin_bit1[ FS / FB ];
#ifdef COMMUNICATION_TEST
SHORT g_DataLength = 0;
#endif

VOID SetSendType( INT type )
{
    DebugAudioLog(@"");
	
	g_SendType = type;
}
    
INT GetDataLenth()
{
    DebugAudioLog(@"");
	
	return g_length;
}   

INT GetSendType()
{
    DebugAudioLog(@"");
	
	return g_SendType;
}    
    
static BYTE GetFrameData( BYTE * outdata, SHORT * cADCResult, BYTE * outlen )
{
    DebugAudioLog(@"");
	
	unsigned char indataindex = 0;
	unsigned char datastart = 0;
	unsigned char dataend = 0;
	unsigned char dataend1 = 0;
	unsigned char bit0flag = 0;
	unsigned char bitindex = 0;
	unsigned char datainterval = 0;
	unsigned char datainterval1 = 0;
	unsigned char datainterval2 = 0;
	short * psample = cADCResult;
	unsigned char retdata = 0;
	for(;;)
	{
		datainterval = 0;
		if(indataindex == 0)
		{		
			while(psample[indataindex] < ZVALUEREF)  // > 三星
			{		
				if(indataindex == 10) 
				{
					*outlen = indataindex;
					return 0;
				}
				indataindex++;
			}			
		}
		datastart = indataindex;
		while(psample[indataindex] >= ZVALUEREF)
		{
			if((indataindex-datastart)>10)
			{
				*outlen = indataindex;
				return 0;
			}
			indataindex++;			
		}
		dataend1  = indataindex;
		datainterval1 = dataend1 - datastart;
		while(psample[indataindex] < ZVALUEREF)
		{
			if((indataindex-datastart)>10)
			{
				*outlen = indataindex;
				return 0;
			}
			indataindex++;	
		}
		dataend = indataindex;
		datainterval = dataend-datastart;
		datainterval2 = datainterval-datainterval1;
		if((datainterval == 3) || (datainterval == 4) || (datainterval == 5)
           || (datainterval == 6)
           )
		   	
		{
			if(bit0flag == 0)
			{
				bit0flag = 1;
				continue;
			}
			else
			{
				retdata |= 1<<(7-bitindex);
				bitindex++;
				bit0flag = 0;
			}
		}
		else if((datainterval==7) || (datainterval==8) || (datainterval==9) ||(datainterval==10)
                )
		{
			retdata  &= ~(1<<(7-bitindex));
			bitindex++;
			bit0flag = 0;
		}	
		else
		{	
			*outlen = indataindex;
			return 0;
		}
		if(bitindex == 8)
		{
			*outdata = retdata;
			*outlen = indataindex;
			return 1;
		}	
	}

}
    
//add by wangzhong
static BYTE GetFrameDataV3(BYTE * outdata, short * cADCResult,BYTE * outlen)
{
    DebugAudioLog(@"");
	
	//unsigned char i = 0;
    //unsigned char j = 0;
    unsigned char indataindex = 0;
    unsigned char datastart = 0;
    unsigned char dataend = 0;
    unsigned char bit0flag = 0;
    unsigned char bitindex = 0;
    unsigned char datainterval = 0;
    short * psample = cADCResult;
    unsigned char retdata = 0;
    //unsigned char fristflag = 0;
    for(;;)
    {
        datainterval = 0;
        datastart = indataindex;
        if(psample[indataindex]>=0)
        {
            while(psample[indataindex] >= ZVALUEREF)
            {
                if((indataindex-datastart)>7)
                {
                    *outlen = indataindex;
                    return 0;
                }
                indataindex++;			
            }
        }
        else
        {
            while(psample[indataindex] < ZVALUEREF)
            {
                if((indataindex-datastart)>7)
                {
                    *outlen = indataindex;
                    return 0;
                }
                indataindex++;			
            }
        }
        dataend = indataindex;
        datainterval = dataend - datastart;
        
        if((datainterval>=4)&&(datainterval<=7)) 
        {
            retdata  &= ~(1<<(7-bitindex));
            bitindex++;
            bit0flag = 0;
        }
        else if((datainterval>=1)&&(datainterval<=3)) 
        {
            if(bit0flag == 0)
            {
                bit0flag = 1;
                continue;
            }
            else
            {
                retdata |= 1<<(7-bitindex);			
                bitindex++;
                bit0flag = 0;
            }			
        }
        else
        {
            *outlen = indataindex;
            return 0;
        }
        if(bitindex == 8)
        {
            *outlen = indataindex;
            *outdata = retdata;
            return 1;
        }
    }
}  
    
    
static unsigned char FSK_Demodule(void * sample,unsigned char *desdata,unsigned long len)
{
    DebugAudioLog(@"");
	
	short * pSamples = NULL;
	unsigned char  pData    = NULL;
	unsigned long nStart = 0;
	unsigned char startlen = 0;
	unsigned char synclen = 0;
	unsigned char startflag = 1;
	unsigned char syncflag = 0;
	unsigned char dataflag = 0;
	unsigned char datalenflag = 0;
	unsigned int  datalength = 0;
	unsigned char datalenindex = 0;
	unsigned int dataindex = 0;
	unsigned int retdatalen = 0;
	unsigned char crc = 0;

	int j = 0;
	unsigned char ret;
	short sTmpData = 0;
	
	if ( (!sample) || (!desdata))
		return -1;	
	for ( nStart = 0; nStart < len - 64;  )  // ±‹√‚ ˝æ›∆´“∆
	{
		pSamples = ( short * )sample + nStart ;	

		if((startflag == 1)&&(syncflag ==0)&&(datalenflag == 0)&&(dataflag == 0)&&(startlen == 0))
		{
			sTmpData = *pSamples;
			if((sTmpData<800)&&(sTmpData>-800))
			{
				nStart++;
				continue;
			}
		}	
		
		ret = GetFrameDataV3(&pData, pSamples, (BYTE*)&retdatalen);
		if((ret == 1)&&(pData == 0xEF)&&(startflag == 1))
		{
#ifdef Debug_Printf 
			printf("\nstart: %d\n",(int)nStart);
#endif
			startlen ++;
			if(startlen == 2)
			{
				startflag = 0;
				syncflag = 1;
				synclen = 0;			
			}
			nStart += retdatalen;
		}
		else if((ret == 1)&&(pData == 0x01)&&(syncflag == 1))
		{
			synclen++;
			if(synclen == 2)
			{
				startflag = 0;
				syncflag = 0;
				datalenflag = 1;
				datalenindex = 0;
				datalength = 0;
			}	
			nStart += retdatalen;
		}
		else if((ret == 1)&&(datalenflag == 1))
		{
				unsigned short temp = pData;
				temp = ( temp & 0x00ff ) << ( datalenindex * 8 );
				datalength |= temp;
				datalenindex++;
				if(datalenindex == 2)
				{				
					datalenflag = 0;
					dataflag = 1;
					datalenflag = 0;
					dataindex = 0;
					crc = 0;
                    
#ifdef Debug_Printf 
					printf("\n datalength = %d \n",datalength);	
#endif
				}
				nStart += retdatalen;
		}
		else if((ret == 1)&&(dataflag == 1))
		{
		    	desdata[dataindex++] = pData;
#ifdef Debug_Printf
				printf("%02x,", pData);
#endif
				if(dataindex == datalength)
				{
					//–£—ÈºÏ≤È
					for(j = 0; j < datalength - 1; j++)
						crc ^= desdata[j];
					if(crc == desdata[datalength - 1])
					{
						//LOGD("FSK_Module received");
						//g_count ++;					
						//LOGD("\n g_collect = %d \n",++g_collect);	
                        
                        //add by wangzhong
                        g_length = datalength;
						return 1;
					}
					else
					{					
						//LOGD("\n g_wrong = %d \n",++g_wrong);
						//LOGD("data received crc error");
						return -1;
					}
					startflag = 1;
					startlen = 0;
					syncflag = 0;		
					datalenflag = 0;
					dataflag = 0;
					nStart += 1;
				}
				nStart += retdatalen;
		}
		else if((ret == 0)&&(dataflag|datalenflag|syncflag))
		{
#ifdef Debug_Printf
			printf("data received data error");
#endif
			return 99;			
			startflag = 1;
			startlen = 0;
			syncflag = 0;		
			datalenflag = 0;
			dataflag = 0;
			nStart += 1;
		}
		else 
		{
			startflag = 1;
			startlen = 0;
			syncflag = 0;		
			datalenflag = 0;
			nStart += 1;
		}
	}
    
	return 0;
}

/*INT FSK_Demodule( VOID * sample, BYTE * desdata, unsigned long len)
{
    DebugAudioLog(@"");
	
	short * pSamples = NULL;
	short * testp = NULL;
	unsigned char  pData    = NULL;
	unsigned long laddresscount = 0;
	unsigned long nStart = 0;
	unsigned char startlen = 0;
	unsigned char synclen = 0;
	unsigned char startflag = 1;
	unsigned char syncflag = 0;
	unsigned char dataflag = 0;
	unsigned char datalenflag = 0;
	unsigned int  datalength = 0;
	unsigned char datalenindex = 0;
	unsigned char dataindex = 0;
    unsigned char flag = 0; 
	unsigned char datareceiveflag = 0;
	unsigned int retdatalen = 0;
	unsigned char readyretflag = 0;
	unsigned char crc = 0;
	int gStartFlag = 0;
	int gSyncFlag = 0;
	int gDataLenflag = 0;
	int i, j = 0;
	int fflag = 0;
	unsigned char ret;
	short sTmpData = 0;
	
	if ( (!sample) || (!desdata))
		return -1;	
	for ( nStart = 0; nStart < len- 64;  )  // ±‹√‚ ˝æ›∆´“∆
	{
		pSamples = ( short * )sample + nStart ;	

		if((startflag == 1)&&(syncflag ==0)&&(datalenflag == 0)&&(dataflag == 0)&&(startlen == 0))
		{
			sTmpData = *pSamples;
			if((sTmpData<200)&&(sTmpData>-200))
			{
				nStart++;
				continue;
			}
		}	
		
		ret = GetFrameData(&pData, pSamples, (BYTE*)&retdatalen);
		//g_start = pSamples - ( short * )sample;

		if((ret == 1)&&(pData == 0xEF)&&(startflag == 1))
		{
			LOGD("find start data");
			startlen ++;
			if(startlen == 2)
			{
				startflag = 0;
				syncflag = 1;
				synclen = 0;			
			}
			nStart += retdatalen;
		}
		else if((ret == 1)&&(pData == 0x01)&&(syncflag == 1))
		{
			LOGD("find sync data");
			synclen++;
			if(synclen == 2)
			{
				startflag = 0;
				syncflag = 0;
				datalenflag = 1;
				datalenindex = 0;
				datalength = 0;
			}	
			nStart += retdatalen;
		}
		else if((ret == 1)&&(datalenflag == 1))
		{
			LOGD("find datalength data");
				unsigned short temp = pData;
				temp = ( temp & 0x00ff ) << ( datalenindex * 8 );
				datalength |= temp;
				datalenindex++;
				if(datalenindex == 2)
				{				
					datalenflag = 0;
					dataflag = 1;
					datalenflag = 0;
					dataindex = 0;
					crc = 0;
					LOGD(" datalength = %d ",datalength);	
				}
				nStart += retdatalen;
		}
		else if((ret == 1)&&(dataflag == 1))
		{
			LOGD("find  data");
		    	desdata[dataindex++] = pData;					
				LOGD("%02x,", pData);
				if(dataindex == datalength)
				{
					//–£—ÈºÏ≤È
					for(j = 0; j < datalength - 1; j++)
						crc ^= desdata[j];
					if(crc == desdata[datalength - 1])
					{
						g_count ++;					
						LOGD("received data OK");						
						return 1;
					}
					else
					{					
						LOGD("CRC ERROR");
						return -1;
					}
					startflag = 1;
					startlen = 0;
					syncflag = 0;		
					datalenflag = 0;
					dataflag = 0;
					nStart += 1;
				}
				nStart += retdatalen;
		}
	}
	//return 0;

}*/

static VOID DemoduleBufferQueue( INT * len )
{
    DebugAudioLog(@"");
	
	int ret = 0;
	*len=0;
	if ( g_total < 8*1024 )
	{
		//LOGW( "queue need more buffer" );
		return;
	}
	//LOGW( "DemoduleBufferQueue,%d ",g_total);
	//debug_write_to_file(Buffer_Queue,g_total);
	ret = FSK_Demodule( ( void * )Buffer_Queue, ( unsigned char * )OutData, g_total );
	//LOGD( "process a buffer, g_start = %d, g_total = %d", g_start, g_total );

	if(ret==1)
        {
		*len=1;
		memset( Buffer_Queue, 0, MAX_QUEUE_LEN );
		g_start = 0;
		g_total = 0;
		return;
	}
	else if(ret==99)
        {
		memmove( Buffer_Queue, Buffer_Queue + ( g_total - 1024 * 4 ), 1024 * 8 );
		g_total = 1024 * 4;
		g_start = 0;
		return;
	}else{
		memset( Buffer_Queue, 0, MAX_QUEUE_LEN );
		g_start = 0;
		g_total = 0;
		return;
	}
	
	//LOGD( "adjust buffer, g_start = %d, g_total = %d", g_start, g_total );
}

INT DemoduleAudioData( VOID * data, INT len ,unsigned char *tempbuf)
{
    DebugAudioLog(@"");
	
	int ret = 0;
    unsigned long OutLenIndix = 0 ;
    unsigned char MobileType = 1;
	memcpy( ((char*)tempbuf+2*1024*1024),tempbuf,2*1024*1024);
	ret = Demodulation(( unsigned char * )OutData, (SHORT *)data, len/2, &OutLenIndix, MobileType, 0);
	if(ret == 0)
    {
        memcpy( tempbuf,((char*)tempbuf+2*1024*1024),2*1024*1024);
    }
    
	if(ret==1)
        {
		return 1;
	}
	return 0;
}

static unsigned int FSKModule( char * data, int len, short * fsk )
{
    DebugAudioLog(@"");
	
	int  i  = 0;
	int  j  = 0;
	int  k  = 0;	
	char c  = 0;
	char lastStatus = 0;
	if ( !data || !fsk )
		return 0;
    for(int m = 0 ; m < 4 ;m++)
    {
        for ( j = 0; j < 8; j++ )
        {
            for(k = 0;k < 4; k++)
            {
                fsk[64*m+8*j+k] = -32536;
            }
            for(k = 4;k < 8; k++)
            {
                fsk[64*m+8*j+k] = 32536;
            }
        }
    }
    
    for(int q = 0 ; q < 200 ;q++)
    {
        fsk[4*64+q] = 0;
    }
    
    for ( i = 0; i < len; i++ )
	{
		c = data[i];		
		for ( j = 0; j < 8; j++ )
		{            
            if((c<<j)&0x80)	
            {
                if(lastStatus == 0)
                {
                    for(k = 0;k < 4; k++)
                    {
                        fsk[64*i+8*j+k+64*4+200] = 32536;                        
                    }
                    for(k = 4;k < 8; k++)
                    {
                        fsk[64*i+8*j+k+64*4+200] = -32536;
                        
                    }
                    lastStatus = 0;
                }
                else
                {
                    for(k = 0;k < 4; k++)
                    {
                        fsk[64*i+8*j+k+64*4+200] = -32536;
                    }
                    for(k = 4;k < 8; k++)
                    {
                        fsk[64*i+8*j+k+64*4+200] = 32536;
                    }
                    lastStatus = 1;
                }
			}
			else
			{
                if(lastStatus == 0)
                {
                    for(k = 0;k < 8; k++)
                    {
                        fsk[64*i+8*j+k+64*4+200] = 32536;
                    }
                    lastStatus = 1;
                }
                else
                {
                    for(k = 0;k < 8; k++)
                    {
                        fsk[64*i+8*j+k+64*4+200] = -32536;
                    }
                    lastStatus = 0;
                }
                
            } 
        }
    }	
    
    if(lastStatus == 0)
    {
        for(k = 0;k < 8; k++)
        {
            fsk[64*i+k+64*4+200] = 32536;
        }
        lastStatus = 1;
    }
    else
    {
        for(k = 0;k < 8; k++)
        {
            fsk[64*i+k+64*4+200] = -32536;
        }
        lastStatus = 0;
    }
    if(lastStatus == 0)
    {
        for(k = 8;k < 16; k++)
        {
            fsk[64*i+k+64*4+200] = 32536;
        }
        lastStatus = 1;
    }
    else
    {
        for(k = 8;k < 16; k++)
        {
            fsk[64*i+k+64*4+200] = -32536;
        }
        lastStatus = 0;
    }
	//return i*64+16+64*4+200;
    return len*64;
}
/*static UINT FSKModule( CHAR * data, INT len, SHORT * fsk )
{
    DebugAudioLog(@"");
	
	INT  d[ 8 ];
	INT  n  = 0;
	INT  i  = 0;
	INT  j  = 0;
	INT  k  = 0;
	INT  ia = 0;
	CHAR c  = 0;

	if ( !data || !fsk )
		return n;

	build_sin_table( sin_bit0, 2 );
	build_sin_table( sin_bit1, 4 );

	for ( i = 0; i < len; i++ )
	{
		c = data[ i ];

		memset( d, 0, 8 * sizeof( INT ) );

		for ( j = 0; j < 8; j++ )
		{
			d[ j ] = ( c << j ) & 0x80;

			if ( d[ j ] == 0x80 )
				ia = 1;
			else
				ia = 0;

			for( k = 0; k < ( FS / FB ); k++ )
			{
				n = ( i * 8 + j ) * ( FS / FB ) + k;

				if ( ia == 1 )
					fsk[ n ] = sin_bit1[ k ];
				else
					fsk[ n ] = sin_bit0[ k ];
			}
		}
	}

	return n + 1;
}*/

VOID * BuildFSKDataFrame( CHAR * data, INT len, INT * frame_len )
{
    DebugAudioLog(@"");
	
    for(int i=0; i<len; i++)
    {
        printf("%02x ",data[i]);
    }
    printf("\n\n");
	SHORT        * s      = NULL;
	//char *cmd=NULL;
	INT            n      = 0;
	int totallen=(len)*128+9216;
	//LOGD("send data len=%d",len);
	/*FSKDataFrame   Frame;
	memset( &Frame, 0, sizeof( FSKDataFrame ) );	
	memset( Frame.FrameStartFlag, START_FLAG, START_FLAG_LENGTH );
	memset( Frame.FrameSyncFlag,  SYNC_FLAG,  SYNC_FLAG_LENGTH  );	
	Frame.DataLength = len;*/
	s = ( SHORT * )calloc(totallen , 1);
	memset((char*)s,0,totallen);
	n=FSKModule(data,len,s+4096);
	*frame_len=n*2+9216;
	 //debug_write_to_file( s, *frame_len*2);
        //LOGD("FSK build commandlen=%d,fsklen=%d",len,*frame_len);
	//*frame_len=*frame_len*2;
	return s;
	
	/*CHAR           c      = ' ';
	INT            n      = 0;
	INT            i      = 0;
	INT            j      = 0;
	INT            k      = 0;
	INT            ia     = 0;
	SHORT        * s      = NULL;
	FSKDataFrame   Frame;

	*frame_len = 0;

	if ( !data )
	{
		debug_log( FSK_MODEM_MODULE, "\nBuildFSKDataFrame - data = NULL\n" );
		return s;
	}

	memset( &Frame, 0, sizeof( FSKDataFrame ) );	
	memset( Frame.FrameStartFlag, START_FLAG, START_FLAG_LENGTH );
	memset( Frame.FrameSyncFlag,  SYNC_FLAG,  SYNC_FLAG_LENGTH  );	

	Frame.DataLength = len;

	s = ( SHORT * )calloc( ( sizeof( FSKDataFrame ) + len ) * ( FS / FB ) * 8 * sizeof( INT ), 1 );	

	if ( !s )
	{
		debug_log( FSK_MODEM_MODULE, "\nBuildFSKDataFrame - calloc failed\n" );
		return s;
	}	

	n = FSKModule( ( CHAR * )&Frame, sizeof( FSKDataFrame ), s );	

	*frame_len += n;	

	n = FSKModule( data, len, s + n );	

	*frame_len += n;
	

	return s;*/
}

    //add by wangzhong
    
    
    LPSTR errorMessageData(INT status)
    {
        DebugAudioLog(@"error status = %02x",status);
        LPSTR msg = (LPSTR)calloc(1024, sizeof(CHAR));
        memset(msg, 0, 1024);
        switch (status)
        {
            case 0x6181:
                memcpy(msg, "RSA密钥生成失败", strlen("RSA密钥生成失败"));
                break;
            case 0x6581:
                memcpy(msg, "存储问题", strlen("存储问题"));
                break;
            case 0x6700:
                memcpy(msg, "LC长度错误", strlen("LC长度错误"));
                break;
                
            //------------698x----------
            case 0x6982:
                memcpy(msg, "安全状态不满足", strlen("安全状态不满足"));
                break;
            case 0x6983:
                memcpy(msg, "PIN码已经被锁定", strlen("PIN码已经被锁定"));
                break;
            case 0x6984:
                memcpy(msg, "引用的数据无效", strlen("引用的数据无效"));
                break;
            case 0x6985:
                memcpy(msg, "使用的条件不满足", strlen("使用的条件不满足"));
                break;
            case 0x6986:
                memcpy(msg, "命令不被允许(无当前EF)", strlen("命令不被允许(无当前EF)"));
                break;
            case 0x6988:
                memcpy(msg, "MAC 认证失败", strlen("MAC 认证失败"));
                break;
            case 0x698a:
                memcpy(msg, "应用ID错误", strlen("应用ID错误"));
                break;
                
            //------------6a8x----------
            case 0x6a80:
                memcpy(msg, "在数据字段中的不正确参数", strlen("在数据字段中的不正确参数"));
                break;
            case 0x6a81:
                memcpy(msg, "功能不被支持", strlen("功能不被支持"));
                break;
            case 0x6a84:
                memcpy(msg, "无足够的文件存储空间", strlen("无足够的文件存储空间"));
                break;
            case 0x6a86:
                memcpy(msg, "P1、P2 参数错误", strlen("P1、P2 参数错误"));
                break;
            case 0x6a88:
                memcpy(msg, "引用的数据未找到", strlen("引用的数据未找到"));
                break;
            case 0x6a89:
                memcpy(msg, "应用已经存在", strlen("应用已经存在"));
                break;
            case 0x6a8a:
                memcpy(msg, "指定的应用已打开", strlen("指定的应用已打开"));
                break;
            case 0x6a8b:
                memcpy(msg, "指定的应用不存在", strlen("指定的应用不存在"));
                break;
            case 0x6a8c:
                memcpy(msg, "引用的对称密钥不存在", strlen("引用的对称密钥不存在"));
                break;
            case 0x6a8d:
                memcpy(msg, "数据错误", strlen("数据错误"));
                break;
                
            //------------6a8x----------
            case 0x6a90:
                memcpy(msg, "已有打开的应用，当前设备不支持同时打开多个应用", strlen("已有打开的应用，当前设备不支持同时打开多个应用"));
                break;
            case 0x6a91:
                memcpy(msg, "指定的容器不存在", strlen("指定的容器不存在"));
                break;
            case 0x6a92:
                memcpy(msg, "文件已经存在", strlen("文件已经存在"));
                break;
            case 0x6a93:
                memcpy(msg, "指定的文件不存在", strlen("指定的文件不存在"));
                break;
            case 0x6a94:
                memcpy(msg, "引用的容器未找到", strlen("引用的容器未找到"));
                break;
            case 0x6a95:
                memcpy(msg, "容器中没有对应的密钥对", strlen("容器中没有对应的密钥对"));
                break;
            case 0x6a96:
                memcpy(msg, "指定类型的证书不存在", strlen("指定类型的证书不存在"));
                break;
            case 0x6a97:
                memcpy(msg, "数据写入失败", strlen("数据写入失败"));
                break;
            case 0x6a98:
                memcpy(msg, "验证签名失败", strlen("验证签名失败"));
                break;
            case 0x6a99:
                memcpy(msg, "不支持的会话密钥算法标识", strlen("不支持的会话密钥算法标识"));
                break;
            case 0x6a9a:
                memcpy(msg, "非对称加密失败", strlen("非对称加密失败"));
                break;
            case 0x6a9b:
                memcpy(msg, "非对称解密失败", strlen("非对称解密失败"));
                break;
            case 0x6a9c:
                memcpy(msg, "私钥签名失败", strlen("私钥签名失败"));
                break;
            case 0x6a9d:
                memcpy(msg, "不支持的摘要算法标识", strlen("不支持的摘要算法标识"));
                break;
            case 0x6a9e:
                memcpy(msg, "还有更多数据需要上传，接口层需重新发送指令获取后续数据", strlen("还有更多数据需要上传，接口层需重新发送指令获取后续数据"));
                break;
                
            //------------6b0x----------
            case 0x6b00:
                memcpy(msg, "给定的偏移值超出文件长度", strlen("给定的偏移值超出文件长度"));
                break;
            case 0x6b01:
                memcpy(msg, "生成密钥协商数据失败", strlen("生成密钥协商数据失败"));
                break;
            case 0x6b02:
                memcpy(msg, "生成协商密钥失败", strlen("生成协商密钥失败"));
                break;
                
            //------------6e0x----------
            case 0x6e00:
                memcpy(msg, "CLA错误，指定的类别不被支持", strlen("CLA错误，指定的类别不被支持"));
                break;
                
            //------------930x----------
            case 0x9303:
                memcpy(msg, "应用已被永久锁定", strlen("应用已被永久锁定"));
                break;
            case 0x9304:
                memcpy(msg, "卡已锁定", strlen("卡已锁定"));
                break;
                
            //------------94Fx----------
            case 0x94fc:
                memcpy(msg, "算法计算失败", strlen("算法计算失败"));
                break;
            case 0x94fd:
                memcpy(msg, "非对称密钥计算失败", strlen("非对称密钥计算失败"));
                break;
            case 0x94fe:
                memcpy(msg, "应用临时锁定", strlen("应用临时锁定"));
                break;
            case 0x94ff:
                memcpy(msg, "应用永久锁定", strlen("应用永久锁定"));
                break;
                
            //------------91xx----------
            case 0x9110:
                memcpy(msg, "IC卡初始化失败", strlen("IC卡初始化失败"));
                break;
            case 0x9111:
                memcpy(msg, "IC卡读主目录失败", strlen("IC卡读主目录失败"));
                break;
            case 0x9112:
                memcpy(msg, "没有可以查询的应用", strlen("没有可以查询的应用"));
                break;
            case 0x9113:
                memcpy(msg, "IC卡打开应用失败", strlen("IC卡打开应用失败"));
                break;
            case 0x9115:
                memcpy(msg, "GPO命令出错，或者AIP,AFL提取出错", strlen("GPO命令出错，或者AIP,AFL提取出错"));
                break;
            case 0x9116:
                memcpy(msg, "没有提取到CODL1数据", strlen("没有提取到CODL1数据"));
                break;
            case 0x9117:
                memcpy(msg, "没有收到密文数据", strlen("没有收到密文数据"));
                break;
            case 0x9118:
                memcpy(msg, "生成明文失败", strlen("生成明文失败"));
                break;
            case 0x9119:
                memcpy(msg, "外部认证不通过", strlen("外部认证不通过"));
                break;
            case 0x9120:
                memcpy(msg, "圈存失败", strlen("圈存失败"));
                break;
            case 0x9121:
                memcpy(msg, "日志生成失败", strlen("日志生成失败"));
                break;
            case 0x9123:
                memcpy(msg, "读现金余额失败", strlen("读现金余额失败"));
                break;
            case 0x9124:
                memcpy(msg, "读现金余额上限失败", strlen("读现金余额上限失败"));
                break;
            case 0x9125:
                memcpy(msg, "余额超过上限", strlen("余额超过上限"));
                break;
            case 0x9126:
                memcpy(msg, "现金格式出错", strlen("现金格式出错"));
                break;
                
            //------------63cx----------
            case 0x63c0:
            case 0x63c1:
            case 0x63c2:
            case 0x63c3:
            case 0x63c4:
            case 0x63c5:
            case 0x63c6:
            case 0x63c7:
            case 0x63c8:
            case 0x63c9:
            case 0x63ca:
            case 0x63cb:
            case 0x63cc:
            case 0x63cd:
            case 0x63ce:
            case 0x63cf:
                char err[50];
                sprintf(err, "认证失败，还剩下%d次重试机会",status-0x63c0);
                memcpy(msg, err, strlen(err));
                break;
                
            default:
                memcpy(msg, "操作失败", strlen("操作失败"));
                break;
        }
        return msg;
    }
    
    
    void DecimalToBinary(int num, int *outDec)
    {
        for(int i=7; i>=0; i--)
        {
            outDec[i] = (num >> (7-i)) & 0x1;
        }
    }
    
    VOID GetAllReturnData( COS_DATA * data )
    {
        DebugAudioLog(@"");
        COS_DATA * pData = data;
        SHORT nData  = 0;
        SHORT nData1 = 0;
        SHORT nData2 = 0;
        
    
        pData->Length = g_length - 4;
        printf("pData->Length = %d\n", pData->Length);
        
        
        nData1 = OutData[2];
        nData2 = OutData[3];
        nData  = nData2 << 8 | nData1;
        pData->Status = nData;
        printf("pData->Status = %d\n", nData);
        printf("pData->Status = %02x\n", nData);
        pData->Type = GetSendType();
        
        if( pData->Type == USER_SEND_COMMAND )
        {
            if (pData->Status == ( SHORT )0x9000 || pData->Status == ( SHORT )0x9999)
            {
                pData->Data = calloc( sizeof( CHAR ), pData->Length + 1 );
                memcpy( pData->Data , OutData + 4, pData->Length );
            }
            else
            {
                LPSTR errormsg = errorMessageData((INT)nData);
                
                pData->Data = calloc( sizeof( CHAR ), strlen(errormsg) + 1 );
                pData->Length = strlen(errormsg);
                memcpy( pData->Data , errormsg, strlen(errormsg) );
            }
        }
        else if ( pData->Type == _6100_token_COMMAND )
        {
            ApiType apitype = [CMobileShield get6100ApitType];
            if(apitype == (ApiType)0xF3)
            {
                if (pData->Status == ( SHORT )0x9000 || pData->Status == ( SHORT )0x9999)
                {
                    pData->Data = calloc( sizeof( CHAR ), pData->Length + 1 );
                    memcpy( pData->Data , OutData + 4, pData->Length );
                    
                    unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                    memcpy(result, pData->Data, 2);
                    if (result[0] == 0x77 && result[1] == 0x77)
                    {
                        BYTE respCode[2];
                        memcpy(respCode, OutData+10, 2);
                        DecimalToBinary(respCode[0], pData->respCode[0]);
                        DecimalToBinary(respCode[1], pData->respCode[1]);
                    }
                }
                else
                {
                    LPSTR errormsg = errorMessageData((INT)nData);
                    
                    pData->Data = calloc( sizeof( CHAR ), strlen(errormsg) + 1 );
                    pData->Length = strlen(errormsg);
                    memcpy( pData->Data , errormsg, strlen(errormsg) );
                }
            }
            else
            {
                BYTE respCode[2];
                memcpy(respCode, OutData+4, 2);
                DecimalToBinary(respCode[0], pData->respCode[0]);
                DecimalToBinary(respCode[1], pData->respCode[1]);
                
                
                pData->Data = calloc( sizeof( CHAR ), pData->Length );
                memcpy( pData->Data , OutData + 6, pData->Length-2 );
            }
        }
    }
    
    
VOID GetReturnData( COS_DATA * data )
{
    DebugAudioLog(@"");
	
	COS_DATA * pData = data;
	SHORT nData  = 0;
	SHORT nData1 = 0;
	SHORT nData2 = 0;

	pData->Type = GetSendType();

	if ( pData->Type == USER_SEND_COMMAND )
	{
#ifndef COMMUNICATION_TEST
		nData1 = OutData[0];
		nData2 = OutData[1];
		nData  = nData2 << 8 | nData1;
		pData->Status = nData;
		nData1 = OutData[2];
		nData2 = OutData[3];
		nData  = nData2 << 8 | nData1;
		pData->Length = nData;
		pData->Data   = NULL;
#else
		pData->Status = ( SHORT )0x9000;
		pData->Length = g_DataLength;
		pData->Data = calloc( sizeof( CHAR ), pData->Length + 1 );
		memcpy( pData->Data, OutData, pData->Length );
#endif
	}
	else if ( pData->Type == READ_RETURN_DATA )
	{
		pData->Status = 0x0000;
		pData->Length = GetReadDataLength();

		pData->Data = calloc( sizeof( CHAR ), pData->Length + 1 );

		memcpy( pData->Data, OutData, pData->Length );
	}
	else
	{
#ifdef Debug_Printf
		printf("\npData->Type Error\n" );
#endif
	}
}

VOID SetJudgementFlag( bool flag )
{
    DebugAudioLog(@"");
	
	g_Judgement = flag;
}

bool GetJudgementFlag()
{
    DebugAudioLog(@"");
	
	return g_Judgement;
}

VOID SetSinuidalFlag( bool flag )
{
    DebugAudioLog(@"");
	
	g_Sinuidal = flag;
}

bool GetSinuidalFlag()
{
    DebugAudioLog(@"");
	
	return g_Sinuidal;
}

VOID MobileShieldInit( bool flag, bool style, VOID * obj, VOID * cbf )
{
    DebugAudioLog(@"");
	
	SetSinuidalFlag( flag );
	//LOGW("MobileShieldInit! Set flag to %d",flag);
	/*BOOL IsFind   = FALSE;
	INT  nCount   = 3;

	SetOutputModule( OPEN_ALL_MODULE );
//	SetOutputModule( JNI_MODULE | FSK_MODEM_MODULE );
	return;
#ifndef COMMUNICATION_TEST
	debug_log( AUDIO_MODULE, "\nMobileShieldInit\n" );
	if ( flag == 1 )
	{
		SetSinuidalFlag( ( BOOL )style );
		SetJudgementFlag( ( BOOL )flag );

		return;
	}

	while ( !GetJudgementFlag() && nCount )
	{
		SetSinuidalFlag( TRUE );
		CMD_HandShake( obj, cbf );

		if ( GetJudgementFlag() )
		{
			IsFind = TRUE;
			break;
		}

		SetSinuidalFlag( FALSE );
		CMD_HandShake( obj, cbf );

		if ( GetJudgementFlag() )
		{
			IsFind = TRUE;
			break;
		}

		nCount--;
	}

	if ( !IsFind )
	{
		// Œ’ ÷≥ˆ¥Ì
		// Todo:
		Return_Data param;

		debug_log( AUDIO_MODULE, "\nIsFind = FALSE\n" );
		param.Status = 0;
		param.Type   = 0;
		param.Data   = NULL;
#ifndef WEBKIT_PLUGIN
		CallBackJAVAMethod( obj, 0, &param, cbf );
#endif		
	}
#else
	SetSinuidalFlag( style );
	SetJudgementFlag( flag );
#endif*/
}


//add for new demodel

/*****************************************
    功能:找到同步头  55550101 或 EFEF0101
    本函数调用的函数清单: 无
    调用本函数的函数清单: main
    输入参数:  *DataBuf   
    输出参数:  第几个点开始是数据
    函数返回值说明:   
    使用的资源 
******************************************/
unsigned char FindHead(short * InDataBuf,unsigned long lenth,unsigned long *endlen,unsigned char MobileType)
{
    DebugAudioLog(@"");
	
	unsigned long i = 0;//指向第i个点

	float LengthOfZorePassage = 0;//过零点之间宽度
	float LastRatio = 0;///过零点上一次的比率
	float	RatioOfZorePassage = 0;//过零点这一次的比率

	unsigned long NumberOfLow = 0;//小幅度波的个数
	unsigned long DataHead = 0;//同步头
	unsigned long datastart = 0;//当前在解的波的开始点
	unsigned char bit0flag = 0;//用于实现两个小波表示1
	
	for(;i<lenth;)
	{   
		NumberOfLow = 0;
		while((InDataBuf[i] < 500)&&(InDataBuf[i] > -500)) //直到有大于500的点，去"串扰"
		{
			i++;
			NumberOfLow++;
			if(i == lenth)
			{
				return 0;
			}
		}
		if(NumberOfLow < 5)//对于中间出现的小幅度波小于5，要退回去
		{
			i -= NumberOfLow;
		}
		datastart = i;//当前波的开始点
		LastRatio = RatioOfZorePassage;//保存上一次的过零点比率
		if(InDataBuf[i] >= 0)//如果采样值大于等于0
		{
			while(InDataBuf[i] >= 0)//直到采样值小于0
			{
				i++;//下一个采样点	
			}
		}
		else//如果采样值小于0
		{
			while(InDataBuf[i] < 0)//直到采样值大于?
			{
				i++;//下一个采样点				
			}
		}
		RatioOfZorePassage = (float(abs(InDataBuf[i]))) 
							/ ( float(abs(InDataBuf[i - 1])) + float(abs(InDataBuf[i])) );

		//记下当前波过零点之间的宽度	
		if(i == 702)
		i = i+0;
	    LengthOfZorePassage =LastRatio  + (i - datastart - 1) + (1 - RatioOfZorePassage);
		if(( LengthOfZorePassage >=  (3.0/ 2.0)*((float) MobileType+1.0) )
					&&(LengthOfZorePassage<(8.0/ 3.0)*((float) MobileType+1.0))) //如果是大波		

		{
			if(bit0flag == 1)
			{
				DataHead = 0;//如果小波之后是大波，则重新开始找头
				bit0flag = 0;
			}
			DataHead = DataHead<<1;
			DataHead &= 0xFFFFFFFE;	
				   //	0xEFEF0101
		}
		else if((LengthOfZorePassage>= ((float) MobileType+1.0)/3.0)
						&&(LengthOfZorePassage< (3.0/2.0)*((float) MobileType+1.0))) //如果是小波
		{
			if(bit0flag == 0)//如果是第一个小波
			{
				bit0flag = 1;
				continue;
			}
			else//如果是第二个小波
			{
                DataHead = DataHead<<1;		
				DataHead |= 0x00000001;
						//	0xEFEF0101
				bit0flag = 0;//两个小波为"1"
			}			
		}
		//else if(LengthOfZorePassage < (2.0/3.0)) //如果是超小波，认为是杂波
		else 
		{
			DataHead = 0;//如果其它，则重新开始找头
		}
		
		if( DataHead == 0xEFEF0101 )//这里需要注意，发上去和发下来的同步头是不同的
		{
			*endlen = i;
			return 1;//从i点开始，都是数据了
		}
	}
	return 0;
}

/*****************************************
    功能:   CRC
    本函数调用的函数清单: 无
    调用本函数的函数清单: GetAllData
    输入参数:  *buf    采样值地址
    		 	len        总长度

    输出参数: 
    函数返回值说明:    CRC值
    使用的资源 
******************************************/
unsigned int chkcrc(unsigned char *buf,unsigned short len)
{
    DebugAudioLog(@"");
	
	unsigned char hi,lo;
	unsigned short i;
	unsigned char j;
	unsigned short crc;
	crc=0xFFFF;
	for (i=0;i<len;i++)
	{
		crc=crc ^ *buf;
		for(j=0;j<8;j++)
		{
			unsigned char chk;
			chk=crc&1;
			crc=crc>>1;
			crc=crc&0x7fff;
			if (chk==1)
				crc=crc^0x8408;
			crc=crc&0xffff;
		}
		buf++;
	}
	hi=crc%256;
	lo=crc/256;
	crc=(hi<<8)|lo;
	return crc;
}

/*****************************************
    功能:   解出全部据数
    本函数调用的函数清单: 无
    调用本函数的函数清单: main
    输入参数:  *InDataBuf    采样值地址
    		 	lenth        总长度
    		 	startlen     开始的地方
    		 	MmobileType  手机类型
    输出参数:  *OutDataBuf   数据保存的地方
    		   *endlen       解到哪点了
    函数返回值说明:    0为出错，1为成功解出8位数据
    使用的资源 
******************************************/
unsigned char GetAllData(unsigned char *OutDataBuf, short *InDataBuf,unsigned long lenth,
									unsigned long *endlen,unsigned char MobileType,unsigned char TestCommunication)
{
        DebugAudioLog(@"");
	
	unsigned long i = *endlen - 1;//指向第i个点
	unsigned short j = 0;//指向第j个解出的数据
	unsigned short DataLenth = 0;//整个数据的长度，由数据前两字节表示
	
	float 	LengthOfZorePassage = 0;//过零点之间宽度
	float	LastRatio = 0;///过零点上一次的比率
	float	RatioOfZorePassage = 0;//过零点这一次的比率
	unsigned long datastart = 0;//当前在解的波的开始点
		
	unsigned char bit0flag = 0;//用于实现两个小波表示1
	unsigned char bitindex = 0;//解出来的数据的位数
	unsigned short crc = 0;//用于校验

/************************************/		
//下面的参数用于实现波形兼容性检查////
	float MaxOf0Wide = 0;//0中宽度偏差之最
	float MaxOf1Wide = 0;// 1中宽度偏差之最
/************************************/	
for(;i<lenth ;)
{   
		datastart = i;//当前波的开始点
		LastRatio = RatioOfZorePassage;//保存上一次的过零点比率
		if(InDataBuf[i] >= 0)//如果采样值大于等于0
		{
			while(InDataBuf[i] >= 0)//直到采样值小于0
			{
				i++;//下一个采样点	
			}
		}
		else//如果采样值小于0
		{
			while(InDataBuf[i] < 0)//直到采样值大于0
			{
				i++;//下一个采样点				
			}
		}
		RatioOfZorePassage =  
			(float(abs(InDataBuf[i]))) / ( float(abs(InDataBuf[i - 1])) + float(abs(InDataBuf[i])) );

		//记下当前波过零点之间的宽度	
	    LengthOfZorePassage =LastRatio  + (i - datastart - 1) + (1 - RatioOfZorePassage);
		if(( LengthOfZorePassage >=  (3.0/ 2.0)*((float) MobileType+1.0) )
					&&(LengthOfZorePassage<(8.0/ 3.0)*((float) MobileType+1.0))) //如果是大波	
		{
			if(bit0flag == 1)//小波后面是大波就是出错了
			{
				*endlen = i;
				return 0;
			}
			/********************************************************/
			if(TestCommunication == 1)//需要比较? 则计算出偏差最大的那个
			{
				if(  fabs(LengthOfZorePassage - (MobileType+1)*2) > fabs(MaxOf0Wide) )
				{
					MaxOf0Wide = (LengthOfZorePassage - (MobileType+1)*2);
				}
			}
			/********************************************************/
			OutDataBuf[j]  &= ~(1<<(7-bitindex));
			bitindex++;
		}
			
		else if((LengthOfZorePassage>= (2.0/3.0)*((float) MobileType+1.0)/2.0)
						&&(LengthOfZorePassage< (3.0/2.0)*((float) MobileType+1.0))&&(i != *endlen)) //如果是小波
		{
			/********************************************************/
			if(TestCommunication == 1)//需要比较? 则计算出偏差最大的那个
			{
				if( fabs(LengthOfZorePassage - (MobileType+1)) > fabs(MaxOf1Wide) )
				{
					MaxOf1Wide = (LengthOfZorePassage - (MobileType+1));
				}
			}
			/********************************************************/
			if(bit0flag == 0)//如果是第一个小波
			{
				bit0flag = 1;
				continue;
			}
			else//如果是第二个小波
			{   
				OutDataBuf[j] |= 1<<(7-bitindex);			
				bitindex++;
				bit0flag = 0;//两个小波为"1"
			}			
		}
		else 
		{	
			if(i == *endlen)//第一个波只取了一点，所以肯定是非常小的
			{
				continue;
			}
			*endlen = i;
			return 0;//出现其它的波，直接认为出错了
		}

		
		if( bitindex == 8 )//8位1字节
		{
			j++;
			bitindex = 0;
		}
		if(( j == 2)&&(bitindex == 0))//一开始两个字节是数据长度
		{
			DataLenth =  OutDataBuf[0] | (OutDataBuf[1] << 8);
            g_length = DataLenth;
		}
		//if(( j == 4)&&(bitindex == 0))
		if(( j == DataLenth + 2) && (j >= 2))//全部解出来了
		{
/***********************************************************************************/
			if(TestCommunication == 1)//需要比较?
			{
				MaxOf0Wide = (3*MaxOf0Wide/(MobileType + 1)/2);
				MaxOf1Wide = (3*MaxOf1Wide/(MobileType + 1));
				if( (fabs(MaxOf0Wide) > 0.7) || (fabs(MaxOf1Wide) > 0.9))//宽度相差太大了
				{
					return 0;//
				}
			}
/*************************************************************************全部异或
			for(k = 2; k < DataLenth+1; k++)//计算校验，除长度之外，全部异或
			{
				crc ^= OutDataBuf[k];
			}						
			if(crc != OutDataBuf[DataLenth + 1])//如果校验通不过
			{			
				printf("\n CRC error \n");	//打印校验出错
				*endlen = i;
				return 0;//校验出错
			}
**************************************************************************////////
/*************************************************************************CRC16**/
			crc = OutDataBuf[DataLenth] | (OutDataBuf[DataLenth + 1] << 8);
			if(crc != chkcrc(OutDataBuf,DataLenth))//如果校验通不过
			{			
				*endlen = i;
				return 0;//校验出错
			}
/***********************************************************************************/
            
            printf("\n\n]\\n");
            for(int i=2; i<DataLenth; i++)
            {
                printf("%02x ",OutDataBuf[i]);
                if(((i-2)+1)%4 == 0)
                {
                    printf(" ");
                }
            }
            printf("\n\n");
			*endlen = i;
			return 1;
		}
	}
	*endlen = i;
	return 0;//没有数据
}
    
    //+++++++++++++++test
    /*****************************************
     功能:   解出全部据数
     本函数调用的函数清单: 无
     调用本函数的函数清单: main
     输入参数:  *InDataBuf    采样值地址
     lenth        总长度
     startlen     开始的地方
     MmobileType  手机类型
     输出参数:  *OutDataBuf   数据保存的地方
     *endlen       解到哪点了
     函数返回值说明:    0为出错，1为成功解出8位数据-1为crc校验错误
     使用的资源
     ******************************************/
    BYTE GetAllDataTest(BYTE *OutDataBuf, short *InDataBuf, unsigned long lenth,unsigned long *endlen,BYTE MobileType)
    {
        //    printf("\n ");
        //    for(int a=0 ; a< 10; a++)
        //    {
        //        printf("%02x ",OutDataBuf[a]);
        //    }
        //    printf("\n");
        unsigned long i = *endlen - 1;//指向第i个点
        unsigned long j = 0;//指向第j个解出的数据
        unsigned long DataLenth = 0;//整个数据的长度，由数据前两字节表示
        
        float 	LengthOfZorePassage = 0;//过零点之间宽度
        float	LastRatio = 0;///过零点上一次的比率
        float	RatioOfZorePassage = 0;//过零点这一次的比率
        unsigned long datastart = 0;//当前在解的波的开始点
        
        BYTE bit0flag = 0;//用于实现两个小波表示1
        BYTE bitindex = 0;//解出来的数据的位数
        unsigned short crc = 0;//用于校验
        /************************************/
        //下面的参数用于实现0 、1 幅度的对比//
        unsigned short highest = 0;//每一位中，采样值的最高点//
        unsigned long sum0 = 0;//0的总和
        unsigned long sum1 = 0;// 1的总和
        unsigned short number0 = 0;//0的个数
        unsigned short number1 = 0;// 1的个数
        unsigned long k = 0;//用于实现查找每一位中的最高采样率 等 普通循环
        float RatioOf0b1 = 0;// 所有1 中最高采样之和 与 所有0中最高采样之和    的比率。
        /************************************/
        /************************************/
        //下面的参数用于实现波形兼容性检查////
        float MaxOf0Wide = 0;//0中宽度偏差之最
        float MaxOf1Wide = 0;// 1中宽度偏差之最
        /************************************/
        for(;i<lenth ;)
        {
            datastart = i;//当前波的开始点
            LastRatio = RatioOfZorePassage;//保存上一次的过零点比率
            if(InDataBuf[i] >= 0)//如果采样值大于等于0
            {
                while(InDataBuf[i] >= 0 && i < lenth)//直到采样值小于0
                {
                    i++;//下一个采样点
                }
            }
            else//如果采样值小于0
            {
                while(InDataBuf[i] < 0 && i < lenth)//直到采样值大于0
                {
                    i++;//下一个采样点
                }
            }
            RatioOfZorePassage = \
            (float(abs(InDataBuf[i]))) / ( float(abs(InDataBuf[i - 1])) + float(abs(InDataBuf[i])) );
            
            //记下当前波过零点之间的宽度
            LengthOfZorePassage =LastRatio  + (i - datastart - 1) + (1 - RatioOfZorePassage);
            if(( LengthOfZorePassage >=  (3.0/ 2.0)*((float) MobileType+1.0) )
               &&(LengthOfZorePassage<(12.0/ 3.0)*((float) MobileType+1.0))) //如果是大波
            {
                if(bit0flag == 1)//小波后面是大波就是出错了
                {
                    *endlen = i;
                    return 0;
                }
                /********************************************************/
                highest = abs(InDataBuf[datastart]);//置初值
                for(k = datastart+1;k < i;k++)//找出该位中的最高采样值
                {
                    if( (abs(InDataBuf[k])) > highest )
                    {
                        highest = abs(InDataBuf[k]);
                    }
                }
                if(highest < 300)//最高采样值不应该比300还低
                {
                    *endlen = i;
                    return 0;
                }
                number0++;//多少个0
                sum0 += highest;//统计0的采样值之和
                /********************************************************/
                if(  fabs(LengthOfZorePassage - (MobileType+1)*2) > fabs(MaxOf0Wide) )
                {
                    MaxOf0Wide = (LengthOfZorePassage - (MobileType+1)*2);
                }
                /********************************************************/
                //            printf("bitindex = %08x \n",bitindex);
                //            printf("j = %02lu ，OutDataBuf[j] = %08x \n",j,OutDataBuf[j]);
                OutDataBuf[j]  &= ~(1<<(7-bitindex));
                //            printf("OutDataBuf[j]  &= ~(1<<(7-bitindex))    i = %lu, j = %02lu,   %08x  ---  %08x \n\n",i,j,InDataBuf[i], OutDataBuf[j]);
                bitindex++;
            }
            
            else if((LengthOfZorePassage>= (1.0/3.0)*((float) MobileType+1.0))
                    &&(LengthOfZorePassage< (3.0/2.0)*((float) MobileType+1.0))&&(i != *endlen)) //如果是小波
            {
                /********************************************************/
                if( fabs(LengthOfZorePassage - (MobileType+1)) > fabs(MaxOf1Wide) )
                {
                    MaxOf1Wide = (LengthOfZorePassage - (MobileType+1));
                }
                /********************************************************/
                if(bit0flag == 0)//如果是第一个小波
                {
                    bit0flag = 1;
                    continue;
                }
                else//如果是第二个小波
                {
                    /********************************************************/
                    highest = abs(InDataBuf[datastart]);//置初值
                    for(k = datastart+1;k < i;k++)//找出该位中的最高采样值
                    {
                        if( abs(InDataBuf[k]) > highest )
                        {
                            highest = abs(InDataBuf[k]);
                        }
                    }
                    if(highest < 300)//最高采样值不应该比300还低
                    {
                        *endlen = i;
                        return 0;
                    }
                    number1++;//多少个1
                    sum1 += highest;//统计1的采样值之和
                    /********************************************************/
                    //                printf("bitindexL = %08x \n",bitindex);
                    //                printf("j = %02lu ，OutDataBuf[j] = %08x \n",j,OutDataBuf[j]);
                    OutDataBuf[j] |= 1<<(7-bitindex);
                    //                printf("OutDataBuf[j] |= 1<<(7-bitindex)    i = %lu, j = %02lu,   %08x  ---  %08x \n\n",i,j,InDataBuf[i], OutDataBuf[j]);
                    bitindex++;
                    bit0flag = 0;//两个小波为"1"
                }
            }
            else
            {
                if(i == *endlen)//第一个波只取了一点，所以肯定是非常小的
                {
                    continue;
                }
                *endlen = i;
                return 0;//出现其它的波，直接认为出错了
            }
            
            
            if( bitindex == 8 )//8位1字节
            {
                //LOGE("%02x",OutDataBuf[j]);
                
                //            printf("\n************\ni = %lu, j = %02lu,   %08x  ---  %08x \n++++++++++\n\n",i,j,InDataBuf[i], OutDataBuf[j]);
                j++;
                bitindex = 0;
            }
            if((j == 1) && (bitindex == 0))// 一开始1个字节是计数器
                j =1;//////这个域就不需要了。。。。。。
            if((j == 3)&&(bitindex == 0))// 接下来两个字节是数据长度
            {
                DataLenth =  OutDataBuf[1] | (OutDataBuf[2] << 8);
            }
            if(( j == DataLenth + 3 + 2) && (j >= 3))//全部解出来了
            {
                /*************************************************************************CRC16**/
                crc = OutDataBuf[DataLenth + 3] + (OutDataBuf[DataLenth + 4] << 8);
                if(crc != chkcrc(OutDataBuf,DataLenth + 3))//如果校验通不过
                {
                    //				LOGE("crc is wrong ");
                    
                    *endlen = i;
                    return -1;//校验出错
                }
                /***********************************************************************************/
                
                printf("\n i= %lu, j = %lu\n",i,j);
                for(int a=0 ; a< j; a++)
                {
                    printf("%02x ",OutDataBuf[a]);
                }
                printf("\n");
                
                *endlen = i;
                return 1;
            }
        }
        *endlen = i;
        return 0;//没有数据
    }
    //+++++++++++++++test

/*****************************************
    功能:   滤波 (平均值滤波，让波形更平滑一些)
    本函数调用的函数清单: 无
    调用本函数的函数清单: Demodulation
    输入参数:  *InDataBuf  从该地址开始滤
    			lenth      滤这么长
    输出参数:   
    函数返回值说明: 无
    使用的资源 
******************************************/
void SmoothingWave(short *InDataBuf,unsigned long lenth)
{
    DebugAudioLog(@"");
	
	unsigned long i = 0;//指向第i个点
	unsigned long NumberOfLow = 0;//小幅度波的个数
	for(;i<lenth;)
	{   
		NumberOfLow = 0;
		while((InDataBuf[i] < 500)&&(InDataBuf[i] > -500)) //去除 连续 3点小于500的点
		{
			i++;
			NumberOfLow++;
			if(i == lenth)
			{
				return;
			}
		}
		if(NumberOfLow < 3)//对于中间出现的小幅度波小于3，要退回去
		{
			i -= NumberOfLow;
		}
		//InDataBuf[i] = (InDataBuf[i - 2] + InDataBuf[i - 1]*2 + InDataBuf[i]*4 + InDataBuf[i + 1]*2 + InDataBuf[i + 2])/10;
        if(i > 0)
        {
            InDataBuf[i] = (InDataBuf[i - 1] + InDataBuf[i] + InDataBuf[i + 1])/4;
        }
		i++;		
	}
}
/*****************************************
    功能:   去扰  (去除波形中过小的干扰，实质也是滤波)
    本函数调用的函数清单: 无
    调用本函数的函数清单: Demodulation
    输入参数:  *InDataBuf    从该地址开始   
    			lenth  		 长度	
    			MobileType	 以该类型来去扰
    输出参数:   
    函数返回值说明: 无
    使用的资源 
******************************************/
void DisInterference(short *InDataBuf,unsigned long lenth,unsigned char MobileType)
{
    DebugAudioLog(@"");
	
	unsigned long i = 0;//指向第i个点
	unsigned long j = 0;//用于超小波宽度中采样值取反
	unsigned long NumberOfLow = 0;//小幅度波的个数
	float LengthOfZorePassage = 0;//过零点之间宽度
	float LastRatio = 0;///过零点上一次的比率
	float	RatioOfZorePassage = 0;//过零点这一次的比率


	unsigned long datastart = 0;//当前在解的波的开始点

	for(;i<lenth;)
	{   
		NumberOfLow = 0;
		while((InDataBuf[i] < 500)&&(InDataBuf[i] > -500)) //去除 连续 3点小于500的点
		{
			i++;
			NumberOfLow++;
			if(i == lenth)
			{
				return;
			}
		}
		if(NumberOfLow < 3)//对于中间出现的小幅度波小于3，要退回去
		{
			i -= NumberOfLow;
		}
		
		datastart = i;//当前波的开始点
		LastRatio = RatioOfZorePassage;//保存上一次的过零点比率
		if(InDataBuf[i] >= 0)//如果采样值大于等于0
		{
			while(InDataBuf[i] >= 0)//直到采样值小于0
			{
				i++;//下一个采样点	
			}
		}
		else//如果采样值小于0
		{
			while(InDataBuf[i] < 0)//直到采样值大于?
			{
				i++;//下一个采样点				
			}
		}
		RatioOfZorePassage = (float(abs(InDataBuf[i]))) 
							/ ( float(abs(InDataBuf[i - 1])) + float(abs(InDataBuf[i])) );

		//记下当前波过零点之间的宽度	
	    LengthOfZorePassage =LastRatio  + (i - datastart - 1) + (1 - RatioOfZorePassage);
		if(LengthOfZorePassage <  ((float)MobileType+1.0)/3.0) //如果是超小波，认为是干扰		
		{
			for(j = datastart;j < i;j++)
				{
					InDataBuf[j] = 0 - InDataBuf[j];
				}			
		}		
		
	}

}

/*****************************************
    功能:  解调 从InDataBuf开始Lenth 这么长的数据 里，用MobileType方式，解调出数据，存在OutDataBuf里
    	   反回时，解到哪个点放在OutLenIndix里
    本函数调用的函数清单: 无
    调用本函数的函数清单: main
    输入参数:  *InDataBuf    采样值地址
    		 	lenth        总长度
    		 	MmobileType  手机类型
    		 	TestCommunication   是否是在测试通信  1:正在测试通信  0:正常通信
    输出参数:  *OutDataBuf   数据保存的地方
    		   *OutLenIndix  解到哪里

    函数返回值说明:    0:出错，1:没有滤波  2:需要滤波
    使用的资源 
******************************************/
unsigned char   Demodulation(unsigned char *OutDataBuf, short *InDataBuf,unsigned long lenth,
									unsigned long *OutLenIndix,unsigned char MobileType,unsigned char TestCommunication)
{
    DebugAudioLog(@"");
	
	unsigned char LoopForSmooth = 0;// 0 是第一次，1是第二次
	unsigned char DemodulationResult = 0;// 找同步头和解调的结果，1为成成，0为失败
	
	for(LoopForSmooth = 0;LoopForSmooth < 2; LoopForSmooth++ )
	{
		if(LoopForSmooth == 1)//两次循环，先不滤波，解不出来再滤波。
		{
			memcpy(InDataBuf,(char*)InDataBuf+lenth*2,lenth*2);
			SmoothingWave(InDataBuf,lenth);
		}
 		DisInterference(InDataBuf,lenth,MobileType);//去扰
		DemodulationResult = FindHead(InDataBuf,lenth,OutLenIndix,MobileType);//找同步头
		if( DemodulationResult == 1)//如果找到了，则解
		{
			DemodulationResult = GetAllData(OutDataBuf,InDataBuf,lenth,OutLenIndix,MobileType,TestCommunication);//解调
            
//			DemodulationResult = GetAllDataTest(OutDataBuf,InDataBuf,lenth,OutLenIndix,MobileType);//解调
		}
		
		if(LoopForSmooth == 0)
		{
			if(DemodulationResult == 1)//continue;//第一次解不出来，滤波后再解
			{
                return 1;//第一次就解出来了，说明是没有滤波就解出来了
			}
		}
		else if(LoopForSmooth == 1)
		{
			if(DemodulationResult == 0)
			{
				return 0;//第二次还解不出来，出错了
			}
			else
			{
                return 2;//第二次才解出来，说明需要滤波
			}
		}

	}
 	return 0;//出错了
}
    
    
#pragma mark - 一盒宝的音频驱动
    
    
//#define FS				44100
#define MODULATE_FREQUENCY	5512.5
#define MODULATE_SAMPLE  (int)(FS / MODULATE_FREQUENCY)
    
#define AMP_U			1024 * 24
#define AMP_D			-1024*24
#define BYTE_LEN		8
    
//    ++++++++++++++++++一盒宝的音频驱动++++++++++++++
    bool m_bIobitFlag = false;
    int ModulateBit(int type,short* retData)
    {
        int index = 0;
        switch(type)
        {
            case 1: // »Áπ˚µ±«∞±»Ãÿ «1£¨‘ÚÃÌº”1 1µƒ≤®–Œ «”–±‰ªØ
                for(int i = 0; i < MODULATE_SAMPLE/2; i++)
                {
                    *(retData + index++) = ((m_bIobitFlag == true) ?AMP_U:AMP_D);
                }
                m_bIobitFlag = !m_bIobitFlag;
                for(int i = 0; i < MODULATE_SAMPLE/2; i++)
                {
                    *(retData + index++) = ((m_bIobitFlag == true) ?AMP_U:AMP_D);
                }
                m_bIobitFlag = !m_bIobitFlag;
                break;
            case 0: // »Áπ˚ «0£¨‘ÚÃÌº”0,0µƒ≤®–Œ «√ª”–±‰ªØ
                for(int i = 0; i <  MODULATE_SAMPLE; i ++)
                {
                    *(retData + index++) = ((m_bIobitFlag == true) ?AMP_U:AMP_D);
                }
                m_bIobitFlag = !m_bIobitFlag;
                break;
        }
        return index;
    }
    
    int ModulateByte(BYTE byte,short* retData)
    {
        int offset = 0;
        for(int i = 0; i < BYTE_LEN; i ++)
        {
            if((byte << i) & 0x80)
            {
                offset += ModulateBit(1,retData + offset);
            }
            else
            {
                offset += ModulateBit(0,retData + offset);
            }
        }
        
        return offset;
    }
    
    VOID * Modulate(BYTE* data,int len,int
                               * outFrameLen)
    {
        int packageLen = 0;
//        BYTE* packBuf = this->PackField(data,len,&packageLen);
        BYTE* packBuf = data;
        
        // ø™ ºµ˜÷∆
        short* voiceData = NULL;
        int offset = 0;
        int voiceLen = packageLen *  MODULATE_SAMPLE * BYTE_LEN;
        voiceData = new short[voiceLen];
        
        for(int i = 0; i < packageLen; i ++)
        {
            offset += ModulateByte(packBuf[i],voiceData+offset);
        }
        free(packBuf);
        packBuf = NULL;
        *outFrameLen = offset;
        return voiceData;
    }
    

#ifdef __cplusplus
}
#endif

