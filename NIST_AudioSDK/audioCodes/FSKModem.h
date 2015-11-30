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

#ifndef BYTE
typedef unsigned char BYTE;
#endif

#ifndef DWORD
typedef unsigned long DWORD;
#endif

#define FS				44100			// ������
// ���͵�Ƶ�ʱ��̶����ˣ����Զ�ʹ�ú�����ʾ
#define MODULATE_FREQUENCY	5512.5		// ���Ƶ�Ƶ��
//#define MODULATE_FREQUENCY	4410		// ���Ƶ�Ƶ��
//#define MODULATE_FREQUENCY	2205
#define MODULATE_SAMPLE  (int)(FS / MODULATE_FREQUENCY)	// ����ʱ������ڵ���

class CFSKModem
{
private:
	// ����
	bool m_bIobitFlag;			// if true >0 else <0 ,�������ÿ�������������
	//char m_cPackageCount;		// ����������ÿ�η��Ͷ���++
	float *m_fPoint;           /* pointer to time-domain samples */
	int m_nFrequency;		//ͨѶƵ��  �ڽ����ʱ��ʹ�õ�

protected:
	int ModulateByte(BYTE byte,short* retData);				// ���һ���ֽ�
	int ModulateBit(int type,short* retData);				// ��һ�����ص����ݵ��Ƴ���Ƶ����

	BYTE* PackField(BYTE* data,int len,int *outLen);		// �鱨��
	int PackSYNC(BYTE* data);								// ���ͬ����
	int PackLevel(BYTE* data);								// ��Ӽ�����
	int PackLength(int len,BYTE* data);						// ��ӳ�����
	int PackData(BYTE* dataIn,int len,BYTE* data);			// ���������
	int PackCRC(unsigned short crc,BYTE* data);						// ���У����
	int PackEnd(BYTE* data);								// ��ӽ�����

	void DisInterference(short *InDataBuf,
		unsigned long lenth,BYTE MobileType);				// ȥ��
	void SmoothingWave(short *InDataBuf,unsigned long length, 
		unsigned long LowF, unsigned long HighF, 
		unsigned long SampleRate);							// �˲�
	BYTE GetAllData(BYTE *OutDataBuf,
		short *InDataBuf,unsigned long lenth,
		unsigned long *endlen,BYTE MobileType);				// ���ȫ������
	BYTE FindHead(short * InDataBuf,unsigned long lenth,
		unsigned long *endlen,BYTE MobileType);				// ����ͬ��ͷ
	unsigned long GetN(unsigned long len);					//
	void FindFrame(short *pData, 
		unsigned long len, long *start, long *end);			//

	unsigned short CalculateCRC(BYTE *buf,unsigned short len);					// ����CRC

public:
	CFSKModem();
	~CFSKModem();

public:
	short* Modulate(BYTE* data,int len,int* outFrameLen);	// ��������  
	int    Demodulate(BYTE *OutDataBuf,
		short *InDataBuf,unsigned long lenth,
		unsigned long *OutLenIndix,BYTE MobileType);		// �������
	int	   GetValidData(short *InDataBuf,
		short *OutDataBuf,unsigned long lenth);				// �ж������Ƿ���Ч
		
	void SetFrequency(int frequency);
	int GetFrequency();
};

#endif
