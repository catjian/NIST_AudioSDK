



#include "stdlib.h"
#include <string.h>
#include <unistd.h>
#include "MobileShield.h"

#include "FSK_Modem.h"

#include "MobileShield_Protocol.h"
#include "AudioPlayer.h"
#include "AudioRecord.h"


#include "RSA/FSKModem.h"

#import <AudioToolbox/AudioSession.h>


#import "newAdd/newFSKModem.h"

#import <sys/sysctl.h>


//#import "exten_Variable.h"

//extern unsigned long bufferSize;

#define AUDIO_RECODE_RUNLOOP_MODE @"AUDIO_RECODE_RUNLOOP_MODE"

USHORT g_ReadDataLength    = 0;

ReturnDataEx g_ReturnData;
//unsigned char YH_FrameHeader[6]={0xff,0xff,0xff,0xff,0xff,0xff};

unsigned char YH_FrameHeader[6]={0};
unsigned char FrameHeader[6]={0x55,0x55,0x01,0x01,0,0};

NSMutableDictionary *g_tokenReturnDic = [[NSMutableDictionary alloc] initWithCapacity:3];

extern BYTE WAITLEVEL;
extern BYTE LONGCMD; //for wait long time cmd

NSTimer *timer;
NSInteger timeoutCount = 0;
NSInteger timeOutLength = 10;

float timeInterval = 0.1;

BOOL isStop = NO;

BOOL isUse = NO;

STATUS status = STATUS_FAILED;

static CMobileShield * g_MobileShield = nil;

@interface CMobileShield ()
{
	bool        m_StopRecord;                                  // Õ£÷πΩ” ’ ˝æ›±Í ∂
	INT         m_ReturnDataLength;                            // ∑µªÿ ˝æ›≥§∂»
	INT         m_ReadDataTime;                                // –Ë“™∂¡»°∑µªÿ ˝æ›¥Œ ˝
	INT         m_CurrentReadTime;                             // µ±«∞∂¡»°∑µªÿ ˝æ›¥Œ ˝
	INT         m_CurrentDataLength;                           // “—æ≠∂¡»°∑µªÿ ˝æ›µƒ≥§∂»
	INT         m_LastReadLength;                              // …œ“ª¥Œ∂¡»°µƒ∑µªÿ ˝æ›≥§∂»
	CHAR *      m_ReturnData;                                  // ∂¡»°µƒ∑µªÿ ˝æ›
	BOOL        m_ReceiveFinish;                               // “Ù∆µ ˝æ›Ω” ’ÕÍ≥…±Í ∂
	bool        m_ReceiveData;                                 // Ω‚µ˜ ˝æ›±Í ∂
	bool        m_IsInitAudio;                                 // “Ù∆µ∑¢ÀÕ≥ı ºªØ±Í ∂
	bool        m_IsInitRecord;
}

@property (nonatomic) ApiType apitype;
@property (nonatomic) BOOL m_ReceiveFinish;

@end

@implementation CMobileShield
@synthesize m_ReceiveFinish;

+(ApiType)get6100ApitType
{
    return g_MobileShield.apitype;
}

+(CMobileShield *)shareMobileShield
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_MobileShield = [[CMobileShield alloc] init];
    });
    return g_MobileShield;
}


-(id)init
{
    DebugAudioLog(@"");
	self = [super init];
    if(self)
    {
        m_ReturnData		= NULL;
        m_StopRecord		= FALSE;
        m_ReceiveFinish 	= false;
        m_ReceiveData		= FALSE;
        m_ReturnDataLength	= 0;
        m_ReadDataTime		= 0;
        m_CurrentReadTime	= 0;
        m_CurrentDataLength = 0;
        m_LastReadLength	= 0;
        [self initAudioSessionRoute];
    }
    return self;
}

-(void)dealloc
{
    DebugAudioLog(@"");
	
	if ( m_ReturnData )
		free( m_ReturnData);
    m_ReturnData = NULL;
    
    [super dealloc];
}

//   +++++++++++++
float getVolumeLevel()
{
    MPVolumeView *slide = [MPVolumeView new];
    UISlider *volumeViewSlider = nil;
    
    for(UIView *view in [slide subviews])
    {
        if([[[view class] description] isEqualToString:@"MPVolumeSlider"])
        {
            volumeViewSlider = (UISlider *)view;
        }
    }
    float val = [volumeViewSlider value];
    [slide release];
    return val;
}

#pragma mark - AudioSession Route about

void volumeListenerCallBack(void                      *inUserData,
                            AudioSessionPropertyID    inPropertyID,
                            UInt32                    inPropertyValueS,
                            const void                *inPropertyValue)
{
    float *volumPointer = (float *)inPropertyValue;
    float volum = *volumPointer;
    NSLog(@"volum = %f",volum);
}

-(void)initAudioSessionRoute
{
    NSLog(@"getVolumeLevel = %f",getVolumeLevel());

//    AVPlayer *avPlay = [[AVPlayer alloc]initWithURL:nil];
//    NSLog(@"audioPlay.volume = %f",avPlay.volume);
//    
//    AVAudioPlayer *audioPlay = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:@""] error:nil];
//    NSLog(@"audioPlay.volume = %f",audioPlay.volume);
    
    NSLog(@"[MPMusicPlayerController applicationMusicPlayer].volume = %f",[MPMusicPlayerController applicationMusicPlayer].volume);
        //设置音量为最大
        if([MPMusicPlayerController applicationMusicPlayer].volume != 1.0)
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        }
        //    iOS应用程序的初始化音频会话对象。
        //    您的应用程序必须调用这个函数，然后再作出任何其他音频会话服务调用。你可以激活和停用您的音频会议需要（见AudioSessionSetActive），但应该初始化它一次。
        AudioSessionInitialize(nil, nil, nil, nil);
    
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallBack, self);
        //    添加对耳机的插拔监听
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallBack, (__bridge void*)(self));
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //    设置音频会话类
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        //    设置指定音频会话属性的值
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(AVAudioSessionCategoryPlayAndRecord), &category);
        [audioSession setActive:YES error:nil];
}

-(void)audioRouteChange:(BOOL)isChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationAudioRouteChange
                                                        object:Nil
                                                      userInfo:@{NotificationKeyIsChange:[NSNumber numberWithBool:isChange]}];
}

-(void)activateAudioSession
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

void audioRouteChangeListenerCallBack(void                      *inUserData,
                                      AudioSessionPropertyID    inPropertyID,
                                      UInt32                    inPropertyValueS,
                                      const void                *inPropertyValue)
{
    if(inPropertyID != kAudioSessionProperty_AudioRouteChange)
        return;
    CFDictionaryRef propertyDicRef = (CFDictionaryRef)inPropertyValue;
    
    CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue(propertyDicRef, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    if(kAudioSessionRouteChangeReason_OldDeviceUnavailable == routeChangeReason)        //耳机被拔出
    {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [g_MobileShield audioRouteChange:NO];
        [g_MobileShield audioRouteOut];
    }
    else if(kAudioSessionRouteChangeReason_NewDeviceAvailable == routeChangeReason)      //有新设备插入
    {
        [g_MobileShield audioRouteChange:YES];
        [g_MobileShield activateAudioSession];
    }
}

//耳机未插入
-(void)audioRouteOut
{
    DebugAudioLog(@"耳机拔出了");
    NSLog(@"++++++++++++++++++++++++++ audioRouteOut ++++++++++++++++++++++++++");
    @synchronized(self)
    {
//    dispatch_sync(dispatch_get_main_queue(), ^(void){
        
        if(![AudioRecorder shareAudioRecorder].recordState.recording)
        {
            return ;
        }
        if(m_ReceiveFinish == false)
        {
            [self performSelectorOnMainThread:@selector(endRunLoop) withObject:nil waitUntilDone:NO];
        }
        
    //    [timer invalidate];
    //    timer = nil;
        [CMobileShield StopAudioRecordTimer];
        
    //    [[AudioRecorder shareAudioRecorder] stopRecord];
        
        [[AudioRecorder shareAudioRecorder] performSelectorOnMainThread:@selector(stopRecord) withObject:nil waitUntilDone:NO];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        
//    });
    }
    NSLog(@"-------------------------- audioRouteOut ---------------------------");
}
//+++++++++++++++++++

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
    unsigned int i;
    unsigned char j;
    unsigned int crc;
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
            {
                //    crc=crc^0xa001;
                crc=crc^0x8408;
            }
            crc=crc&0xffff;
        }
        buf++;
    }
    hi=crc%256;
    lo=crc/256;
    crc=(hi<<8)|lo;
    return crc;
}
        
-(STATUS)SetupAudioTrack
{
    DebugAudioLog(@"");
	 m_IsInitAudio = TRUE;
    return STATUS_SUCCESS;
}

-(STATUS)SetupAudioRecord
{
    DebugAudioLog(@"");
	m_ReceiveFinish = false;
	m_ReceiveData   = FALSE;
	m_IsInitRecord = TRUE;
    return STATUS_SUCCESS;
}
        
-(STATUS)ReadData
{
    DebugAudioLog(@"");
	
	INT    nLen    = 0;
	INT totallen=0;
	INT startindex=0;
	INT demodLen=0;
	INT waitlen=0;
    ULONG buff_Rec = 1024 * 216;

	unsigned char *tempbuf = (unsigned char *)calloc(1024*1024*4, sizeof(unsigned char*));//(1024*512);
    if(tempbuf == NULL)
    {
        DebugAudioLog(@"calloc memery wrong!");
    }
    
	ResetReturnData();
	if(WAITLEVEL==1)
    {
		waitlen=256*1024;
	}
	else if(WAITLEVEL==2)
    {
        //waitlen=512*1024;
        waitlen=2000*1024;//640//768
	}
    else if(WAITLEVEL==3)
    {
        //waitlen=512*1024;
        waitlen=512*1024;//640//768
	}
	else
	{
		waitlen=512*1024;
	}
    
	while ( !m_ReceiveFinish )
    {
        if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        {
            if([AudioRecorder shareAudioRecorder].recordState.recording)
            {
                [self audioRouteOut];
            }
            break;
        }
        nLen = [[AudioRecorder shareAudioRecorder] getCircleLength];
        
        if (nLen < 8192 || nLen == 0)
        {
            continue;
        }
        
        [[AudioRecorder shareAudioRecorder] getCircleBuffer:tempbuf+totallen length:8192];
        totallen += 8192;
        
        if (nLen > 0)
        {
            if (totallen > buff_Rec)
            {
                startindex = totallen - buff_Rec;
                demodLen = (buff_Rec)/2;
            }
            else
            {
                startindex=0;
				demodLen=totallen/2;
            }
                
            if (DemoduleAudioData(tempbuf+startindex, demodLen,tempbuf)) 
            {
                DebugAudioLog(@"data received");
                status = STATUS_SUCCESS;
                m_ReceiveData = 1;
                totallen = 0;
                nLen = 0;
                memset(tempbuf,0,1024*512);
                
                [self audioRouteOut];
            }
            else
            {
//                if (totallen >= waitlen)
//                {
//                    //超时
//                    DebugAudioLog(@"over time");
//                    m_ReceiveData = 0;
//                    if([AudioRecorder shareAudioRecorder].recordState.recording)
//                    {
//                        [self audioRouteOut];
//                    }
//                }
            }
        }
    }
    
    free(tempbuf);
    tempbuf = NULL;
    if ( m_ReceiveData )
		status = STATUS_SUCCESS;
	else
		status = STATUS_FAILED;
	nLen = 0;
	totallen=0;
	return status;
}

-(void)endRunLoop
{
    m_ReceiveFinish = true;
}

//检测录音状态
-(void)checkRecordState_OC
{
    DebugAudioLog(@"");
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    if(![[CMobileShield shareMobileShield]  audioRoute_IsPlugedIn])
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    if([CMobileShield shareMobileShield].m_ReceiveFinish)       //如果录音的定时器已停止并且如果定时器没有释放就释放
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    
    timeoutCount ++ ;
    NSLog(@"timeoutCount = %d",timeoutCount);
    if(![AudioRecorder shareAudioRecorder].recordState.recording)  //如果在录音 释放定时器 停止录音和播放
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    else
    {
        if(timeoutCount*timeInterval >= timeOutLength)  //如果超时 释放定时器 更改解析状态 停止录音和播放 回调解析超时
        {
            [[CMobileShield shareMobileShield] audioRouteOut];
            return;
        }
    }
}

void checkRecordState()
{
    DebugAudioLog(@"");
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    if(![[CMobileShield shareMobileShield]  audioRoute_IsPlugedIn])
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    if([CMobileShield shareMobileShield].m_ReceiveFinish)       //如果录音的定时器已停止并且如果定时器没有释放就释放
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    
    timeoutCount ++ ;
    NSLog(@"timeoutCount = %d",timeoutCount);
    if(![AudioRecorder shareAudioRecorder].recordState.recording)  //如果在录音 释放定时器 停止录音和播放
    {
        [[CMobileShield shareMobileShield] audioRouteOut];
        return;
    }
    else
    {
        NSInteger outLength = timeOutLength;
        if ([CMobileShield shareMobileShield].apitype == ApiTypeQueryTokenEX)
        {
            outLength = 1;
        }
        if(timeoutCount*timeInterval >= outLength)  //如果超时 释放定时器 更改解析状态 停止录音和播放 回调解析超时
        {
            NSLog(@"++++++++++++++     timeout +++++++++++++");
            //++++++++by zhangjian 20141013 02:30
            if([CMobileShield shareMobileShield].apitype == CMD_READSTATUS)
            {
                CHAR data[2] = {static_cast<CHAR>(0x88), static_cast<CHAR>(0x88)};
                SetReturnData(1, 1, 2,  data);
            }
            //++++++++++++
            [[CMobileShield shareMobileShield] audioRouteOut];
            return;
        }
    }
}

-(NSDictionary *)resolveReciveInfo:(NSArray *)respCode1 :(NSArray *)respCode2
{
    NSMutableDictionary *msg = [[[NSMutableDictionary alloc]initWithCapacity:3] autorelease];
    
    DebugAudioLog(@"respCode1 = %@",[respCode1 componentsJoinedByString:@""]);
    DebugAudioLog(@"respCode2 = %@",[respCode2 componentsJoinedByString:@""]);
    
    if(self.apitype == ApiTypeCancelTrans || self.apitype == ApiTypeDelayLcd)
    {
        [msg setObject:@"0" forKey:reciveKey_ResponseCode];
        [msg setObject:@"音频Key数据解析成功" forKey:reciveKey_ErrorMessage];
        DebugAudioLog(@"self.apitype == ApiTypeCancelTrans || self.apitype == ApiTypeDelayLcd info = %@",msg);
        return (NSDictionary *)msg;
    }
    if(!respCode1 && !respCode2)
    {
        DebugAudioLog(@"respCode1 && respCode2 is NULL");
        return @{@"apiType":[NSNumber numberWithInt:self.apitype],
                 reciveKey_ResponseCode:@"-1",
                 reciveKey_ErrorMessage:@"音频Key通讯超时"};
    }
    if(1 == [respCode2[0]integerValue])
    {
        [msg setObject:@"9" forKey:reciveKey_ResponseCode];
        [msg setObject:@"版本错误" forKey:reciveKey_ErrorMessage];
        DebugAudioLog(@"1 == [respCode2[0]integerValue] info = %@",msg);
        return (NSDictionary *)msg;
    }
    [msg setObject:[respCode2 objectAtIndex:4] forKey:reciveKey_isHxShow];
    switch ([[respCode1 objectAtIndex:5] integerValue])
    {
        case 0: //SN正确
        {
            switch ([[respCode1 objectAtIndex:6] integerValue])
            {
                case 0: //已激活
                {
                    switch ([[respCode1 objectAtIndex:4] integerValue])
                    {
                        case 0: //音频Key未锁定
                        {
                            switch ([[respCode1 objectAtIndex:3] integerValue])
                            {
                                case 0: //音频Key未自动锁定
                                {
                                    switch ([[respCode1 objectAtIndex:2] integerValue])
                                    {
                                        case 0: //已设PIN码
                                        {
                                            switch ([[respCode2 objectAtIndex:7] integerValue])
                                            {
                                                case 0: //PIN码正确
                                                {
                                                    switch ([[respCode2 objectAtIndex:6] integerValue])
                                                    {
                                                        case 0: //校验码正确
                                                        {
                                                            [msg setObject:@"0" forKey:reciveKey_ResponseCode];
                                                            switch (self.apitype)
                                                            {
                                                                case ApiTypeQueryToken:
                                                                case ApiTypeUpdatePin:
                                                                case ApiTypeActiveTokenPlug:
                                                                case ApiTypeUnlockRandomNo:
                                                                case ApiTypeUnlockPin:
                                                                case ApiTypeLcdOpCode:
                                                                case ApiTypePowerShow:
                                                                case ApiTypeShowHxTransferInfo:
                                                                case ApiTypeGetTokenCodeSafety:
                                                                case ApiTypeQueryTokenEX:
                                                                case ApiTypeQueryVersionHW:
                                                                case ApiTypeRecordInfo:
                                                                case ApiTypeQueryInfo:
                                                                case ApiTypeDelayLcd:
                                                                case ApiTypeShowWallet:
                                                                case ApiTypeGetTokenCodeSafety_key:
                                                                case ApiTypeScanCode:
                                                                    [msg setObject:@"音频Key数据解析成功" forKey:reciveKey_ErrorMessage];
                                                                    break;
                                                                default:
                                                                    break;
                                                            }
                                                        }
                                                            break;
                                                        case 1: //校验码错误
                                                        {
                                                            [msg setObject:@"7" forKey:reciveKey_ResponseCode];
                                                            switch (self.apitype)
                                                            {
                                                                case ApiTypeQueryToken:
                                                                case ApiTypeUpdatePin:
                                                                case ApiTypeActiveTokenPlug:
                                                                case ApiTypeUnlockRandomNo:
                                                                case ApiTypeUnlockPin:
                                                                case ApiTypeLcdOpCode:
                                                                case ApiTypePowerShow:
                                                                case ApiTypeShowHxTransferInfo:
                                                                case ApiTypeGetTokenCodeSafety:
                                                                case ApiTypeQueryTokenEX:
                                                                case ApiTypeQueryVersionHW:
                                                                case ApiTypeRecordInfo:
                                                                case ApiTypeQueryInfo:
                                                                case ApiTypeDelayLcd:
                                                                case ApiTypeShowWallet:
                                                                case ApiTypeGetTokenCodeSafety_key:
                                                                case ApiTypeScanCode:
                                                                    [msg setObject:@"校验码错误" forKey:reciveKey_ErrorMessage];
                                                                    break;
                                                                default:
                                                                    break;
                                                            }
                                                        }
                                                            
                                                        default:
                                                            break;
                                                    }
                                                }
                                                    break;
                                                case 1: //PIN码错误
                                                {
                                                    [msg setObject:@"6" forKey:reciveKey_ResponseCode];
                                                    switch (self.apitype)
                                                    {
                                                        case ApiTypeUpdatePin:
                                                        case ApiTypeQueryInfo:
                                                        case ApiTypeQueryToken:
                                                        case ApiTypeActiveTokenPlug:
                                                        case ApiTypeUnlockRandomNo:
                                                        case ApiTypeUnlockPin:
                                                        case ApiTypeLcdOpCode:
                                                        case ApiTypePowerShow:
                                                        case ApiTypeShowHxTransferInfo:
                                                        case ApiTypeQueryTokenEX:
                                                        case ApiTypeQueryVersionHW:
                                                        case ApiTypeRecordInfo:
                                                        case ApiTypeDelayLcd:
                                                        case ApiTypeGetTokenCodeSafety:
                                                        case ApiTypeShowWallet:
                                                        case ApiTypeGetTokenCodeSafety_key:
                                                        case ApiTypeScanCode:
                                                            [msg setObject:@"PIN码错误"
                                                                    forKey:reciveKey_ErrorMessage];
                                                            break;
                                                        default:
                                                            break;
                                                    }
                                                }
                                                default:
                                                    break;
                                            }
                                        }
                                            break;
                                        case 1: //未设PIN码
                                        {
                                            [msg setObject:@"5" forKey:reciveKey_ResponseCode];
                                            switch (self.apitype)
                                            {
                                                case ApiTypeQueryToken:
                                                case ApiTypeUpdatePin:
                                                case ApiTypeActiveTokenPlug:
                                                case ApiTypeLcdOpCode:
                                                case ApiTypePowerShow:
                                                case ApiTypeShowHxTransferInfo:
                                                case ApiTypeGetTokenCodeSafety:
                                                case ApiTypeQueryTokenEX:
                                                case ApiTypeQueryVersionHW:
                                                case ApiTypeRecordInfo:
                                                case ApiTypeQueryInfo:
                                                case ApiTypeDelayLcd:
                                                case ApiTypeShowWallet:
                                                case ApiTypeGetTokenCodeSafety_key:
                                                case ApiTypeScanCode:
                                                    [msg setObject:@"请设置PIN码" forKey:reciveKey_ErrorMessage];
                                                    break;
                                                case ApiTypeUnlockPin:
                                                case ApiTypeUnlockRandomNo:
                                                    [msg setObject:@"音频Key解锁成功，请设置PIN码" forKey:reciveKey_ErrorMessage];
                                                    break;
                                                default:
                                                    break;
                                            }
                                        }
                                            break;
                                        default:
                                            break;
                                    }
                                }
                                    break;
                                case 1: //音频Key已自动锁定
                                {
                                    if(ApiTypeUnlockRandomNo == self.apitype)
                                    {
                                        [msg setObject:@"0" forKey:reciveKey_ResponseCode];
                                    }
                                    else
                                    {
                                        [msg setObject:@"4" forKey:reciveKey_ResponseCode];
                                        switch (self.apitype)
                                        {
                                            case ApiTypeQueryToken:
                                            case ApiTypeUpdatePin:
                                            case ApiTypeLcdOpCode:
                                            case ApiTypePowerShow:
                                            case ApiTypeShowHxTransferInfo:
                                            case ApiTypeGetTokenCodeSafety:
                                            case ApiTypeQueryTokenEX:
                                            case ApiTypeQueryVersionHW:
                                            case ApiTypeRecordInfo:
                                            case ApiTypeQueryInfo:
                                            case ApiTypeDelayLcd:
                                            case ApiTypeShowWallet:
                                            case ApiTypeGetTokenCodeSafety_key:
                                            case ApiTypeScanCode:
                                            {
                                                [msg setObject:@"音频Key已自动锁定" forKey:reciveKey_ErrorMessage];
                                            }
                                                break;
                                            case ApiTypeActiveTokenPlug:
                                            {
                                                [msg setObject:[NSString stringWithFormat:@"%@\n%@",@"音频Key已激活",@"音频Key自动锁定"] forKey:reciveKey_ErrorMessage];
                                            }
                                                break;
                                            case ApiTypeUnlockPin:
                                            {
                                                if(1 == [[respCode2 objectAtIndex:6] integerValue])
                                                {
                                                    [msg setObject:@"音频Key解锁失败，解锁码错误" forKey:reciveKey_ErrorMessage];
                                                }
                                            }
                                                break;
                                            default:
                                                break;
                                        }
                                    }
                                }
                                    break;
                                default:
                                    break;
                            }
                        }
                            break;
                        case 1: //音频Key已锁定
                        {
                            if(ApiTypeUnlockRandomNo == self.apitype)
                            {
                                [msg setObject:@"0" forKey:reciveKey_ResponseCode];
                            }
                            else
                            {
                                [msg setObject:@"3" forKey:reciveKey_ResponseCode];
                                switch (self.apitype)
                                {
                                    case ApiTypeQueryToken:
                                    case ApiTypeUpdatePin:
                                    case ApiTypeLcdOpCode:
                                    case ApiTypePowerShow:
                                    case ApiTypeShowHxTransferInfo:
                                    case ApiTypeGetTokenCodeSafety:
                                    case ApiTypeQueryTokenEX:
                                    case ApiTypeQueryVersionHW:
                                    case ApiTypeRecordInfo:
                                    case ApiTypeQueryInfo:
                                    case ApiTypeDelayLcd:
                                    case ApiTypeShowWallet:
                                    case ApiTypeGetTokenCodeSafety_key:
                                    case ApiTypeScanCode:
                                    {
                                        [msg setObject:@"音频Key已锁定" forKey:reciveKey_ErrorMessage];
                                    }
                                        break;
                                        
                                    case ApiTypeActiveTokenPlug:
                                    {
                                        [msg setObject:[NSString stringWithFormat:@"%@\n%@",@"音频Key已激活",@"音频Key锁定"] forKey:reciveKey_ErrorMessage];
                                    }
                                        break;
                                        
                                    case ApiTypeUnlockPin:
                                    {
                                        if(1 == [[respCode2 objectAtIndex:6] integerValue])
                                        {
                                            [msg setObject:@"音频Key解锁失败，解锁码错误" forKey:reciveKey_ErrorMessage];
                                        }
                                    }
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 1: //未激活
                {
                    [msg setObject:@"2" forKey:reciveKey_ResponseCode];
                    switch (self.apitype)
                    {
                        case ApiTypeQueryToken:
                        case ApiTypeUpdatePin:
                        case ApiTypeUnlockRandomNo:
                        case ApiTypeUnlockPin:
                        case ApiTypeLcdOpCode:
                        case ApiTypePowerShow:
                        case ApiTypeShowHxTransferInfo:
                        case ApiTypeGetTokenCodeSafety:
                        case ApiTypeQueryTokenEX:
                        case ApiTypeQueryVersionHW:
                        case ApiTypeRecordInfo:
                        case ApiTypeQueryInfo:
                        case ApiTypeDelayLcd:
                        case ApiTypeShowWallet:
                        case ApiTypeGetTokenCodeSafety_key:
                        case ApiTypeScanCode:
                        {
                            [msg setObject:@"请激活音频Key" forKey:reciveKey_ErrorMessage];
                        }
                            break;
                        case ApiTypeActiveTokenPlug:
                        {
                            if([[respCode2 objectAtIndex:6] integerValue])
                            {
                                [msg setObject:@"音频Key激活失败，激活码错误" forKey:reciveKey_ErrorMessage];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1: //SN号错误
        {
            [msg setObject:@"1" forKey:reciveKey_ResponseCode];
            switch (self.apitype)
            {
                case ApiTypeQueryToken:
                case ApiTypeUpdatePin:
                case ApiTypeActiveTokenPlug:
                case ApiTypeUnlockRandomNo:
                case ApiTypeUnlockPin:
                case ApiTypeLcdOpCode:
                case ApiTypePowerShow:
                case ApiTypeShowHxTransferInfo:
                case ApiTypeGetTokenCodeSafety:
                case ApiTypeQueryTokenEX:
                case ApiTypeQueryVersionHW:
                case ApiTypeRecordInfo:
                case ApiTypeQueryInfo:
                case ApiTypeDelayLcd:
                case ApiTypeShowWallet:
                case ApiTypeGetTokenCodeSafety_key:
                case ApiTypeScanCode:
                {
                    [msg setObject:@"序列号错误" forKey:reciveKey_ErrorMessage];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    DebugAudioLog(@"success info = %@",msg);
    return (NSDictionary *)msg;
}

NSOperationQueue *queue;

-(STATUS)SendData:(VOID *)data dataLength:(INT)len recObj:(VOID *)obj recCbf:(VOID *)cbf
{
    DebugAudioLog(@"");
    status = STATUS_FAILED;
	INT    nFrame_Len = 0;
	INT    nLen       = 0;
    
	VOID * pResult    = NULL;
	CHAR * pData      = NULL;
	CHAR * pTemp      = NULL;
	
	m_StopRecord 	   = FALSE;
	m_ReturnDataLength = 0;
	m_ReadDataTime	   = 0;
	m_CurrentReadTime  = 0;
	m_ReturnData 	   = NULL;
    m_ReceiveFinish    = false;

    COS_DATA COS_Data;  //下午5：16，1月29号
    
    
	if ( !data )
		return STATUS_FAILED;

	if ( len == 0 )
		return STATUS_FAILED;
    
    
	nLen  = len;
	pTemp = ( CHAR * )data;
    
    printf("\npTemp:\n");
    for(int i=0; i<nLen; i++)
    {
        printf("%02x ",pTemp[i]);
    }
    printf("\n\n");
    timeOutLength = 10;
    BYTE CLA = pTemp[2], INS = pTemp[3];
    if(CLA == 0x80 && INS == 0xcc)
    {
        isStop = NO;
        SetSendType( _6100_token_COMMAND );
        self.apitype = (ApiType)pTemp[4];
    }
    else if(CLA == 0x80 && INS == CMD_READSTATUS)
    {
        BYTE p1 = pTemp[4];
        if(p1 == 0xcc)
        {
            SetSendType( _6100_token_COMMAND );
            self.apitype = (ApiType)CMD_READSTATUS;
        }
        else
        {
            SetSendType( USER_SEND_COMMAND );
        }
        timeOutLength = 1;
        pTemp[4] = 0x00;
        printf("\npTemp:\n");
        for(int i=0; i<nLen; i++)
        {
            printf("%02x ",pTemp[i]);
        }
        printf("\n\n");
    }
    else
    {
        isStop = NO;
        SetSendType( USER_SEND_COMMAND );
    }
    
    pData = ( CHAR * )calloc( nLen + 9, sizeof( BYTE ) );
    
	memcpy( pData+6, pTemp, nLen );
	memcpy(pData,FrameHeader,4);
	pData[4]=(nLen+2);
	pData[5]=(nLen+2)>>8;
	nLen=nLen+6;
    
    for(int i=0; i<nLen; i++)
    {
        printf("%02x ",pData[i]);
    }
    printf("\n\n");
    BYTE cmd = pData[9];
    unsigned int crc = chkcrc((unsigned char *)pData,nLen);
    pData[nLen] = (char)crc ;
    pData[nLen+1] = (char)(crc>>8) ;
    pData[nLen+2] = '\0' ;
    nLen += 2;

	pResult = BuildFSKDataFrame( ( CHAR * )pData, nLen, &nFrame_Len );
    
    if(pResult != NULL)
    {
        [self SetupAudioRecord];
        [self SetupAudioTrack];
        NSData *NDSendData = [[NSData alloc]initWithBytes:(const char*)pResult length:nFrame_Len];
        //DebugAudioLog(@"SetupAudioTrack------------------END--------------------------------");
        [[AudioPlayer shareAudioPlayer] AudioPlayData:NDSendData];
        [NDSendData release];
        NDSendData = nil;
        [[AudioRecorder shareAudioRecorder] record];
        
        /**/
//        queue = [[NSOperationQueue alloc]init];
//        [queue setMaxConcurrentOperationCount:1];//设置并发数
//        [queue setSuspended:NO];
        dispatch_async(dispatch_queue_create("time_out_control", DISPATCH_QUEUE_SERIAL), ^(void){
//            if(cmd != CMD_READSTATUS)
            {
                timeoutCount = 0;
                [CMobileShield CreateAudioRecordTimer:timeInterval selectObject:^{checkRecordState();}];
            }
            status=[self ReadData];
//            NSInvocationOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(ReadData) object:nil];
//            [queue addOperation:op];
//            [op release];
        });
        
        m_ReceiveFinish = false;
        while (!m_ReceiveFinish)
        {
            if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            {
                [[CMobileShield shareMobileShield] audioRouteOut];
                break;
            }
            else
            {
                [[NSRunLoop currentRunLoop] runMode:AUDIO_RECODE_RUNLOOP_MODE beforeDate:[NSDate distantFuture]];
            }
        }
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//         */
//        status=[self ReadData];
    }
	if ( status != STATUS_SUCCESS )
	{
		status = STATUS_FAILED;
//        if(m_ReturnData != NULL)
//        {
//            free( m_ReturnData );
//            m_ReturnData = NULL;    
//        }
//        if (pData != NULL)
//        {
//		    free( pData );
//            pData = NULL;
//         }
//        if (pResult != NULL)
//        {
//		    free( pResult );
//            pResult = NULL;
//        }
        return status;
	}
	else
	{
        [[CMobileShield shareMobileShield] audioRouteOut];
        
//        if (pData != NULL)
//        {
//            free( pData );
//            pData = NULL;
//        }
//		if (pResult != NULL)
//        {
//            free( pResult );
//            pResult = NULL;
//        }
    
        GetAllReturnData(&COS_Data);
        DebugAudioLog(@"COS_Data.Status = %02x", COS_Data.Status);
        Return_Data param;
        if(COS_Data.Type == USER_SEND_COMMAND)
        {
            if (COS_Data.Status == ( SHORT )0x9000)
            {
                param.Status = STATUS_SUCCESS;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                
                SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
            else
            {
                if(cmd == CMD_DIGEST)
                {
                    if (COS_Data.Status == ( SHORT )0x9999)
                    {
                        param.Status = STATUS_SUCCESS;
                        param.Type   = COS_Data.Status;
                        param.Data   = COS_Data.Data;
                        
                        SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                        
                        if (COS_Data.Data != NULL)
                        {
                            free(COS_Data.Data);
                            COS_Data.Data = NULL;
                        }
                    }
                    return param.Status;
                }

                param.Status = STATUS_FAILED;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                printf("%s\n",param.Data);
                SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR *)COS_Data.Data );
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
        }
        else if(COS_Data.Type == _6100_token_COMMAND)
        {
            if(self.apitype == (ApiType)0xF3)
            {
                if (COS_Data.Status == ( SHORT )0x9000)
                {
                    param.Status = STATUS_SUCCESS;
                    unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                    memcpy(result, COS_Data.Data, 2);
                    if (result[0] == 0x77 && result[1] == 0x77)
                    {
                        int resp1[8], resp2[8];
                        for(int i=0; i<8; i++)
                        {
                            resp1[i] = COS_Data.respCode[0][i];
                            resp2[i] = COS_Data.respCode[1][i];
                        }
                        NSArray *respCode1 = @[[NSNumber numberWithInt:resp1[0]],[NSNumber numberWithInt:resp1[1]],
                                               [NSNumber numberWithInt:resp1[2]],[NSNumber numberWithInt:resp1[3]],
                                               [NSNumber numberWithInt:resp1[4]],[NSNumber numberWithInt:resp1[5]],
                                               [NSNumber numberWithInt:resp1[6]],[NSNumber numberWithInt:resp1[7]]];
                        NSArray *respCode2 = @[[NSNumber numberWithInt:resp2[0]],[NSNumber numberWithInt:resp2[1]],
                                               [NSNumber numberWithInt:resp2[2]],[NSNumber numberWithInt:resp2[3]],
                                               [NSNumber numberWithInt:resp2[4]],[NSNumber numberWithInt:resp2[5]],
                                               [NSNumber numberWithInt:resp2[6]],[NSNumber numberWithInt:resp2[7]]];
                        
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[self resolveReciveInfo:respCode1 :respCode2]];
                        
                        [dic setObject:[NSNumber numberWithInt:STATUS_SUCCESS] forKey:@"return_status"];
                        
                        
                        BYTE *COSData = (BYTE*)calloc(COS_Data.Length, sizeof(BYTE));
                        memcpy(COSData, COS_Data.Data, COS_Data.Length);
                        for(int i=0; i<COS_Data.Length; i++)
                        {
                            printf("%02x ",COSData[i]);
                        }
                        printf("\n\n");
                        
                        char dataLen[4] = {0};
                        for(int i=0,j=0; i < 4; i++)
                        {
                            if(COSData[10+i] == 0x00)
                            {
                                continue;
                            }
                            dataLen[j] = COSData[10+i];
                            j++;
                        }
                        char *d_len = (char *)calloc(4, sizeof(char));
                        memcpy(d_len, dataLen, 4);
                        int pwdLen = (int)*d_len;
                        char *realData = (char *)calloc(pwdLen, sizeof(char));
                        memcpy(realData, COSData+14, pwdLen);
                        [dic setObject:[NSString stringWithFormat:@"%s",realData] forKey:reciveKey_RecordInfo];
                        
                        SetTokenReturnData(dic);
                    }
                    param.Type   = COS_Data.Status;
                    param.Data   = COS_Data.Data;
                    
                    SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                   
                    
                    if (COS_Data.Data != NULL)
                    {
                        free(COS_Data.Data);
                        COS_Data.Data = NULL;
                    }
                    free(result);
                    result = nil;
                }
                else
                {
                    param.Status = STATUS_FAILED;
                    param.Type   = COS_Data.Status;
                    param.Data   = COS_Data.Data;
                    printf("%s\n",param.Data);
                    SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR *)COS_Data.Data );
                    
                    if (COS_Data.Data != NULL)
                    {
                        free(COS_Data.Data);
                        COS_Data.Data = NULL;
                    }
                }
                
                if(isStop)
                {
                    CHAR data[2] = {0};
                    data[0] = 0x66;
                    data[1] = 0x66;
                    SetReturnData(param.Status, param.Type, 2, data);
                }
                
                return param.Status;
            }
            if (COS_Data.Status == ( SHORT )0x9000)
            {
                param.Status = STATUS_SUCCESS;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                
                BYTE *COSData = (BYTE*)calloc(COS_Data.Length, sizeof(BYTE));
                memcpy(COSData, COS_Data.Data, COS_Data.Length);
                for(int i=0; i<COS_Data.Length; i++)
                {
                    printf("%02x ",COSData[i]);
                }
                printf("\n\n");
                
                int resp1[8], resp2[8];
                for(int i=0; i<8; i++)
                {
                    resp1[i] = COS_Data.respCode[0][i];
                    resp2[i] = COS_Data.respCode[1][i];
                }
                NSArray *respCode1 = @[[NSNumber numberWithInt:resp1[0]],[NSNumber numberWithInt:resp1[1]],
                                       [NSNumber numberWithInt:resp1[2]],[NSNumber numberWithInt:resp1[3]],
                                       [NSNumber numberWithInt:resp1[4]],[NSNumber numberWithInt:resp1[5]],
                                       [NSNumber numberWithInt:resp1[6]],[NSNumber numberWithInt:resp1[7]]];
                NSArray *respCode2 = @[[NSNumber numberWithInt:resp2[0]],[NSNumber numberWithInt:resp2[1]],
                                       [NSNumber numberWithInt:resp2[2]],[NSNumber numberWithInt:resp2[3]],
                                       [NSNumber numberWithInt:resp2[4]],[NSNumber numberWithInt:resp2[5]],
                                       [NSNumber numberWithInt:resp2[6]],[NSNumber numberWithInt:resp2[7]]];
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[self resolveReciveInfo:respCode1 :respCode2]];
                
                [dic setObject:[NSNumber numberWithInt:STATUS_SUCCESS] forKey:@"return_status"];
                if([dic[reciveKey_ResponseCode] integerValue] == 6)
                {
                    [dic setObject:[NSString stringWithFormat:@"PIN码错误，还剩%d次机会",COSData[0]]
                            forKey:reciveKey_ErrorMessage];
                }
                [dic setObject:[NSString stringWithFormat:@"%s",COS_Data.Data] forKey:reciveKey_RecordInfo];
                
                SetTokenReturnData(dic);
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
            else
            {
                
            }
        }
        
        return param.Status;
    }
}

STATUS SendDataToMobileShield( VOID * data, INT len, VOID* obj, VOID * cbf )
{
    DebugAudioLog(@"");
    if(![[CMobileShield shareMobileShield]  audioRoute_IsPlugedIn])
    {
        ResetReturnData();
        return STATUS_FAILED;
    }
    
    if([AudioRecorder shareAudioRecorder].recordState.recording)
    {
        return STATUS_FAILED;
    }
//    return [[CMobileShield shareMobileShield] SendData:data dataLength:len recObj:obj recCbf:cbf];
    
    return [[CMobileShield shareMobileShield] YH_SendData:data dataLength:len recObj:obj recCbf:cbf];
}


USHORT GetReadDataLength()
{
    DebugAudioLog(@"");
	
	return g_ReadDataLength;
}

VOID SetReadDataLength( USHORT len )
{
    DebugAudioLog(@"");
	
	g_ReadDataLength = len;
}


ReturnDataEx * GetReturnDataEx()
{
    DebugAudioLog(@"");
	
	return &g_ReturnData;
}

VOID ResetReturnData()
{
    DebugAudioLog(@"");
	memset( &g_ReturnData, 0,20);
    if([[CMobileShield shareMobileShield]  audioRoute_IsPlugedIn])
    {
        [[AudioRecorder shareAudioRecorder] CleanCircleBuffer];
    }
}

VOID SetReturnData( INT status, SHORT type, INT length, CHAR * data )
{
	g_ReturnData.Status = status;
	g_ReturnData.Type   = type;
	g_ReturnData.Length = length;
	if ( data )
		memcpy( g_ReturnData.Data, data, length );
}

VOID SetTokenReturnData(NSDictionary *reDic)
{
    g_tokenReturnDic = [[NSMutableDictionary alloc] initWithDictionary:reDic];
}

NSDictionary *GetTokenReturnData()
{
    return (NSDictionary *)g_tokenReturnDic;
}

bool isInitRoute = NO;
-(BOOL)audioRoute_IsPlugedIn
{
#if TARGET_IPHONE_SIMULATOR     //模拟器
    return NO;
#else
    if(!isInitRoute)
    {
        AudioSessionInitialize(nil, nil, nil, nil);
        isInitRoute = YES;
    }
    CFStringRef route;
    UInt32 propertSize = sizeof(CFStringRef);
    //获取指定的音频会话属性的值
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertSize, &route);

    if(nil == route || 0 == CFStringGetLength(route))
    {
        return NO;
    }
    else
    {
        NSString *routeStr = (__bridge NSString *)route;
        NSRange rangeHeadPhone = [routeStr rangeOfString:@"Headphone"];
        NSRange rangeHeadSet = [routeStr rangeOfString:@"Headset"];
        if(rangeHeadPhone.location != NSNotFound)
        {
            return YES;
        }
        if(rangeHeadSet.location != NSNotFound)
        {
            return YES;
        }
    }
    return NO;
#endif
}

+(void)stopAudioSessionControl
{
    isStop = YES;
    [[CMobileShield shareMobileShield] audioRouteOut];
}


//+++++test++++
dispatch_queue_t timerQueue;
dispatch_source_t connectTimer;
dispatch_source_t CreateAudioRecordDispatchTimer(uint64_t interval,
                                                 uint64_t leeway,
                                                 dispatch_queue_t queue,
                                                 dispatch_block_t block)
{
    if(!connectTimer)
    {
        connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        if(connectTimer)
        {
            dispatch_time_t tt = dispatch_walltime(DISPATCH_TIME_NOW, 0);
            dispatch_source_set_timer(connectTimer, tt, interval, leeway);
            dispatch_source_set_event_handler(connectTimer, block);
            dispatch_resume(connectTimer);
            return connectTimer;
        }
    }
    return connectTimer;
}

+(void)CreateAudioRecordTimer:(float) intervalTime selectObject:(dispatch_block_t) block
{
    if(!timerQueue)
    {
        timerQueue = dispatch_queue_create("Audio record check timeout queue", DISPATCH_QUEUE_SERIAL);
        dispatch_source_t aTimer = CreateAudioRecordDispatchTimer(intervalTime * NSEC_PER_SEC,
                                                                  1ull * NSEC_PER_SEC,
                                                                  timerQueue,
                                                                  block);
        // Store it somewhere for later use.
        if (aTimer)
        {
            DebugAudioLog(@"Create and Start Audio record check timeout queue OK");
        }
    }
}


NSCondition* ticketsCondition = [[NSCondition alloc] init];

+(void)StopAudioRecordTimer
{
    DebugAudioLog(@"Stop Audio record check timeout queue");
//    @synchronized(connectTimer)
    
    [ticketsCondition lock];
    {
        if(connectTimer)
        {
            dispatch_source_set_cancel_handler(connectTimer, ^{
                DebugAudioLog(@"Stop Audio record check timeout queue OK");
            });
            
            dispatch_source_cancel(connectTimer);
            connectTimer = NULL;
//            @synchronized(timerQueue)
            {
                if(timerQueue)
                {
        //            dispatch_release(connectTimer);
                    connectTimer = NULL;
        //#if !OS_OBJECT_USE_OBJC
        //            dispatch_release(timerQueue);
        //#endif
                    timerQueue = NULL;
                }
            }
        }
    }
    [ticketsCondition unlock];
    [[CMobileShield shareMobileShield] endRunLoop];
}


#pragma mark - 一盒宝

static int SetGarbageLen=0;
-(int)SetGarbageData:(int)time_ms
{
    DebugAudioLog(@"");
    SetGarbageLen=44100*2/1000*time_ms;
    return SetGarbageLen;
}
-(unsigned char*)MakeGarbageData:(unsigned char *)pData Length:(int)Len
{
    DebugAudioLog(@"");
    char *rubbish=(char *)malloc(SetGarbageLen);
    memset(rubbish, 0, SetGarbageLen);
    unsigned char *modulData=(unsigned char *)malloc(SetGarbageLen+Len);
    memcpy(modulData, rubbish, SetGarbageLen);
    memcpy(modulData+SetGarbageLen, pData, Len);
    free(rubbish);
    rubbish=nil;
    free(pData);
    pData=nil;
    return modulData;
}

-(STATUS)YH_SendData:(VOID *)data dataLength:(INT)len recObj:(VOID *)obj recCbf:(VOID *)cbf
{
    DebugAudioLog(@"");
    
    NSLog(@"start record");
    
    status = STATUS_FAILED;
	INT    nFrame_Len = 1;
	INT    nLen       = 0;
    
	VOID * pResult    = NULL;
	CHAR * pData      = NULL;
	CHAR * pTemp      = NULL;
	
	m_StopRecord 	   = FALSE;
	m_ReturnDataLength = 0;
	m_ReadDataTime	   = 0;
	m_CurrentReadTime  = 0;
	m_ReturnData 	   = NULL;
    m_ReceiveFinish    = false;
    
    COS_DATA_YH COS_Data;  //下午5：16，1月29号
    
    
	if ( !data )
		return STATUS_FAILED;
    
	if ( len == 0 )
		return STATUS_FAILED;
    
    
	nLen  = len;
	pTemp = ( CHAR * )data;
    timeOutLength = 10;
    BYTE CLA = pTemp[2], INS = pTemp[3];
    if(CLA == 0x80 && INS == 0xcc)
    {
        isStop = NO;
        YH_SetSendType( _6100_token_COMMAND );
        self.apitype = (ApiType)pTemp[4];
    }
    else if(CLA == 0x80 && INS == CMD_READSTATUS)
    {
        BYTE p1 = pTemp[4];
        timeOutLength = 1;
        if(p1 == 0xcc)
        {
            YH_SetSendType( _6100_token_COMMAND );
            self.apitype = (ApiType)CMD_READSTATUS;
        }
        else
        {
            self.apitype = (ApiType)CMD_READSTATUS;
            YH_SetSendType( USER_SEND_COMMAND );
        }
        
        pTemp[4] = 0x00;
    }
    else
    {
        self.apitype = (ApiType)1000;
        isStop = NO;
        YH_SetSendType( USER_SEND_COMMAND );
    }
    
//    +++++++++++++++++++
    if(self.apitype == ApiTypeCancelTrans)
    {
        [AudioRecorder shareAudioRecorder].bufferSize = 4000;
        if(!isUse)
        {
            return STATUS_FAILED;
        }
        isUse = NO;
    }
    else
    {
//        if([[newFSKModem shareNewFSKModem] nYH_GetSendType] == _6100_token_COMMAND)
        if(YH_GetSendType() == _6100_token_COMMAND)
        {
            if(self.apitype == ApiTypeGetTokenCodeSafety
               || self.apitype == ApiTypeGetTokenCodeSafety_key)
            {
                isUse = YES;
            }
            else
            {
                isUse = NO;
            }
            
            switch (self.apitype)
            {
                case ApiTypeQueryTokenEX:
                    [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*1;
                    break;
                case ApiTypeGetTokenCodeSafety:
                case ApiTypeGetTokenCodeSafety_key:
                    [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*2;
                    break;
                case CMD_READSTATUS:
                    [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*2*10;
                    break;
                default:
                    [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*2;
                    break;
            }
        }
        else if(YH_GetSendType() == USER_SEND_COMMAND) //        else if([[newFSKModem shareNewFSKModem] nYH_GetSendType] == USER_SEND_COMMAND)
        {
            NSLog(@"INS = %02x",INS);
            if(INS == CMD_CHANGE_PIN)
            {
                isUse = YES;
            }
            else
            {
                isUse = NO;
            }
        }
        
        switch (INS )
        {
            case CMD_GET_PININFO:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*0.5;
                break;
            case CMD_CHANGE_PIN:
            case CMD_OPEN_APPLICATION:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*1;
                break;
            case CMD_RSA_SIGNDATA:
            case CMD_ECC_SIGNDATA:
            case CMD_DEVAUTH:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*1.5;
                break;
            case CMD_GEN_RANDOM:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*2;
                break;
            case CMD_OPEN_CONTAINER:
            case CMD_GET_FILEINFO:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*3;
                break;
            case CMD_ENUM_FILES:
            case CMD_ENUM_CONTAINER:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*4;
                break;
            case CMD_READSTATUS:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*5.5;
                break;
            case CMD_READ_FILE:
            case CMD_GETICCARDNUM:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*5*10;
                break;
            default:
                [AudioRecorder shareAudioRecorder].bufferSize = 1024*8*1;
                break;
        }
    }
//    +++++++++++++++
    
    pData = ( CHAR * )calloc( nLen + 9+6, sizeof( BYTE ) );
    
	memcpy( pData+12, pTemp, nLen );
	memcpy(pData,YH_FrameHeader,6);
	memcpy(pData+6,FrameHeader,4);
	pData[4+6]=(nLen-2);
	pData[5+6]=(nLen-2)>>8;
	nLen=nLen+6+6;
    
    printf("\n Send pData lenght = %d :\n",nLen);
    for(int i=0; i<nLen; i++)
    {
        printf("%02x ",pData[i]);
    }
    printf("\n\n");
    BYTE cmd = pData[9+6];
    unsigned int crc = chkcrc((unsigned char *)pData+6+4,nLen-6-4);
    pData[nLen] = (char)crc ;
    pData[nLen+1] = (char)(crc>>8) ;
    pData[nLen+2] = '\0' ;
    nLen += 2;
    
    if(self.apitype == CMD_READSTATUS)
    {
        memcpy(pData,YH_FrameHeader,6);
        nLen += 6;
    }
    
	pResult = YH_BuildFSKDataFrame( ( CHAR * )pData, nLen, &nFrame_Len );
    
    data = nil;
    pTemp = nil;
    pData = nil;
    
    if(pResult != NULL)
    {
        //        ++++++++++++++++
        [self SetGarbageData:1];
        nFrame_Len=nFrame_Len*2;
        //添加垃圾数据
        if (SetGarbageLen)
        {
            pResult=(short*)[self MakeGarbageData:(unsigned char *)pResult Length:nFrame_Len];
            nFrame_Len+=SetGarbageLen;
        }
        //        +++++++++++++++++
     
        [self SetupAudioRecord];
        [self SetupAudioTrack];
        
        NSData *NDSendData = [[NSData alloc]initWithBytes:(const char*)pResult length:nFrame_Len];
        //DebugAudioLog(@"SetupAudioTrack------------------END--------------------------------");
        NSLog(@"start play");
        [[AudioPlayer shareAudioPlayer] AudioPlayData:NDSendData];
        [NDSendData release];
        NDSendData = nil;
        
        
        if(self.apitype == ApiTypeCancelTrans)
        {
            free(pResult);
            pResult = NULL;
            return STATUS_SUCCESS;
        }
    
        NSLog(@"start record");
        [[AudioRecorder shareAudioRecorder] record];
        ResetReturnData();
        
        dispatch_async(dispatch_queue_create("time_out_control", DISPATCH_QUEUE_SERIAL), ^(void){
            timeoutCount = 0;
            [CMobileShield CreateAudioRecordTimer:timeInterval selectObject:^{checkRecordState();}];
            status=[self YH_ReadData];
        });
        
        m_ReceiveFinish = false;
        while (!m_ReceiveFinish)
        {
            if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            {
                [[CMobileShield shareMobileShield] audioRouteOut];
                break;
            }
            else
            {
                [[NSRunLoop currentRunLoop] runMode:AUDIO_RECODE_RUNLOOP_MODE beforeDate:[NSDate distantFuture]];
            }
        }
        CGFloat dataSince = 0.1;
        NSString *platform = [NSString getDeviceVersion];
        if([platform rangeOfString:@"iPhone3"].location != NSNotFound ||
           [platform rangeOfString:@"iPhone2"].location != NSNotFound ||
           [platform rangeOfString:@"iPhone1"].location != NSNotFound)
        {
            dataSince = 0.2;
        }
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:dataSince]];
    }
    
	DebugAudioLog(@"status = %d", status);
    [[CMobileShield shareMobileShield] audioRouteOut];
    
    if ( status != STATUS_SUCCESS )
	{
		status = STATUS_FAILED;
        if(m_ReturnData != NULL)
        {
            m_ReturnData = NULL;
        }
        if (pData != NULL)
        {
            pData = NULL;
        }
        if (pResult != NULL)
        {
		    free( pResult );
            pResult = NULL;
        }
        if(timeoutCount >= timeOutLength/timeInterval)
        {
            status = STATUS_TIMEOUT;
        }
        return status;
	}
	else
	{
        
        if (pData != NULL)
        {
            pData = NULL;
        }
		if (pResult != NULL)
        {
            free( pResult );
            pResult = NULL;
        }
        
        YH_GetAllReturnData(&COS_Data);
        
        NSLog(@"COS_Data.Status = %02x", COS_Data.Status);
        Return_Data param;
        if(COS_Data.Type == USER_SEND_COMMAND)
        {
            if (COS_Data.Status == ( SHORT )0x9000)
            {
                param.Status = STATUS_SUCCESS;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                
                SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
            else
            {
                if(cmd == CMD_DIGEST)
                {
                    if (COS_Data.Status == ( SHORT )0x9999)
                    {
                        param.Status = STATUS_SUCCESS;
                        param.Type   = COS_Data.Status;
                        param.Data   = COS_Data.Data;
                        
                        SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                        
                        if (COS_Data.Data != NULL)
                        {
                            free(COS_Data.Data);
                            COS_Data.Data = NULL;
                        }
                    }
                    return param.Status;
                }
                if(cmd == CMD_CHANGE_PIN)
                {
//                    if (COS_Data.Status == ( SHORT )0x6666 || COS_Data.Status == ( SHORT )0x3333)
                    {
                        param.Status = STATUS_SUCCESS;
                        param.Type   = COS_Data.Status;
                        param.Data   = COS_Data.Data;
                        
                        SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                        
                        if (COS_Data.Data != NULL)
                        {
                            free(COS_Data.Data);
                            COS_Data.Data = NULL;
                        }
                    }
                    return param.Status;
                }
                
                param.Status = STATUS_FAILED;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                printf("error msg = %s\n",param.Data);
                SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR *)COS_Data.Data );
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
        }
        else if(COS_Data.Type == _6100_token_COMMAND)
        {
            if(self.apitype == (ApiType)0xF3)
            {
                if (COS_Data.Status == ( SHORT )0x9000)
                {
                    NSLog(@"COSData:\n\n");
                    BYTE *COSData = (BYTE*)calloc(COS_Data.Length, sizeof(BYTE));
                    memcpy(COSData, COS_Data.Data, COS_Data.Length);
                    for(int i=0; i<COS_Data.Length; i++)
                    {
                        printf("%02x ",COSData[i]);
                    }
                    printf("\n\n");
                    
                    
                    param.Status = STATUS_SUCCESS;
                    unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                    memcpy(result, COS_Data.Data, 2);
                    if (result[0] == 0x77 && result[1] == 0x77)
                    {
                        int resp1[8], resp2[8];
                        for(int i=0; i<8; i++)
                        {
                            resp1[i] = COS_Data.respCode[0][i];
                            resp2[i] = COS_Data.respCode[1][i];
                        }
                        NSMutableDictionary *dic = nil;
                        if(self.waitApiType != ApiTypeUpdatePin)
                        {
                            NSArray *respCode1 = @[[NSNumber numberWithInt:resp1[0]],[NSNumber numberWithInt:resp1[1]],
                                                   [NSNumber numberWithInt:resp1[2]],[NSNumber numberWithInt:resp1[3]],
                                                   [NSNumber numberWithInt:resp1[4]],[NSNumber numberWithInt:resp1[5]],
                                                   [NSNumber numberWithInt:resp1[6]],[NSNumber numberWithInt:resp1[7]]];
                            NSArray *respCode2 = @[[NSNumber numberWithInt:resp2[0]],[NSNumber numberWithInt:resp2[1]],
                                                   [NSNumber numberWithInt:resp2[2]],[NSNumber numberWithInt:resp2[3]],
                                                   [NSNumber numberWithInt:resp2[4]],[NSNumber numberWithInt:resp2[5]],
                                                   [NSNumber numberWithInt:resp2[6]],[NSNumber numberWithInt:resp2[7]]];
                            
                            dic = [[[NSMutableDictionary alloc] initWithDictionary:[self resolveReciveInfo:respCode1 :respCode2]] autorelease];
                            
                            char dataLen[4] = {0};
                            for(int i=0,j=0; i < 4; i++)
                            {
                                if(COSData[10+i] == 0x00)
                                {
                                    continue;
                                }
                                dataLen[j] = COSData[10+i];
                                j++;
                            }
                            char *d_len = (char *)calloc(4, sizeof(char));
                            memcpy(d_len, dataLen, 4);
                            int pwdLen = (int)*d_len;
                            char *realData = (char *)calloc(pwdLen, sizeof(char));
                            memcpy(realData, COSData+14, pwdLen);
                            [dic setObject:[NSString stringWithFormat:@"%s",realData] forKey:reciveKey_RecordInfo];
                        }
                        else
                        {
                            dic = [[NSMutableDictionary alloc] init];
                            
                            if (COSData[COS_Data.Length-2] == 0 && COSData[COS_Data.Length-1] == 0x90)
                            {
                                [dic setObject:@"修改成功" forKey:reciveKey_ErrorMessage];
                                [dic setObject:[NSNumber numberWithInt:0] forKey:reciveKey_ResponseCode];
                            }
                            else if(COSData[COS_Data.Length - 1] == 0x63)
                            {
                                [dic setObject:[NSString stringWithFormat:@"PIN码错误，还剩%d次机会",(COSData[COS_Data.Length - 2]-0xc0)]
                                        forKey:reciveKey_ErrorMessage];
                                [dic setObject:[NSNumber numberWithInt:6] forKey:reciveKey_ResponseCode];
                            }
                        }
                        
                        [dic setObject:[NSNumber numberWithInt:STATUS_SUCCESS] forKey:@"return_status"];
                        
                        SetTokenReturnData(dic);
                        COSData = nil;
                    }
                    param.Type   = COS_Data.Status;
                    param.Data   = COS_Data.Data;
                    
                    SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR*)param.Data );
                    
                    
                    if (COS_Data.Data != NULL)
                    {
                        free(COS_Data.Data);
                        COS_Data.Data = NULL;
                    }
                    
                    free(result);
                    result = NULL;
                }
                else
                {
                    param.Status = STATUS_FAILED;
                    param.Type   = COS_Data.Status;
                    param.Data   = COS_Data.Data;
                    printf("%s\n",param.Data);
                    SetReturnData( param.Status, param.Type, COS_Data.Length, (CHAR *)COS_Data.Data );
                    
                    if (COS_Data.Data != NULL)
                    {
                        free(COS_Data.Data);
                        COS_Data.Data = NULL;
                    }
                }
                
                if(isStop)
                {
                    CHAR data[2] = {0};
                    data[0] = 0x66;
                    data[1] = 0x66;
                    SetReturnData(param.Status, param.Type, 2, data);
                }
                
                return param.Status;
            }
            if (COS_Data.Status == ( SHORT )0x9000)
            {
                param.Status = STATUS_SUCCESS;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                
                BYTE *COSData = (BYTE*)calloc(COS_Data.Length, sizeof(BYTE));
                memcpy(COSData, COS_Data.Data, COS_Data.Length);
                for(int i=0; i<COS_Data.Length; i++)
                {
                    printf("%02x ",COSData[i]);
                }
                printf("\n\n");
                
                int resp1[8], resp2[8];
                for(int i=0; i<8; i++)
                {
                    resp1[i] = COS_Data.respCode[0][i];
                    resp2[i] = COS_Data.respCode[1][i];
                }
                NSArray *respCode1 = @[[NSNumber numberWithInt:resp1[0]],[NSNumber numberWithInt:resp1[1]],
                                       [NSNumber numberWithInt:resp1[2]],[NSNumber numberWithInt:resp1[3]],
                                       [NSNumber numberWithInt:resp1[4]],[NSNumber numberWithInt:resp1[5]],
                                       [NSNumber numberWithInt:resp1[6]],[NSNumber numberWithInt:resp1[7]]];
                NSArray *respCode2 = @[[NSNumber numberWithInt:resp2[0]],[NSNumber numberWithInt:resp2[1]],
                                       [NSNumber numberWithInt:resp2[2]],[NSNumber numberWithInt:resp2[3]],
                                       [NSNumber numberWithInt:resp2[4]],[NSNumber numberWithInt:resp2[5]],
                                       [NSNumber numberWithInt:resp2[6]],[NSNumber numberWithInt:resp2[7]]];
                
                NSMutableDictionary *dic = [[[NSMutableDictionary alloc] initWithDictionary:[self resolveReciveInfo:respCode1 :respCode2]]autorelease];
                
                [dic setObject:[NSNumber numberWithInt:STATUS_SUCCESS] forKey:@"return_status"];
                if([dic[reciveKey_ResponseCode] integerValue] == 6)
                {
                    [dic setObject:[NSString stringWithFormat:@"PIN码错误，还剩%d次机会",COSData[0]]
                            forKey:reciveKey_ErrorMessage];
                }
                [dic setObject:[NSString stringWithFormat:@"%s",COS_Data.Data] forKey:reciveKey_RecordInfo];
                
                SetTokenReturnData(dic);
                NSLog(@"success dic = %@",dic);
                COSData = nil;
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
            else if (COS_Data.Status == ( SHORT )0x5566)
            {
                param.Status = STATUS_SUCCESS;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                
                BYTE *COSData = (BYTE*)calloc(COS_Data.Length, sizeof(BYTE));
                memcpy(COSData, COS_Data.Data, COS_Data.Length);
                for(int i=0; i<COS_Data.Length; i++)
                {
                    printf("%02x ",COSData[i]);
                }
                printf("\n\n");
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            [NSNumber numberWithInt:10],reciveKey_ResponseCode,
                                            @"请在key上进行按键操作",reciveKey_ErrorMessage,
                                            [NSNumber numberWithInt:STATUS_SUCCESS],@"return_status", nil];
                SetTokenReturnData(dic);
                NSLog(@"error dic = %@",dic);
                COSData = nil;
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
                
            }
            else
            {
                param.Status = STATUS_SUCCESS;
                param.Type   = COS_Data.Status;
                param.Data   = COS_Data.Data;
                
                BYTE *COSData = (BYTE*)calloc(COS_Data.Length, sizeof(BYTE));
                memcpy(COSData, COS_Data.Data, COS_Data.Length);
                for(int i=0; i<COS_Data.Length; i++)
                {
                    printf("%02x ",COSData[i]);
                }
                printf("\n\n");
                
                int resp1[8], resp2[8];
                for(int i=0; i<8; i++)
                {
                    resp1[i] = COS_Data.respCode[0][i];
                    resp2[i] = COS_Data.respCode[1][i];
                }
                NSArray *respCode1 = @[[NSNumber numberWithInt:resp1[0]],[NSNumber numberWithInt:resp1[1]],
                                       [NSNumber numberWithInt:resp1[2]],[NSNumber numberWithInt:resp1[3]],
                                       [NSNumber numberWithInt:resp1[4]],[NSNumber numberWithInt:resp1[5]],
                                       [NSNumber numberWithInt:resp1[6]],[NSNumber numberWithInt:resp1[7]]];
                NSArray *respCode2 = @[[NSNumber numberWithInt:resp2[0]],[NSNumber numberWithInt:resp2[1]],
                                       [NSNumber numberWithInt:resp2[2]],[NSNumber numberWithInt:resp2[3]],
                                       [NSNumber numberWithInt:resp2[4]],[NSNumber numberWithInt:resp2[5]],
                                       [NSNumber numberWithInt:resp2[6]],[NSNumber numberWithInt:resp2[7]]];
                
                NSMutableDictionary *dic = [[[NSMutableDictionary alloc] initWithDictionary:[self resolveReciveInfo:respCode1 :respCode2]] autorelease];
                
                [dic setObject:[NSNumber numberWithInt:1] forKey:@"return_status"];
                if([dic[reciveKey_ResponseCode] integerValue] == 6)
                {
                    [dic setObject:[NSString stringWithFormat:@"PIN码错误，还剩%d次机会",COSData[0]]
                            forKey:reciveKey_ErrorMessage];
                }
                [dic setObject:[NSString stringWithFormat:@"%s",COS_Data.Data] forKey:reciveKey_RecordInfo];
                
                SetTokenReturnData(dic);
                NSLog(@"error dic = %@",dic);
                COSData = nil;
                
                if (COS_Data.Data != NULL)
                {
                    free(COS_Data.Data);
                    COS_Data.Data = NULL;
                }
            }
        }
        NSLog(@"Send Data End");
        return param.Status;
    }
}

STATUS YH_SendDataToMobileShield( VOID * data, INT len, VOID* obj, VOID * cbf )
{
    DebugAudioLog(@"");
    if(![[CMobileShield shareMobileShield]  audioRoute_IsPlugedIn])
    {
        ResetReturnData();
        return STATUS_FAILED;
    }
    if([AudioRecorder shareAudioRecorder].record)
    {
        return STATUS_FAILED;
    }
    return [[CMobileShield shareMobileShield] YH_SendData:data dataLength:len recObj:obj recCbf:cbf];
}

-(STATUS)YH_ReadData
{
    DebugAudioLog(@"");
	
	INT    nLen    = 0;
	INT totallen=0;
//	INT startindex=0;
//	INT demodLen=0;
//	INT waitlen=0;
//    ULONG buff_Rec = 1024 * 216;
    
	unsigned char *tempbuf = (unsigned char *)calloc(1024*8*6*10, sizeof(unsigned char*));//(1024*512);
    if(tempbuf == NULL)
    {
        DebugAudioLog(@"calloc memery wrong!");
    }
    
	ResetReturnData();
//	if(WAITLEVEL==1)
//    {
//		waitlen=256*1024;
//	}
//	else if(WAITLEVEL==2)
//    {
//        //waitlen=512*1024;
//        waitlen=2000*1024;//640//768
//	}
//    else if(WAITLEVEL==3)
//    {
//        //waitlen=512*1024;
//        waitlen=512*1024;//640//768
//	}
//	else
//	{
//		waitlen=512*1024;
//	}
    
	while ( !m_ReceiveFinish )
    {
        if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
        {
            if([AudioRecorder shareAudioRecorder].recordState.recording)
            {
                [self audioRouteOut];
            }
            break;
        }
        if ([AudioRecorder shareAudioRecorder].recordState.recording == NO)
        {
            [self audioRouteOut];
            break;
        }
        nLen = [[AudioRecorder shareAudioRecorder] getCircleLength];
        
        if (nLen < 8192*2 || nLen == 0)
        {
            continue;
        }
        
//        [[AudioRecorder shareAudioRecorder] getCircleBuffer:tempbuf+totallen length:8192];
//        totallen += [[AudioRecorder shareAudioRecorder] getCircleBuffer:tempbuf+totallen];
        unsigned long len = 0;
        NSData *buf = [[AudioRecorder shareAudioRecorder] getCircle_Length:&len];
        if(!buf)
        {
            continue;
        }
        memcpy(tempbuf+totallen, [buf bytes], len);
        totallen += len;
        
        if (nLen > 0)
        {
//            if (totallen > buff_Rec)
//            {
//                startindex = totallen - buff_Rec;
//                demodLen = (buff_Rec)/2;
//            }
//            else
//            {
//                startindex=0;
//				demodLen=totallen/2;
//            }
            if(tempbuf == NULL)
            {
                totallen = 0;
                continue;
            }
            if (YH_DemoduleAudioData(tempbuf, totallen,tempbuf))
//            if([[newFSKModem shareNewFSKModem] nYH_DemoduleAudioData:tempbuf length:totallen tempBuf:tempbuf])
            {
                DebugAudioLog(@"data received");
                status = STATUS_SUCCESS;
                m_ReceiveData = 1;
                totallen = 0;
//                nLen = 0;
                
                [self audioRouteOut];
            }
            else
            {
                //                if (totallen >= waitlen)
                //                {
                //                    //超时
                //                    DebugAudioLog(@"over time");
                //                    m_ReceiveData = 0;
                //                    if([AudioRecorder shareAudioRecorder].recordState.recording)
                //                    {
                //                        [self audioRouteOut];
                //                    }
                //                }
//                if(totallen > 8000*4)
//                {
//                    totallen = 0;
//                }
            }
            totallen = 0;
        }
    }
    
    
    free(tempbuf);
    tempbuf = NULL;
    if ( m_ReceiveData )
		status = STATUS_SUCCESS;
	else
		status = STATUS_FAILED;
//	nLen = 0;
//	totallen=0;
	return status;
}


+(void)newSetBufferSize:(unsigned long) sizelength
{
    [[AudioRecorder shareAudioRecorder] reloadBufferSize:sizelength];
}

@end

@implementation NSString (CategoryForString_moblie)

-(NSString *)intToFloatWithCentMoney
{
    NSRange pointRange = [self rangeOfString:@"."];
    NSMutableString *newMoney;
    if(pointRange.location == NSNotFound)
    {
        newMoney = [[[NSMutableString alloc] initWithString:self] autorelease];
        [newMoney appendString:@".00"];
        return newMoney;
    }
    else
    {
        return self;
    }
}

-(NSString *)floatToIntWithCentMoney
{
    NSRange pointRange = [self rangeOfString:@"."];
    NSMutableString *newMoney;
    if(pointRange.location == NSNotFound)
    {
        newMoney = [[[NSMutableString alloc] initWithString:self] autorelease];
        [newMoney appendString:@"00"];
    }
    else
    {
        if([[self substringWithRange:NSMakeRange(0, pointRange.location)] isEqualToString:@"0"])
        {
            newMoney = [[[NSMutableString alloc] init]autorelease];
        }
        else
        {
            newMoney = [[[NSMutableString alloc] initWithString:[self substringWithRange:NSMakeRange(0, pointRange.location)]]autorelease];
        }
        [newMoney appendString:[self substringWithRange:NSMakeRange(pointRange.location+1, self.length-pointRange.location-1)]];
        [newMoney appendString:[@"00" substringFromIndex:(self.length-pointRange.location-1)]];
    }
    return newMoney;
}

-(NSString *)FormatMoney
{
    NSString *selfStr = nil;
    for(int i=0; i<self.length; i++)
    {
        if(![[self substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"0"])
        {
            selfStr = [self substringFromIndex:i];
            break;
        }
    }
    if(selfStr == nil)
    {
        return self;
    }
    NSRange rang = [selfStr rangeOfString:@"."];
    NSMutableString *money = [[[NSMutableString alloc]init]autorelease];
    NSString *iMoney;
    if(rang.location == NSNotFound)
    {
        iMoney = [NSString stringWithFormat:@"%@",selfStr];
    }
    else
    {
        iMoney = [NSString stringWithFormat:@"%@", [selfStr substringWithRange:NSMakeRange(0, rang.location)]];
    }
    for(int i=(int)iMoney.length-1,j=0; j<iMoney.length; i--,j++)
    {
        [money insertString:[iMoney substringWithRange:NSMakeRange(i, 1)] atIndex:0];
        if((j+1)%3 == 0 && j+1 < iMoney.length)
        {
            [money insertString:@"," atIndex:0];
        }
    }
    [money insertString:@"￥ " atIndex:0];
    if(rang.location == NSNotFound)
    {
        [money appendString:[NSString stringWithFormat:@".00"]];
    }
    else
    {
        NSMutableString *str = [[NSMutableString alloc]initWithString:[selfStr substringFromIndex:rang.location]];
        if(str.length == 2)
        {
            [str appendString:@"0"];
        }
        [money appendString:[NSString stringWithFormat:@"%@",str]];
        [str release];
    }
    return money;
}

+ (NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

@end