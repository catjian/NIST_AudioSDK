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

#ifndef BYTE
typedef unsigned char BYTE;
#endif

#ifndef DWORD
typedef unsigned long DWORD;
#endif

#define FS				44100			// 采样率
// 发送的频率被固定死了，所以都使用宏来表示
#define MODULATE_FREQUENCY	5512.5		// 调制的频率
//#define MODULATE_FREQUENCY	4410		// 调制的频率
//#define MODULATE_FREQUENCY	2205
#define MODULATE_SAMPLE  (int)(FS / MODULATE_FREQUENCY)	// 调制时候的周期点数

class CFSKModem
{
private:
	// 调制
	bool m_bIobitFlag;			// if true >0 else <0 ,用来标记每个采样点的正负
	//char m_cPackageCount;		// 包计数器，每次发送都会++
	float *m_fPoint;           /* pointer to time-domain samples */
	int m_nFrequency;		//通讯频率  在解调的时候使用到

protected:
	int ModulateByte(BYTE byte,short* retData);				// 添加一个字节
	int ModulateBit(int type,short* retData);				// 将一个比特的数据调制成音频数据

	BYTE* PackField(BYTE* data,int len,int *outLen);		// 组报文
	int PackSYNC(BYTE* data);								// 添加同步域
	int PackLevel(BYTE* data);								// 添加计数域
	int PackLength(int len,BYTE* data);						// 添加长度域
	int PackData(BYTE* dataIn,int len,BYTE* data);			// 添加数据域
	int PackCRC(unsigned short crc,BYTE* data);						// 添加校验域
	int PackEnd(BYTE* data);								// 添加结束域

	void DisInterference(short *InDataBuf,
		unsigned long lenth,BYTE MobileType);				// 去扰
	void SmoothingWave(short *InDataBuf,unsigned long length, 
		unsigned long LowF, unsigned long HighF, 
		unsigned long SampleRate);							// 滤波
	BYTE GetAllData(BYTE *OutDataBuf,
		short *InDataBuf,unsigned long lenth,
		unsigned long *endlen,BYTE MobileType);				// 解出全部数据
	BYTE FindHead(short * InDataBuf,unsigned long lenth,
		unsigned long *endlen,BYTE MobileType);				// 查找同步头
	unsigned long GetN(unsigned long len);					//
	void FindFrame(short *pData, 
		unsigned long len, long *start, long *end);			//

	unsigned short CalculateCRC(BYTE *buf,unsigned short len);					// 计算CRC

public:
	CFSKModem();
	~CFSKModem();

public:
	short* Modulate(BYTE* data,int len,int* outFrameLen);	// 调制数据  
	int    Demodulate(BYTE *OutDataBuf,
		short *InDataBuf,unsigned long lenth,
		unsigned long *OutLenIndix,BYTE MobileType);		// 解调数据
	int	   GetValidData(short *InDataBuf,
		short *OutDataBuf,unsigned long lenth);				// 判断数据是否有效
		
	void SetFrequency(int frequency);
	int GetFrequency();
};

#endif
