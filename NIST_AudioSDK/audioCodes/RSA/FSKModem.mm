/************************************************************************/
/*
 FSKModem.cpp
 xiaotanyu13
 2012/11/12
 xiaot.yu@sunyard.com
 
 封装了FSK调制解调的函数，采用类的方法来实现*/
/************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "FSKModem.h"
#include "stdio.h"
#include "MobileShield.h"

#include "fftsg_h.h"


#define def_MaxValidAudio  1024*8*6*10

unsigned int YH_OutDataLenth = 0;
#ifdef  __cplusplus
extern "C" {
#endif

    void YH_DecimalToBinary(int num, int *outDec);
    LPSTR YH_errorMessageData(INT status);

#define AMP_U			1024 * 24			// 幅度 +
#define AMP_D			-1024*24		// 幅度 -
#define BYTE_LEN		8				// 每个字节的比特数
#define E_POINTS		128
#define E_SOUND_THRESHOLD	(1000*E_POINTS)
#define E_SILENCE_THRESHOD	(800*E_POINTS)
#define MAX_N_POINTS		(512*1024)  /* 2**14 */


bool YH_m_bIobitFlag = false;			// if true >0 else <0 ,”√¿¥±Íº«√ø∏ˆ≤…—˘µ„µƒ’˝∏∫
//char m_cPackageCount;		// ∞¸º∆ ˝∆˜£¨√ø¥Œ∑¢ÀÕ∂ºª·++
float *m_fPoint = (float*)malloc(2 * MAX_N_POINTS * sizeof(float));//滤波的时候保存数据
int m_nFrequency = 1;
    
int YH_SendType = USER_SEND_COMMAND;


unsigned char YH_OutData[1030]={0};

INT YH_DemoduleAudioData( VOID * data, INT len ,unsigned char *tempbuf)
{
    DebugAudioLog(@"YH_DemoduleAudioData");
    
	int status  = 0;
    int iValidLen;
    int ret = 0;
    
    YH_SetFrequency(SYNC_FALG);
    
//    int MaxValidAudioLength = 1024*8/2*((44100/2200)*2);
    
    int MaxValidAudioLength = def_MaxValidAudio;
    int TempBufLength = MaxValidAudioLength*2;
    
    char *m_RecordBuf = (char*)malloc(TempBufLength);
    unsigned int OutLenIndix = 0;
    
//    NSLog(@"data lenght = %d", [[NSString stringWithUTF8String:(char *)data] length]);
    
    iValidLen= YH_GetValidData((short *)data, (short *)m_RecordBuf, len);
    if (iValidLen>=320*((YH_GetFrequency()+1)/2))
    {
        ret= YH_Demodulate(YH_OutData, (short *)m_RecordBuf, (unsigned long)iValidLen, &OutLenIndix, YH_GetFrequency());
        if (ret>0)
        {
//            memcpy( tempbuf,((char*)tempbuf+MaxValidAudioLength),MaxValidAudioLength);
            status = 1;
        }
    }
    free(m_RecordBuf);
    m_RecordBuf = nil;
    return status;

//    int ret = 0;
//    unsigned long OutLenIndix = 0 ;
//    unsigned char MobileType = 1;
//    memcpy( ((char*)tempbuf+2*1024*1024),tempbuf,2*1024*1024);
//    ret = YH_Demodulate(( unsigned char * )OutData, (SHORT *)data, len/2, &OutLenIndix, MobileType);
//    if(ret == 0)
//    {
//        memcpy( tempbuf,((char*)tempbuf+2*1024*1024),2*1024*1024);
//    }
//
//    if(ret==1)
//    {
//        return 1;
//    }
//    return 0;
}

VOID * YH_BuildFSKDataFrame( CHAR * data, INT len, INT * frame_len )
{
    
//    printf("YH_BuildFSKDataFrame\n\n");
//    for(int i=0; i<len; i++)
//    {
//        printf("%02x ",data[i]);
//    }
//    printf("\n\n");
    //        int        * s      = NULL;
    //        //char *cmd=NULL;
    //        INT            n      = 0;
    //        int totallen=(len)*128+9216;
    //
    //        s = ( int * )calloc(totallen , 1);
    //        memset((char*)s,0,totallen);
    ////        n = FSKModule(data,len,s+4096);
    //        *frame_len=n*2+9216;
    //
    //        return s;
    return YH_Modulate((BYTE *)data, len, frame_len);
}

/*
 
 
 输入参数：
 
 type:	类型有0 和 1
 0表示 0的波
 1表示 1的波
 输出参数：
 retData:	保存buffer的指针
 返回值：
 对retData所作的偏移值
 */
int YH_ModulateBit(int type,short* retData)
{
	int index = 0;
	switch(type)
	{
        case 1: // 如果当前比特是1，则添加1 1的波形是有变化
            for(int i = 0; i < MODULATE_SAMPLE/2; i++)
            {
                *(retData + index++) = ((YH_m_bIobitFlag == true) ?AMP_U:AMP_D);
            }
            YH_m_bIobitFlag = !YH_m_bIobitFlag;
            for(int i = 0; i < MODULATE_SAMPLE/2; i++)
            {
                *(retData + index++) = ((YH_m_bIobitFlag == true) ?AMP_U:AMP_D);
            }
            YH_m_bIobitFlag = !YH_m_bIobitFlag;
            break;
        case 0: // 如果是0，则添加0,0的波形是没有变化
            for(int i = 0; i <  MODULATE_SAMPLE; i ++)
            {
                *(retData + index++) = ((YH_m_bIobitFlag == true) ?AMP_U:AMP_D);
            }
            YH_m_bIobitFlag = !YH_m_bIobitFlag;
            break;
	}
	return index;
}
/*
 调制一个字节的数据,一个字节之后还需要加两个0
 输入参数：
 byte：	需要调制的字节
 输出参数：
 retData：保存调制后的数据数组
 返回值：
 对retData所作的偏移
 */
int YH_ModulateByte(BYTE byte,short* retData)
{
	int offset = 0;
	for(int i = 0; i < BYTE_LEN; i ++)
	{
		if((byte << i) & 0x80)
		{
			offset += YH_ModulateBit(1,retData + offset);
		}
		else
		{
			offset += YH_ModulateBit(0,retData + offset);
		}
	}
    
	return offset;
}
/*
 组同步域，固定为0x01015555
 输入参数：
 
 输出参数：
 data：保存调制后的数据数组
 返回值：
 对data所作的偏移
 */
int YH_PackSYNC(BYTE* data)
{
	int offset = 0;
	data[offset++] = 0xff;
	data[offset++] = 0xff;
	data[offset++] = 0xff;
	data[offset++] = 0xff;
	data[offset++] = 0xff;
	data[offset++] = 0xff;
	data[offset++] = 0x55;
	data[offset++] = 0x55;
	data[offset++] = 0x01;
	data[offset++] = 0x01;
	return offset;
}
/*
 组计数域，1个字节
 输入参数：
 
 输出参数：
 data：保存调制后的数据数组
 返回值：
 对data所作的偏移
 */
int YH_PackLevel(BYTE* data)
{
	//m_cPackageCount ++;
	//m_cPackageCount = m_cPackageCount % 256;
	int offset = 0;
	data[offset++] = (BYTE)m_nFrequency;
	return offset;
    
}
/*
 组数据长度域，2字节
 输入参数：
 len：	数据的长度
 输出参数：
 data：保存调制后的数据数组
 返回值：
 对data所作的偏移
 */
int YH_PackLength(int len,BYTE* data)
{
	int offset = 0;
	data[offset++] = len % 256;
	data[offset++] = len / 256;
	return offset;
}
/*
 组数据域
 输入参数：
 dataIn：需要调制的数据
 len：	数据的长度
 输出参数：
 data：保存调制后的数据数组
 返回值：
 对data所作的偏移
 */
int YH_PackData(BYTE* dataIn,int len,BYTE* data)
{
	memcpy(data,dataIn,len);
	return len;
}
/*
 组校验域
 输入参数：
 crc：	校验值
 输出参数：
 data：保存调制后的数据数组
 返回值：
 对data所作的偏移
 */
int YH_PackCRC(unsigned short crc,BYTE* data)
{
	int offset = 0;
	data[offset++] = crc % 256;
	data[offset++] = crc / 256;
	return offset;
}

int YH_PackEnd(BYTE* data)
{
	int offset = 0;
	data[offset++] = 0x00;
	return offset;
}
/*
 组包，包格式：
 同步域	包计数域	数据长度域	数据域	校验域
 4字节	1字节		2字节		n字节	2字节
 输入参数：
 data:	上层传递下来的数据
 len:	数据的长度
 输出参数：
 outLen：返回值的长度
 返回值：
 按照以上格式组好的包
 */
BYTE* YH_PackField(BYTE* data,int len,int *outLen)
{
	int bufLen = len + 30;
	BYTE *buf = NULL;
	int offset = 0;
	int syncLen = 0;
	buf = new BYTE[bufLen];
	syncLen = YH_PackSYNC(buf + offset);
	offset += syncLen;
	offset += YH_PackLevel(buf + offset);
	offset += YH_PackLength(len,buf+offset);
	offset += YH_PackData(data,len,buf+offset);
	// crc校验需要把计数器域开始到数据域结束的数据添加计算
	unsigned short crc = YH_CalculateCRC(buf+syncLen,offset - syncLen);
	offset += YH_PackCRC(crc,buf+offset);
	offset += YH_PackEnd(buf + offset);// 看看是否添加了结束域会提高crc的校验
	*outLen = offset;
	return buf;
}

/*
 对数据进行crc校验，并且返回crc校验值
 输入参数：
 buf：	需要计算crc的数据
 len：	数据的长度
 输出参数：
 
 返回值：
 crc校验结果
 */
unsigned short YH_CalculateCRC(unsigned char *buf,unsigned short len)
{
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

/*
 调制数据
 输入参数：
 data：	从应用层传下来的命令
 len：	data的长度
 输出参数：
 outFrameLen：	调制成音频数据的长度
 返回值：
 调制成的音频数据,这个返回值需要用户自己去销毁
 */
short* YH_Modulate(BYTE* data,int len,int* outFrameLen)
{
//	int packageLen = len;
////	BYTE* packBuf = YH_PackField(data,len,&packageLen);
//    
//	BYTE* packBuf = data;
//	// 开始调制
//	short* voiceData = NULL;
//	int offset = 0;
//	int voiceLen = packageLen *  MODULATE_SAMPLE * BYTE_LEN;
//	voiceData = new short[voiceLen];
//    
//	for(int i = 0; i < packageLen; i ++)
//	{
//		offset += YH_ModulateByte(packBuf[i],voiceData+offset);
//	}
//	free(packBuf);
//	*outFrameLen = offset;
//	return voiceData;
    int packageLen = len;

//    BYTE* packBuf = PackField(data,len,&packageLen);
    BYTE* packBuf = data;
//    printf("YH_Modulate\n\n");
//    for(int i=0; i<packageLen; i++)
//    {
//        printf("%02x ",packBuf[i]);
//    }
//    printf("\n\n");
    // 开始调制
    short* voiceData = NULL;
    int offset = 0;
    int voiceLen = packageLen *  MODULATE_SAMPLE * BYTE_LEN;
//        int voiceLen=(len)*128+9216;
    voiceData = new short[voiceLen];

    for(int i = 0; i < packageLen; i ++)
    {
        offset += YH_ModulateByte(packBuf[i],voiceData+offset);
    }
    free(packBuf);
    packBuf = NULL;
    *outFrameLen = offset;

//    printf("\n一盒宝调制数据: 长度 %d\n",*outFrameLen);
//    for(int i=0; i< *outFrameLen; i++)
//    {
//        if(voiceData[i]>0)
//        {
//            printf("+%d,",voiceData[i]);
//        }
//        else
//        {
//            printf("%d,",voiceData[i]);
//        }
//        if((i+1)%4 == 0)
//        {
//            printf("  ");
//        }
//        if((i+1)%8 == 0)
//        {
//            printf("\n");
//        }
//        if((i+1)%64 == 0)
//        {
//            printf("\n");
//        }
//    }
//    printf("\n\n");
    return voiceData;
}

void YH_FindFrame(short *pData, unsigned long len, long *start, long *end)
{
	unsigned long i, j;
	unsigned long E;
	BYTE flag = 0;
    
	*start = *end = -1;
	if(len < 128)
		return;
	for(i = 0; i <= len - E_POINTS; i += E_POINTS) {
		E = 0;
		for(j = 0; j < E_POINTS; j ++) {
			E += abs(pData[i+j]);
		}
		if(!flag) { // find start pos of sound
			if(E > E_SOUND_THRESHOLD) {
				if(i >= E_POINTS)
					*start = i - E_POINTS;
				else
					*start = i;
				flag = 1;
			}
		}
		else {
			if(E < E_SILENCE_THRESHOD) {
				*end = i + E_POINTS;
				//*end = i;
				return;
			}
		}
	}
	// start pos found
	if(flag)
		*end = len -1;
}
unsigned long YH_GetN(unsigned long len)
{
	unsigned long N;
    
	if(len <= 64) {
		N = 64;
	}
	else if(len <= 128) {
		N = 128;
	}
	else if(len <= 512) {
		N = 512;
	}
	else if(len <= 1204) {
		N = 1024;
	}
	else if(len <= 2048) {
		N = 2048;
	}
	else if(len <= 4096) {
		N = 4096;
	}
	else if(len <= 8192) {
		N = 8192;
	}
	else if(len <= 16384) {
		N = 16384;
	}
	else if(len <= 32768) {
		N = 32768;
	}
	else if(len <= 64*1024) {
		N = 64*1024;
	}
	else if(len <= 128*1024) {
		N = 128*1024;
	}
	else if(len <= 256*1024) {
		N = 256*1024;
	}
	else if(len <= 512*1024) {
		N = 512*1024;
	}
	else {
		return 0;
	}
    
	return N;
}

/*
 判断数据是否是有效数据
 输入参数：
 InDataBuf：	从音频口接收的数据
 输出参数：
 OutDataBuf:	判断出的有效数据
 lenth:		接收数据的长度
 返回结果：
 有效数据的长度
 */
int YH_GetValidData(short *InDataBuf,short *OutDataBuf, unsigned long lenth)
{
	unsigned long i = 0;//指向第i个点
	unsigned long NumberOfLow = 0;//小幅度波的个数
	unsigned long k = 0;//指向第K个有效数据
	int Lenthofdata = 0;
	int isEnd = 0;
    
	if(InDataBuf[lenth-1]>1500 || InDataBuf[lenth-1]<-1500)
	{
		isEnd++;
	}
	if(InDataBuf[lenth-2]>1500 || InDataBuf[lenth-2]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-3]>1500 || InDataBuf[lenth-3]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-4]>1500 || InDataBuf[lenth-4]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-5]>1500 || InDataBuf[lenth-5]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-6]>1500 || InDataBuf[lenth-6]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-7]>1500 || InDataBuf[lenth-7]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-8]>1500 || InDataBuf[lenth-8]<-1500){
		isEnd++;
	}
	if(InDataBuf[lenth-9]>1500 || InDataBuf[lenth-9]<-1500) {
		isEnd++;
	}
	if(InDataBuf[lenth-10]>1500 || InDataBuf[lenth-10]<-1500) {
		isEnd++;
	}
	if(isEnd >6)
	{
		return -1;
	}
    
	for(i=0;i<lenth;i++)
	{
		NumberOfLow = 0;
		while((InDataBuf[i] < 500)&&(InDataBuf[i] > -500)) //去除 连续 3点小于500的点
		{
			i++;
			NumberOfLow++;
			if(i == lenth)
			{
				goto endLow;
			}
		}
		if(NumberOfLow < 3)//对于中间出现的小幅度波小于3，要退回去
		{
			i -= NumberOfLow;
		}
		OutDataBuf[Lenthofdata] = InDataBuf[i];
		Lenthofdata++;
        
	}
endLow:
	//去除干扰，连续超过20个大于或者小于0 的, 把多余的去掉
    if(OutDataBuf == NULL)
    {
        return -1;
    }
	short currentData = OutDataBuf[0];
	int tempLenth = Lenthofdata;
	int j = 1;
    
	for(i=0; i<tempLenth; i++)
	{
		if((currentData <0 && OutDataBuf[i] <=0) ||(currentData >0 && OutDataBuf[i] >=0) )
		{
			j++;
		}
		else
		{
			currentData = OutDataBuf[i];
			if(j>40)
			{
				memcpy(&OutDataBuf[i]-(j-20),OutDataBuf+(i-20),(tempLenth-(i-20))*2);
				i = i - (j-20);
				tempLenth = tempLenth - (j-40);
			}
			j = 1;
		}
	}
	if(j>40)
	{
		memcpy(&OutDataBuf[i]-(j-20),OutDataBuf+(i-20),(tempLenth-(i-20))*2);
		i = i - (j-20);
		tempLenth = tempLenth - (j-40);
	}
	j = 1;
    
	return tempLenth;
}

/*****************************************
 功能:找到同步头  55550101 或 EFEF0101
 本函数调用的函数清单: 无
 调用本函数的函数清单: main
 输入参数:  *DataBuf
 输出参数:  第几个点开始是数据
 函数返回值说明:
 使用的资源
 ******************************************/
BYTE YH_FindHead(short * InDataBuf,unsigned long lenth,unsigned int *endlen,BYTE MobileType)
{
	unsigned long i = 0;//指向第i个点
    
	float LengthOfZorePassage = 0;//过零点之间宽度
	float LastRatio = 0;///过零点上一次的比率
	float	RatioOfZorePassage = 0;//过零点这一次的比率
    
	unsigned long NumberOfLow = 0;//小幅度波的个数
	unsigned long DataHead = 0;//同步头
	unsigned long datastart = 0;//当前在解的波的开始点
	BYTE bit0flag = 0;//用于实现两个小波表示1
    
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
			while(InDataBuf[i] >= 0&& i < lenth)//直到采样值小于0
			{
				i++;//下一个采样点
			}
		}
		else//如果采样值小于0
		{
			while(InDataBuf[i] < 0&& i < lenth)//直到采样值大于?
			{
				i++;//下一个采样点
			}
		}
		RatioOfZorePassage = (float(abs(InDataBuf[i])))
        / ( float(abs(InDataBuf[i - 1])) + float(abs(InDataBuf[i])) );
        
		//记下当前波过零点之间的宽度
		LengthOfZorePassage =LastRatio  + (i - datastart - 1) + (1 - RatioOfZorePassage);
		if(( LengthOfZorePassage >=  (3.0/ 2.0)*((float) MobileType+1.0) )
           &&(LengthOfZorePassage<(12.0/ 3.0)*((float) MobileType+1.0))) //如果是大波
            
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
		else if((LengthOfZorePassage>= (1.0/3.0)*((float) MobileType+1.0))
                &&(LengthOfZorePassage< (3.0/2.0)*((float) MobileType+1.0))&&(i != *endlen)) //如果是小波
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
        
        //		if(( DataHead == 0x55550101 )||( DataHead == 0xEFEF0101 ))//这里需要注意，发上去和发下来的同步头是不同的
        if( DataHead == 0xEFEF0101 )//这里需要注意，发上去和发下来的同步头是不同的
		{
			*endlen = i;
			return 1;//从i点开始，都是数 据了
		}
	}
	return 0;
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
 函数返回值说明:    0为出错，1为成功解出8位数据-1为crc校验错误
 使用的资源
 ******************************************/
BYTE YH_GetAllData(BYTE *OutDataBuf, short *InDataBuf,
                           unsigned long lenth,unsigned int *endlen,BYTE MobileType)
{
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
			OutDataBuf[j]  &= ~(1<<(7-bitindex));
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
        /*
		if((j == 1) && (bitindex == 0))// 一开始1个字节是计数器
			j =1;//////这个域就不需要了。。。。。。
		if((j == 3)&&(bitindex == 0))// 接下来两个字节是数据长度
		{
			DataLenth =  OutDataBuf[1] | (OutDataBuf[2] << 8);
            
		}
		if(( j == DataLenth + 3 + 2) && (j >= 3))//全部解出来了
		{
			//-*************************************************************************CRC16**-/
			DataLenth =  OutDataBuf[0] | (OutDataBuf[1] << 8);
            printf("OutDataBuf:\n\n");
            for(int i=0; i<DataLenth+4; i++)
            {
                printf("%02x ",OutDataBuf[i]);
            }
            printf("\n\n");
            
			crc = OutDataBuf[DataLenth + 3] + (OutDataBuf[DataLenth + 4] << 8);
			if(crc != YH_CalculateCRC(OutDataBuf,DataLenth + 3))//如果校验通不过
			{
                //				LOGE("crc is wrong ");
                
				*endlen = i;
				return -1;//校验出错
			}
			//-***********************************************************************************-/
            
            
			*endlen = i;
			return 1;
		}
        // */
        
    
        if(( j == 2)&&(bitindex == 0))//一开始两个字节是数据长度
		{
			DataLenth =  OutDataBuf[0] | (OutDataBuf[1] << 8);
            YH_OutDataLenth = DataLenth;
		}
        //+++++++++by zhangjian 20141013 02:30
        if([CMobileShield get6100ApitType] == CMD_READSTATUS)
        {
            if(j == 6)
            {
                unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                memcpy(result, OutDataBuf+4, 2);
//                NSLog(@"%02x, %02x",result[0],result[1]);
                if (result[0] == 0x77 && result[1] == 0x77)
                {
                    [CMobileShield newSetBufferSize:1024*8*2*10];
                }
            }
        }
		//if(( j == 4)&&(bitindex == 0))
		if(( j == DataLenth + 2) && (j >= 2))//全部解出来了
		{
            printf("\nYH_GetAllData\n\n");
            for(int i=0; i<DataLenth+2; i++)
            {
                printf("%02x ",OutDataBuf[i]);
                if(((i-2)+1)%4 == 0)
                {
                    printf(" ");
                }
            }
            printf("\n\n");
            //-*************************************************************************CRC16**-/
			crc = OutDataBuf[DataLenth] | (OutDataBuf[DataLenth + 1] << 8);
			if(crc != YH_CalculateCRC(OutDataBuf,DataLenth))//如果校验通不过
			{
                NSLog(@"校验 出错");
				*endlen = i;
				return 0;//校验出错
			}
            //-***********************************************************************************-/
            
            YH_OutDataLenth = DataLenth;
            NSLog(@"校验 通过");
			*endlen = i;
			return 1;
		}
	}
	*endlen = i;
	return 0;//没有数据
}

/*****************************************
 功能:   滤波 (平均值滤波，让波形更平滑一些)
 本函数调用的函数清单: 无
 调用本函数的函数清单: Demodulate
 输入参数:  *InDataBuf  从该地址开始滤
 length      滤这么长
 LowF       截取低频
 HighF      截取高频
 SampleRate 采样率
 输出参数:
 函数返回值说明: 无
 使用的资源
 ******************************************/
/**/
#if 1
void YH_SmoothingWave(short *InDataBuf,unsigned long length,
							  unsigned long LowF, unsigned long HighF, unsigned long SampleRate)
{
	unsigned long i, j, k, N;
	long start, end;
	unsigned long l, h;
    
    
#if 0
	for(i = 0; i < length;) {
		FindFrame(InDataBuf + i, length - i, &start, &end);
		if(start >= 0) {
			if(end == -1)
				end = length - i - 1;
			N = YH_GetN(end - start + 512); // 前后各至少填充256点,每点值为0
			memset(m_fPoint, 0, 2 * N * sizeof(float));
			for (j = 256; j < N; j ++)	{
				m_fPoint[2*j] = InDataBuf[i+start+j-256];
			}
			/* Calculate FFT. */
			cdft(N*2, -1, m_fPoint);
			/* Filter */
			l = (unsigned long)(LowF/((float)SampleRate/N));
			h = (unsigned long)(HighF/((float)SampleRate/N));
			for(k = 0; k < l; k ++) {
				m_fPoint[2*k] = m_fPoint[2*k+1] = 0;
			}
			for(k = h; k < N; k ++) {
				m_fPoint[2*k] =  m_fPoint[2*k+1] = 0;
			}
            
			/* Clear time-domain samples and calculate IFFT. */
			memset(InDataBuf+i+start, 0, (end-start)*2);
			icdft(N*2, -1, m_fPoint);
			for(k = 0; k < end-start; k ++) {
				InDataBuf[i+start+k] = (short)m_fPoint[2*k+256];
			}
			i += end;
		}
		else
			break;
	}
#else
	for(i = 0; i < length;) {
		YH_FindFrame(InDataBuf + i, length - i, &start, &end);
		if(start >= 0) {
			if(end == -1)
				end = length - i - 1;
			N = YH_GetN(end - start + 512); // 前后各至少填充256点,每点值为0
			memset(m_fPoint, 0, 2 * N * sizeof(float));
			for (j = 256; j < end - start + 256; j ++)	{
				m_fPoint[j] = InDataBuf[i+start+j-256];
			}
			/* Calculate FFT. */
			rdft(N, 1, m_fPoint);
			/* Filter */
			l = (unsigned long)(LowF/((float)SampleRate/N));
			h = (unsigned long)(HighF/((float)SampleRate/N));
			for(k = 0; k < l; k ++) {
				m_fPoint[2*k] = m_fPoint[2*k+1] = 0;
			}
			for(k = h; k < N; k ++) {
				m_fPoint[2*k] =  m_fPoint[2*k+1] = 0;
			}
            
			/* Clear time-domain samples and calculate IFFT. */
			memset(InDataBuf+i+start, 0, (end-start)*2);
            
			rdft(N, -1, m_fPoint);
			for (j = 0; j <= N - 1; j++) {
				//m_fPoint[j] *= 2.0/ N;
				m_fPoint[j] /= N;
			}
            
			for(k = 0; k < end-start; k ++) {
				InDataBuf[i+start+k] = (short)m_fPoint[k+256];
			}
            
			i += end;
		}
		else
			break;
	}
    
#endif
}
#endif

#if 0
void YH_SmoothingWave(short *InDataBuf,unsigned long lenth)
{
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
		InDataBuf[i] = (InDataBuf[i - 1] + InDataBuf[i] + InDataBuf[i + 1])/3;
		i++;
	}
}
#endif
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
void YH_DisInterference(short *InDataBuf,unsigned long lenth,BYTE MobileType)
{
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
		while((InDataBuf[i] < 500)&&(InDataBuf[i] > -500) && i < lenth) //去除 连续 3点小于500的点
		{
			i++;
			NumberOfLow++;
		}
		if(NumberOfLow < 3)//对于中间出现的小幅度波小于3，要退回去
		{
			i -= NumberOfLow;
		}
        
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
			while(InDataBuf[i] < 0 && i < lenth)//直到采样值大于?
			{
				i++;//下一个采样点
			}
		}
		RatioOfZorePassage = ((float)(abs(InDataBuf[i]))) / (( float)(abs(InDataBuf[i - 1])) + (float)(abs(InDataBuf[i])) );
        
		//记下当前波过零点之间的宽度
		LengthOfZorePassage =LastRatio  + (i - datastart - 1) + (1 - RatioOfZorePassage);
		if(LengthOfZorePassage <  (((float)(MobileType+1.0))/3.0)) //如果是超小波，认为是干扰
		{
			for(j = datastart;j < i;j++)
			{
				InDataBuf[j] = 0 - InDataBuf[j];
			}
		}
        
	}
}

/*****************************************
 功能:  解调 从InDataBuf开始Lenth 这么长的数据 里，用MobileType方式，解调出数据，保存在OutDataBuf里
 反回时，解到哪个点放在OutLenIndix里，校验会在里面处理好
 本函数调用的函数清单: 无
 调用本函数的函数清单: main
 输入参数:  *InDataBuf    采样值地址
 lenth        总长度
 MmobileType  手机类型
 输出参数:  *OutDataBuf   数据保存的地方
 *OutLenIndix  解到哪里
 
 函数返回值说明:    0:出错，1:没有滤波  2:需要滤波
 使用的资源
 ******************************************/
int    YH_Demodulate(BYTE *OutDataBuf, short *InDataBuf,
                             unsigned long lenth,unsigned int *OutLenIndix,BYTE MobileType)
{
	BYTE LoopForSmooth = 0;// 0 是第一次，1是第二次
	BYTE DemodulationResult = 0;// 找同步头和解调的结果，1为成功，0为失败
    
	for(LoopForSmooth = 0;LoopForSmooth <3 ; LoopForSmooth++ )
	{
		if(LoopForSmooth != 0)//两次循环，先不滤波，解不出来再滤波。
		{
			unsigned long lLowF = 0;
			unsigned long lHighF = 0;
			lLowF = (unsigned long)((float)(2000*2/(MobileType+1))*(float)(1.0/32.0 * (float)(MobileType+1)+15.0/16.0));
			lHighF = (unsigned long)((float)(15000*2/(MobileType+1))*(float)(1.0/16.0 * (float)(MobileType+1)+7.0/8.0));
            
			memcpy(InDataBuf,(char*)InDataBuf+lenth*2,lenth*2);
			YH_SmoothingWave(InDataBuf,lenth, lLowF, lHighF, F_S);
			//	SmoothingWave(InDataBuf,lenth);
			*OutLenIndix = 0;
		}
        
		
		YH_DisInterference(InDataBuf,lenth,MobileType);//去扰
		DemodulationResult = YH_FindHead(InDataBuf,lenth,OutLenIndix,MobileType);//找同步头
		if( DemodulationResult == 1)//如果找到了，则解
		{
            NSLog(@"同步头找到了,开始解调");
			DemodulationResult = YH_GetAllData(OutDataBuf,InDataBuf,lenth,OutLenIndix,MobileType);//解调
		}
        
		if(LoopForSmooth == 0)
		{
			if(DemodulationResult == 1)//continue;//第一次解不出来，滤波后再解
			{
				return 1;//第一次就解出来了，说明是没有滤波就解出来了
			}
		}
		else //if(LoopForSmooth == 1)
		{
			if(DemodulationResult == 1)
			{
				return 2;//第二次还解不出来，出错了
			}
			else
			{
				return DemodulationResult ;//第二次才解出来，说明需要滤波
			}
		}
        
	}
	return 0;//出错了
}


void YH_SetFrequency(int frequency)
{
	m_nFrequency = frequency;
}

int YH_GetFrequency()
{
	return m_nFrequency;
}
    
VOID YH_SetSendType( INT type )
{
    DebugAudioLog(@"");
    
    YH_SendType = type;
}

INT YH_GetDataLenth()
{
    DebugAudioLog(@"");
    
    return YH_OutDataLenth;
}

INT YH_GetSendType()
{
    DebugAudioLog(@"");
    
    return YH_SendType;
}

void YH_GetAllReturnData(COS_DATA_YH * data)
{
    COS_DATA_YH * pData = data;
    SHORT nData  = 0;
    SHORT nData1 = 0;
    SHORT nData2 = 0;
    
    
    pData->Length = YH_OutDataLenth - 4;
    printf("pData->Length = %d\n", pData->Length);
    
    
    nData1 = YH_OutData[2];
    nData2 = YH_OutData[3];
    nData  = nData2 << 8 | nData1;
    pData->Status = nData;
    printf("pData->Status = %d\n", nData);
    printf("pData->Status = %02x\n", nData);
    pData->Type = YH_GetSendType();
    
    if( pData->Type == USER_SEND_COMMAND )
    {
        if (pData->Status == ( SHORT )0x9000 || pData->Status == ( SHORT )0x9999)
        {
            pData->Data = calloc( sizeof( CHAR ), pData->Length + 1 );
            memcpy( pData->Data , YH_OutData + 4, pData->Length );
        }
        else
        {
            LPSTR errormsg = YH_errorMessageData((INT)nData);
            
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
                memcpy( pData->Data , YH_OutData + 4, pData->Length );
                
                unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                memcpy(result, pData->Data, 2);
                if (result[0] == 0x77 && result[1] == 0x77)
                {
                    BYTE respCode[2];
                    memcpy(respCode, YH_OutData+10, 2);
                    YH_DecimalToBinary(respCode[0], pData->respCode[0]);
                    YH_DecimalToBinary(respCode[1], pData->respCode[1]);
                }
                free(result);
                result = nil;
            }
            else
            {
                LPSTR errormsg = YH_errorMessageData((INT)nData);
                
                pData->Data = calloc( sizeof( CHAR ), strlen(errormsg) + 1 );
                pData->Length = strlen(errormsg);
                memcpy( pData->Data , errormsg, strlen(errormsg) );
            }
        }
        else
        {
            BYTE respCode[2];
            if(pData->Status == 0x3333 || pData->Status == 0x6666)
            {
                respCode[0] = 0;
                respCode[1] = 0;
                YH_DecimalToBinary(respCode[0], pData->respCode[0]);
                YH_DecimalToBinary(respCode[1], pData->respCode[1]);
            }
            else
            {
                memcpy(respCode, YH_OutData+4, 2);
                YH_DecimalToBinary(respCode[0], pData->respCode[0]);
                YH_DecimalToBinary(respCode[1], pData->respCode[1]);
            }
            
            
            pData->Data = calloc( sizeof( CHAR ), pData->Length );
            if(pData->Length >= 2)
            {
                memcpy( pData->Data , YH_OutData + 6, pData->Length-2 );
            }
        }
    }
}
    
#pragma mark - error message
    
    void YH_DecimalToBinary(int num, int *outDec)
    {
        for(int i=7; i>=0; i--)
        {
            outDec[i] = (num >> (7-i)) & 0x1;
        }
    }
    
    LPSTR YH_errorMessageData(INT status)
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
    
#ifdef __cplusplus
}
#endif