
#ifndef __MOBILE_SHIELD_INTERFACE_H__
#define __MOBILE_SHIELD_INTERFACE_H__


#include "global.h"
#include "MobileShield_Protocol.h"

//#define STRART_FLAG 0xEF


typedef enum
{
    ApiTypeQueryToken = 1 ,             //获取密码器信息
    
    ApiTypeUpdatePin = 3,               //修改PIN码
    
    ApiTypeActiveTokenPlug,             //激活密码器
    
    ApiTypeUnlockRandomNo,              //获取解锁码
    
    ApiTypeUnlockPin,                   //密码器解锁
    
    ApiTypeLcdOpCode = 9,               //LCD显示控制
    
    ApiTypeShowHxTransferInfo,          //汉显GBK
    
    ApiTypeGetTokenCodeSafety = 12,     //获取动态密码
    
    ApiTypeQueryTokenEX = 14,           //获取密码器序列号
    
    ApiTypeQueryVersionHW,              //获取密码器型号
    
    ApiTypeRecordInfo,                  //插入交易信息
    
    ApiTypeQueryInfo,                   //查询交易信息
    
    ApiTypeCancelTrans = 18,                //取消转账功能，或者清屏
    
    ApiTypeShowWallet,                      //显示钱包充值金额
    
    ApiTypeDelayLcd,                        //设置屏背光亮的时间
    
    ApiTypeGetTokenCodeSafety_key,          //新增接口,用户转账时获取动态密码,需要按键确定
    
    ApiTypeScanCode,                        //新增接口,扫码支付 获取动态密码,需要按键确定
    
    ApiTypeFinallyTrans,
    
    ApiTypePowerShow = 101              //显示密码电量
    
}ApiType;


#define NotificationAudioRouteChange    @"Notification-AudioRouteChange"
#define NotificationKeyIsChange         @"NotificationKeyIsChange"

#define reciveKey_ErrorMessage          @"errorMessage"
#define reciveKey_apiTypeCode           @"key_apiType"
#define reciveKey_ResponseCode          @"ResponseCode"
#define reciveKey_PinErrCountNum        @"pinErrCount"
#define reciveKey_upDatePinOkNum        @"updatePinOk"
#define reciveKey_unlockRandomNum       @"unlockRandom"
#define reciveKey_LcdOpStatus           @"LcdOpStatus"
#define reciveKey_powerNum              @"powerNum"
#define reciveKey_HXrespCodeNum         @"HX_RespCode"
#define reciveKey_LastErrorTime         @"lastErrorTime"
#define reciveKey_CalcPassWord          @"calcPassWord"
#define reciveKey_CalcPwdLength         @"calcPasswordLength"
#define reciveKey_ErrorNum              @"errorNumber"
#define reciveKey_TokenSN               @"tokenSNumber"
#define reciveKey_TokenHWVersion        @"tokenHardwareVersion"
#define reciveKey_RecordResultCount     @"recordResultCount"
#define reciveKey_RecordInfo            @"recordInfo"
#define reciveKey_isHxShow              @"isHX"


#ifdef __cplusplus
extern "C" {
#endif
//#ifdef SKF_INTERFACE
#ifndef WIN32
#define DEVAPI
#else
#define DEVAPI  __stdcall
#endif

#define SAR_TIMEOUT                     -1
#define SAR_OK                        0x00000000//≥…π¶
#define SAR_FAIL                      0x0A000001// ß∞‹
#define SAR_UNKNOWNERR                0x0A000002//“Ï≥£¥ÌŒÛ
#define SAR_NOTSUPPORTYETERR          0x0A000003//≤ª÷ß≥÷µƒ∑˛ŒÒ
#define SAR_FILEERR                   0x0A000004//Œƒº˛≤Ÿ◊˜¥ÌŒÛ
#define SAR_INVALIDHANDLEERR          0x0A000005//Œﬁ–ßµƒæ‰±˙
#define SAR_INVALIDPARAMERR           0x0A000006//Œﬁ–ßµƒ≤Œ ˝
#define SAR_READFILEERR               0x0A000007//∂¡Œƒº˛¥ÌŒÛ
#define SAR_WRITEFILEERR              0x0A000008//–¥Œƒº˛¥ÌŒÛ
#define SAR_NAMELENERR                0x0A000009//√˚≥∆≥§∂»¥ÌŒÛ
#define SAR_KEYUSAGEERR               0x0A00000A//√‹‘ø”√Õæ¥ÌŒÛ
#define SAR_MODULUSLENERR             0x0A00000B//ƒ£µƒ≥§∂»¥ÌŒÛ
#define SAR_NOTINITIALIZEERR          0x0A00000C//Œ¥≥ı ºªØ
#define SAR_OBJERR                    0x0A00000D//∂‘œÛ¥ÌŒÛ
#define SAR_MEMORYERR                 0x0A00000E//ƒ⁄¥Ê¥ÌŒÛ
#define SAR_TIMEOUTERR                0x0A00000F//≥¨ ±
#define SAR_INDATALENERR              0x0A000010// ‰»Î ˝æ›≥§∂»¥ÌŒÛ
#define SAR_INDATAERR                 0x0A000011// ‰»Î ˝æ›¥ÌŒÛ
#define SAR_GENRANDERR                0x0A000012//…˙≥…ÀÊª˙ ˝¥ÌŒÛ
#define SAR_HASHOBJERR                0x0A000013//HASH∂‘œÛ¥Ì
#define SAR_HASHERR                   0x0A000014//HASH‘ÀÀ„¥ÌŒÛ
#define SAR_GENRSAKEYERR              0x0A000015//≤˙…˙RSA√‹‘ø¥Ì
#define SAR_RSAMODULUSLENERR          0x0A000016//RSA√‹‘øƒ£≥§¥ÌŒÛ
#define SAR_CSPIMPRTPUBKEYERR         0x0A000017//CSP∑˛ŒÒµº»Îπ´‘ø¥ÌŒÛ
#define SAR_RSAENCERR                 0x0A000018//RSAº”√‹¥ÌŒÛ
#define SAR_RSADECERR                 0x0A000019//RSAΩ‚√‹¥ÌŒÛ
#define SAR_HASHNOTEQUALERR           0x0A00001A//HASH÷µ≤ªœ‡µ»
#define SAR_KEYNOTFOUNTERR            0x0A00001B//√‹‘øŒ¥∑¢œ÷
#define SAR_CERTNOTFOUNTERR           0x0A00001C//÷§ ÈŒ¥∑¢œ÷
#define SAR_NOTEXPORTERR              0x0A00001D//∂‘œÛŒ¥µº≥ˆ
#define SAR_DECRYPTPADERR             0x0A00001E//Ω‚√‹ ±◊ˆ≤π∂°¥ÌŒÛ
#define SAR_MACLENERR                 0x0A00001F//MAC≥§∂»¥ÌŒÛ
#define SAR_BUFFER_TOO_SMALL          0x0A000020//ª∫≥Â«¯≤ª◊„
#define SAR_KEYINFOTYPEERR            0x0A000021//√‹‘ø¿‡–Õ¥ÌŒÛ
#define SAR_NOT_EVENTERR              0x0A000022//Œﬁ ¬º˛¥ÌŒÛ
#define SAR_DEVICE_REMOVED            0x0A000023//…Ë±∏“—“∆≥˝
#define SAR_PIN_INCORRECT             0x0A000024//PIN≤ª’˝»∑
#define SAR_PIN_LOCKED                0x0A000025//PIN±ªÀ¯À¿
#define SAR_PIN_INVALID               0x0A000026//PINŒﬁ–ß
#define SAR_PIN_LEN_RANGE             0x0A000027//PIN≥§∂»¥ÌŒÛ
#define SAR_USER_ALREADY_LOGGED_IN    0x0A000028//”√ªß“—æ≠µ«¬º
#define SAR_USER_PIN_NOT_INITIALIZED  0x0A000029//√ª”–≥ı ºªØ”√ªßø⁄¡Ó
#define SAR_USER_TYPE_INVALID         0x0A00002A//PIN¿‡–Õ¥ÌŒÛ
#define SAR_APPLICATION_NAME_INVALID  0x0A00002B//”¶”√√˚≥∆Œﬁ–ß
#define SAR_APPLICATION_EXISTS        0x0A00002C//”¶”√“—æ≠¥Ê‘⁄
#define SAR_USER_NOT_LOGGED_IN        0x0A00002D//”√ªß√ª”–µ«¬º
#define SAR_APPLICATION_NOT_EXISTS    0x0A00002E//”¶”√≤ª¥Ê‘⁄
#define SAR_FILE_ALREADY_EXIST        0x0A00002F//Œƒº˛“—æ≠¥Ê‘⁄
#define SAR_NO_ROOM                   0x0A000030//ø’º‰≤ª◊„
#define SAR_FILE_NOT_EXIST            0x0A000031//Œƒº˛≤ª¥Ê‘⁄

//--------Key¥Ê∑≈À˜“˝--------------
#define KI_MC        0x00  //÷˜øÿ√‹‘øÀ˘‘⁄µƒÀ˜“˝
#define KI_SOPIN     0x01  //π‹¿Ì‘±PINÀ˘‘⁄µƒÀ˜“˝
#define KI_USERPIN   0x02  //”√ªßPINÀ˘‘⁄µƒÀ˜“˝
#define KI_IA        0x03  //ƒ⁄≤ø—È÷§µƒKEY
#define KI_EA        0x04  //Õ‚≤ø—È÷§µƒKEY
//----------º”√‹À„∑®¿‡–Õ--------------------------------------
#define PKI_RSA      0
#define PKI_SM2      1

#define RANDOM_LEN      8
#define DATA_BLOCK_LEN 16
//#define MAX_RSA_MODULUS_BITS 1024
//#define MAX_RSA_MODULUS_LEN (1024+7)/8
//#define MAX_RSA_PRIM_BITS((1024+1)/8)
typedef int ( * CALLBACK_FUNC )( VOID * obj, VOID * cbf, VOID * param );

#ifndef DEVHANDLE
typedef HANDLE          DEVHANDLE;
#endif
#ifndef HAPPLICATION
typedef HANDLE          HAPPLICATION;
#endif
#ifndef HCONTAINER
typedef HANDLE          HCONTAINER;
#endif

typedef struct _tagAPPLICATION
{
	CHAR szName[32];
	WORD wAppID;
}
APPLICATION, *PAPPLICATION; 

typedef struct _tagCONTAINER
{
	CHAR szName[32];
	WORD wContainerID;
}
CONTAINER, *PCONTAINER;

typedef struct _KEYHANDLE
{
	UINT   lAlgID;
	UINT   KeyID;
	UINT   KeyType;	//0 cipher key , 1 plain key
	CHAR   Key[32];
	bool   lValid;
	HANDLE phDev;
}
KEYHANDLE, *HKEYHANDLE;

typedef struct Struct_cosAPPLICATIONINFO
{
	CHAR  szApplicatinName[32]; //”¶”√√˚≥∆£¨≤ª◊„32 ◊÷Ω⁄ ˝æ›“‘0x00 ≤ª»´
	CHAR  szAdminPin[16];       //π‹¿Ì‘±ø⁄¡Ó£¨≤ª◊„16 ◊÷Ω⁄ ˝æ›“‘0x00 ≤ª»´
	ULONG dwAdminPinRetryCount; //π‹¿Ì‘±ø⁄¡Ó÷ÿ ‘¥Œ ˝
	CHAR  szUserPin[16];        //”√ªßø⁄¡Ó£¨≤ª◊„16 ◊÷Ω⁄ ˝æ›“‘0x00 ≤ª»´
	ULONG dwUserPinRetryCount;  //”√ªßø⁄¡Ó÷ÿ ‘¥Œ ˝
	ULONG dwCreateFileRights;   //‘⁄”¶”√œ¬¥¥Ω®Œƒº˛µƒ»®œﬁ
	BYTE  byContainerNum;       //“™«Û”¶”√÷ß≥÷µƒ»›∆˜ ˝¡ø
	BYTE  byCertNum;            //“™«Û”¶”√÷ß≥÷µƒ÷§ È ˝¡ø
	WORD  wFileNum;             //“™«Û”¶”√÷ß≥÷µƒŒƒº˛ ˝¡ø
}
APPLICATIONINFO, *PAPPLICATIONINFO;

typedef struct _tagREADFILE
{
	WORD wAppID;
	WORD wOffset;
	WORD wFileNameLen;
	CHAR chFileName[40];
}
READFILE, *HREADFILE;

typedef struct _tagWRITEFILE
{
	WORD   wAppID;
	WORD   wOffset;
	WORD   wFileNameLen;
	BYTE   chFileName[40];
	WORD   wDataLen;
}
WRITEFILE, *HWRITEFILE;

typedef struct _tagIMPORTCERTIFICATEBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	BYTE  bCertType;
	ULONG ulCertLen;
	BYTE  pbCert;
}
IMPORTCERTIFICATEBLOB, *PIMPORTCERTIFICATEBLOB;

typedef struct _tagIMPORTRSAKEYPAIRBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulSymAlgID;
	ULONG ulWrappedKeyLen;
	BYTE  pbWrappedKey[64];
	ULONG ulBits;
	ULONG ulEncryptedPriKeyLen;
	BYTE  pbEncryptedData[4*64];
}
IMPORTRSAKEYPAIRBLOB, *PIMPORTRSAKEYPAIRBLOB;

typedef struct _tagRSAEXPORTSESSIONKEY
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulAlgId;
	ULONG BitLen;
	BYTE  Modulus[64];  // Temp
	ULONG PublicExponent;
}
RSAEXPORTSESSIONKEY, *HRSAEXPORTSESSIONKEY;

typedef struct _tagECCKEYPAIR
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulBits;
}
ECCKEYPAIR, *HECCKEYPAIR;
    
typedef struct Struct_ECCCIPHERBLOB
{
//    BYTE XCoordinate[64]; // ”Îy◊È≥…Õ÷‘≤«˙œﬂ…œµƒµ„£®x£¨y£©
//    BYTE YCoordinate[64]; // ”Îx◊È≥…Õ÷‘≤«˙œﬂ…œµƒµ„£®x£¨y£©
//    BYTE Cipher[64];          // √‹Œƒ ˝æ›
//    BYTE Mac[64];             // ‘§¡Ù£¨”√”⁄÷ß≥÷¥¯MACµƒECCÀ„∑®
    ULONG  BitLen; 
	BYTE  XCoordinate[32];   
	BYTE  YCoordinate[32];   
	BYTE  HASH[32];   
	ULONG CipherLen;  
	BYTE  Cipher[16];		
}
ECCCIPHERBLOB, *PECCCIPHERBLOB;

typedef struct Struct_ECCPUBLICKEYBLOB
{
    ULONG AlgID;                                // À„∑®±Í ∂∫≈
    ULONG BitLen;                               // ƒ£ ˝µƒ µº Œª≥§∂»£¨±ÿ–Î «8µƒ±∂ ˝
    BYTE  XCoordinate[64]; // «˙œﬂ…œµ„µƒX◊¯±Í
    BYTE  YCoordinate[64]; // «˙œﬂ…œµ„µƒY◊¯±Í
}
ECCPUBLICKEYBLOB, *PECCPUBLICKEYBLOB;
typedef struct SKF_ENVELOPEDKEYBLOB
{
	ULONG            Version; // µ±«∞∞Ê±æŒ™ 1
	ULONG            ulSymmAlgID; // ”√”⁄º”√‹¥˝µº»ÎECC √‹‘ø∂‘µƒ∂‘≥∆À„∑®±Í ∂£¨œﬁ∂®
						// Œ™≤…”√ECB ƒ£ Ω∂‘√‹‘ø∂‘ ˝æ›Ω¯––º”√‹
	ULONG            ulBits; // ¥˝µº»Îº”√‹√‹‘ø∂‘µƒ√‹‘øŒª≥§∂»
	BYTE             cbEncryptedPriKey[64]; // ¥˝µº»Îº”√‹√‹‘ø∂‘ÀΩ‘øµƒ√‹Œƒ
	ECCPUBLICKEYBLOB PubKey; // ¥˝µº»Îº”√‹√‹‘ø∂‘µƒπ´‘ø
	ECCCIPHERBLOB    ECCCipherBlob; // ”√±£ª§π´‘øº”√‹µƒ∂‘≥∆√‹‘ø√‹Œƒ
}
ENVELOPEDKEYBLOB, *PENVELOPEDKEYBLOB;

//  ˝◊È≥§∂»∫Í∂®“Â–Ë“™»∑»œ
typedef struct _tagIMPORTECCKEYPAIR
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG Version;
	ULONG ulSymmAlgID;
	ULONG ulBits;
	ULONG ulEncryptedPriKeyLen;
	BYTE  cbEncryptedPriKey[64];
	BYTE  importedXCoordinate[64];
	BYTE  importedYCoordinate[64];
	ULONG ulProtectKeyBits;
	BYTE  ProtectKeyXCoordinate[64];
	BYTE  ProtectKeyYCoordinate[64];
	BYTE  HASH[64];
	ULONG CipherLen;
	BYTE  Cipher[64];
}
IMPORTECCKEYPAIR, *PIMPORTECCKEYPAIR;

typedef struct _tagECCVERIFY
{
	ULONG ulBits;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	ULONG ulDataLen;
	BYTE  pbData[64];
	BYTE  r[64];
	BYTE  s[64];
}
ECCVERIFY, *PECCVERIFY;

typedef struct _tagECCEXPORTSESSIONKEY
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulBits;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	ULONG ulAlgId;
}
ECCEXPORTSESSIONKEY, *PECCEXPORTSESSIONKEY;

typedef struct _tagEXTECCENCRYPT
{
	ULONG ulBits;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	ULONG ulPlainTextLen;
	BYTE  pbPlainText[64];
}
EXTECCENCRYPT, *PEXTECCENCRYPT;

typedef struct _tagEXTECCDECRYPT
{
	ULONG BitLen;
	BYTE  PrivateKey[64];
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	BYTE  HASH[64];
	ULONG CipherLen;
	BYTE  Cipher[64];
}
EXTECCDECRYPT, *PEXTECCDECRYPT;

typedef struct _tagEXTECCSIGN
{
	ULONG BitLen;
	BYTE  PrivateKey[64];
	ULONG ulPlainTextLen;
	BYTE  pbPlainText[64];
}
EXTECCSIGN, *PEXTECCSIGN;

typedef struct _tagGENERATEAGREEMENTDATAWITHECCBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulAlgId;
	ULONG ulIDLen;
	BYTE  pbID[256]; // ulIDLen
}
GENERATEAGREEMENTDATAWITHECCBLOB, *PGENERATEAGREEMENTDATAWITHECCBLOB;

typedef struct _tagGENERATEAGREEMENTDATAANDKEYWITHECCBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulAlgId;
	ULONG ulSponsorBits;
	BYTE  SponsorXCoordinate[256];
	BYTE  SponsorYCoordinate[256];
	ULONG ulSponsorTempBits;
	BYTE  SponsorTempXCoordinate[64];
	BYTE  SponsorTempYCoordinate[64];
	ULONG ulSponsorIDLen;
	BYTE  pbSponsorID[64];
	ULONG ulIDLen;
	BYTE  pbID[64];
}
GENERATEAGREEMENTDATAANDKEYWITHECCBLOB, *PGENERATEAGREEMENTDATAANDKEYWITHECCBLOB;

typedef struct _tagGENERATEKEYWITHECCBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG hAgreementHandle;
	ULONG ulResponserBits;
	BYTE  ResponserXCoordinate[64];
	BYTE  ResponserYCoordinate[64];
	ULONG ulResponserTempBits;
	BYTE  ResponserTempXCoordinate[64];
	BYTE  ResponserTempYCoordinate[64];
	ULONG ulResponserIDLen;
	BYTE  pbResponserID[256];
}
GENERATEKEYWITHECCBLOB, *PGENERATEKEYWITHECCBLOB;

typedef struct _tagEXPORTPUBLICKEYBLOB
{
	WORD wAppID;
	WORD wContainerID;
}
EXPORTPUBLICKEYBLOB, *PEXPORTPUBLICKEYBLOB;

typedef struct _tagIMPORTSESSIONKEYBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	ULONG ulAlgID;
	ULONG ulWrapedLen;
	BYTE  pbWrapedData[256];
}
IMPORTSESSIONKEYBLOB, *PIMPORTSESSIONKEYBLOB;

typedef struct _tagIMPORTSYMMKEYBLOB
{
	BYTE  wAppID[2];
	BYTE  wContainerID[2];
	ULONG ulAlgID;
	WORD  wSymKeyLen;
	BYTE  pbSymKey[64];
}
IMPORTSYMMKEYBLOB, *PIMPORTSYMMKEYBLOB;

typedef struct _tagENCRYPTINITBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	WORD  wKeyID;
	ULONG AlgID;
	WORD  IVLen;
	BYTE  IV[64];
	ULONG PaddingType;
	ULONG FeedBitLen;
}
ENCRYPTINITBLOB, *PENCRYPTINITBLOB;

typedef struct _tagDECRYPTINITBLOB
{
	WORD  wAppID;
	WORD  wContainerID;
	WORD  wKeyID;
	WORD  IVLen;
	BYTE  IV[64];
	ULONG PaddingType;
	ULONG FeedBitLen;
}
DECRYPTINITBLOB, *PDECRYPTINITBLOB;

typedef struct _tagDIGESTINITBLOB
{
	ULONG BitLen;
	BYTE  PrivateKey[64];
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	ULONG ulIDLen;
	BYTE  pucID[64];
}
DIGESTINITBLOB, *PDIGESTINITBLOB;

typedef struct _tagMACINIT
{
	WORD  wAppID;
	WORD  wContainerID;
	WORD  wKeyID;
	ULONG AlgID;
	WORD  IVLen;
	BYTE  IV[64];
	ULONG PaddingType;
	ULONG FeedBitLen;
}
MACINIT, *PMACINIT;
typedef struct _VERSION//∞Ê±æ 
{
    BYTE major;
    BYTE minor;
}VERSION;
/********** œÏ”¶±®Œƒ ˝æ›”Úµƒ ˝æ›Ω·ππ  **********/
typedef struct _tagDEVINFO
{
	VERSION StructVersion;
	VERSION SpecificationVersion;
	CHAR    Manufacturer[64];
	CHAR    Issuer[64];
	CHAR    Label[32];
	CHAR    SerialNumber[32];
	VERSION HWVersion;
	VERSION FirmwareVersion;
	ULONG   AlgSymCap;
	ULONG   AlgAsymCap;
	ULONG   AlgHashCap;
	ULONG   DevAuthAlgId;
	ULONG   TotalSpace;
	ULONG   FreeSpace;
	WORD    MaxApduDataLen;
	WORD    UserAuthMethod;
	WORD    DeviceType;
	BYTE    MaxContainerNum;
	BYTE    MaxCertNum;
	WORD    MaxFileNum;
	BYTE    Reserved[54];
}
DEVINFO, *PDEVINFO;

typedef struct _tagOPENAPPLICATION
{
	ULONG dwCreateFileRights;  // ‘⁄∏√”¶”√œ¬¥¥Ω®Œƒº˛∫Õ»›∆˜µƒ»®œﬁ
	BYTE  byMaxContainerNum;   // µ±«∞”¶”√ø…÷ß≥÷µƒ◊Ó¥Û»›∆˜ ˝¡ø
	BYTE  byMaxCertNum;        // µ±«∞”¶”√ø…÷ß≥÷µƒ◊Ó¥Û÷§ È ˝¡ø
	WORD  wMaxFileNum;         // µ±«∞”¶”√ø…÷ß≥÷µƒ◊Ó¥ÛŒƒº˛ ˝¡ø
	WORD  wAppID;              // ∑µªÿµƒ”¶”√ID£¨”√”⁄±Í ∂“—¥Úø™µƒ”¶”√£¨∫Û–¯≤Ÿ◊˜ø…Õ®π˝¥ÀID “˝”√¥Úø™µƒ”¶”√°£
}
OPENAPPLICATION, *POPENAPPLICATION;

typedef struct _tagGETFILEINFO
{
	ULONG FileSize;
	ULONG ReadRights;
	ULONG WriteRights;
}
GETFILEINFO, *PGETFILEINFO;

typedef struct _tagCONTAINERINFO
{
	BYTE  ContainerType;
	ULONG ulSignKeyLen;
	ULONG ulExchgKeyLen;
	BYTE  bSignCertFlag;
	BYTE  bExchgCertFlag;
}
CONTAINERINFO, *PCONTAINERINFO;

typedef struct _tagEXTECCENCRYPTINFO
{
	ULONG ulBits;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	BYTE  HASH[64];
	ULONG CipherLen;
	BYTE  Cipher[64];
}
EXTECCENCRYPTINFO, *PEXTECCENCRYPTINFO;

typedef struct _tagECCDECRYPTINFO
{
	ULONG ulPlainTextLen;
	BYTE  pbPlainText[64];
}
ECCDECRYPTINFO, *PECCDECRYPTINFO;

typedef struct _tagEXTECCSIGNINFO
{
	BYTE r[64];
	BYTE s[64];
}
EXTECCSIGNINFO, *PEXTECCSIGNINFO;

typedef struct _tagGENERATEAGREEMENTDATAWITHECCINFO
{
	ULONG ulBits;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	ULONG hAgreementHandle;
}
GENERATEAGREEMENTDATAWITHECCINFO, *PGENERATEAGREEMENTDATAWITHECCINFO;

typedef struct _tagGENERATEAGREEMENTDATAANDKEYWITHECCINFO
{
	ULONG ulBits;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
	ULONG hSessionKeyID;
}
GENERATEAGREEMENTDATAANDKEYWITHECCINFO, *PGENERATEAGREEMENTDATAANDKEYWITHECCINFO;

typedef struct _tagEXPORTPUBLICKEYINFO
{
	ULONG BitLen;
	BYTE  XCoordinate[64];
	BYTE  YCoordinate[64];
}
EXPORTPUBLICKEYINFO, *PEXPORTPUBLICKEYINFO;

/************************************************************/

/*************  …Ë±∏π‹¿Ì**************/
ULONG DEVAPI SKF_SetLabel( DEVHANDLE hDev, LPSTR szLabel );
ULONG DEVAPI SKF_GetDevInfo( DEVHANDLE hDev, DEVINFO * pDevInfo );
ULONG DEVAPI SKF_Transmit(
	DEVHANDLE hDev,
	BYTE    * pbCommand,
	ULONG     ulCommandLen,
	BYTE    * pbData,
	ULONG   * pulDataLen );
ULONG DEVAPI SKF_TransmitEx(
	DEVHANDLE hDev,
	BYTE    * pbData,
	ULONG     ulDataLen );
/*****************************************/

/*************  ∑√Œ øÿ÷∆**************/
ULONG DEVAPI SKF_DevAuth(
	DEVHANDLE hDev,
	BYTE    * pbAuthData,
	ULONG     ulLen );
ULONG DEVAPI SKF_ChangeDevAuthKey(
	DEVHANDLE hDev,
	BYTE    * pbKeyValue,
	ULONG     ulKeyLen );
ULONG DEVAPI SKF_GetPINInfo(
	HAPPLICATION hApplication,
	ULONG        ulPINType,
	ULONG      * pulMaxRetryCount,
	ULONG      * pulRemainRetryCount,
	bool       * pbDefaultPin );
ULONG DEVAPI SKF_ChangePIN(
	HAPPLICATION hApplication,
	ULONG        ulPINType,
	LPSTR        szOldPin,
	LPSTR        szNewPin,
	ULONG      * pulRetryCount );
ULONG DEVAPI SKF_VerifyPIN(
	HAPPLICATION hApplication,
	ULONG        ulPINType,
	LPSTR        szPIN,
	ULONG      * pulRetryCount );
ULONG DEVAPI SKF_UnblockPIN(
	HAPPLICATION hApplication,
	LPSTR        szAdminPIN,
	LPSTR        szNewUserPIN,
	ULONG      * pulRetryCount );
ULONG DEVAPI SKF_ClearSecureState( HAPPLICATION hApplication );
/*****************************************/

/*************  ”¶”√π‹¿Ì**************/
ULONG DEVAPI SKF_CreateApplication( 
	DEVHANDLE      hDev,
	LPSTR          szAppName,
	LPSTR          szAdminPin,
	DWORD          dwAdminPinRetryCount,
	LPSTR          szUserPin,
	DWORD          dwUserPinRetryCount,
	DWORD          dwCreateFileRights,
	HAPPLICATION * phApplication );
ULONG DEVAPI SKF_EnumApplication(
	DEVHANDLE hDev,
	LPSTR     szAppName,
	ULONG   * pulSize );
ULONG DEVAPI SKF_DeleteApplication( DEVHANDLE hDev, LPSTR szAppName );
ULONG DEVAPI SKF_OpenApplication(
	DEVHANDLE      hDev,
	LPSTR          szAppName,
	HAPPLICATION * phApplication );
ULONG DEVAPI SKF_CloseApplication( HAPPLICATION hApplication );
/*****************************************/

/*************  Œƒº˛π‹¿Ì**************/
ULONG DEVAPI SKF_CreateFile(
	HAPPLICATION hApplication,
	LPSTR        szFileName,
	ULONG        ulFileSize,
	ULONG        ulReadRights,
	ULONG        ulWriteRights );
ULONG DEVAPI SKF_DeleteFile( HAPPLICATION hApplication, LPSTR szFileName );
ULONG DEVAPI SKF_EnumFiles(
	HAPPLICATION hApplication,
	LPSTR        szFileList,
	ULONG      * pulSize );
ULONG DEVAPI SKF_GetFileInfo(
	HAPPLICATION    hApplication,
	LPSTR           szFileName,
	FILEATTRIBUTE * pFileInfo );
ULONG DEVAPI SKF_ReadFile(
	HAPPLICATION hApplication,
	LPSTR        szFileName,
	ULONG        ulOffset,
	ULONG        ulSize,
	BYTE       * pbOutData,
	ULONG      * pulOutLen );
ULONG DEVAPI SKF_WriteFile(
	HAPPLICATION hApplication,
	LPSTR        szFileName,
	ULONG        ulOffset,
	BYTE       * pbData,
	ULONG        ulSize );
/*****************************************/

/*************  »›∆˜π‹¿Ì**************/
ULONG DEVAPI SKF_CreateContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName,
	HCONTAINER * phContainer );
ULONG DEVAPI SKF_OpenContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName,
	HCONTAINER * phContainer );
ULONG DEVAPI SKF_CloseContainer( HCONTAINER hContainer );
ULONG DEVAPI SKF_EnumContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName,
	ULONG      * pulSize );
ULONG DEVAPI SKF_DeleteContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName );
ULONG DEVAPI SKF_GetContainerInfo(
	HAPPLICATION    hApplication,
	LPSTR           szContainerName,
	CONTAINERINFO * pFileInfo );
ULONG DEVAPI SKF_ImportCertificate(
	HAPPLICATION hApplication,
	BYTE         bCertificate,
	BYTE       * pbData,
	ULONG        ulDataLen );
ULONG DEVAPI SKF_ExportCertificate(
	HAPPLICATION hApplication,
	ULONG        ulExportType,
	ULONG      * ulRetDataLen,
	BYTE       * pbRetData );
/*****************************************/

/*************  √‹¬Î∑˛ŒÒ**************/
ULONG DEVAPI SKF_GenRandom(
	DEVHANDLE hDev,
	BYTE    * pbRandom,
	ULONG     ulRandomLen );
//#ifdef RSA_INTERFACE
ULONG DEVAPI SKF_GenExtRSAKey(
	DEVHANDLE           hDev,
	ULONG               ulBitsLen,
	RSAPRIVATEKEYBLOB * pBlob );
ULONG DEVAPI SKF_GenRSAKeyPair(
	HCONTAINER hContainer,
	ULONG ulBitsLen,
	RSAPUBLICKEYBLOB *pBlob );
ULONG DEVAPI SKF_ImportRSAKeyPair(
	HCONTAINER hContainer,
	ULONG      ulSymAlgId,
	BYTE     * pbWrappedKey,
	ULONG      ulWrappedKeyLen,
	BYTE     * pbEncryptedData,
	ULONG      ulEncryptedDataLen );
ULONG DEVAPI SKF_RSASignData(
	HCONTAINER hContainer,
	BYTE     * pbData,
	ULONG      ulDataLen,
	BYTE     * pbSignature,
	ULONG    * pulSignLen,
    LPSTR        szPIN,
    UINT       CertFlag);
ULONG DEVAPI SKF_RSAVerify(
	RSAPUBLICKEYBLOB * pRSAPubKeyBlob,
	BYTE             * pbData,
	ULONG              ulDataLen,
	BYTE             * pbSignature,
	ULONG              ulSignLen );
ULONG DEVAPI SKF_RSAExportSessionKey(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	RSAPUBLICKEYBLOB * pPubKey,
	BYTE             * pbData,
	ULONG            * pulDataLen,
	HANDLE           * phSessionKey );
    
ULONG DEVAPI SKF_RSAExportSessionKey_2048(
                                         HCONTAINER         hContainer,
                                         ULONG              ulAlgId,
                                         RSAPUBLICKEYBLOB * pPubKey,
                                         BYTE             * pbData,
                                         ULONG            * pulDataLen,
                                         HANDLE           * phSessionKey );
ULONG DEVAPI SKF_ExtRSAPubKeyOperation(
	DEVHANDLE          hDev,
	RSAPUBLICKEYBLOB * pRSAPubKeyBlob,
	BYTE             * pbInput,
	ULONG              ulInputLen,
	BYTE             * pbOutput,
	ULONG            * pulOutputLen );
ULONG DEVAPI SKF_DestroySessionKey(HCONTAINER hContainer,BYTE *pKeyId,INT keyIdLen);   
    

ULONG DEVAPI SKF_ExtRSAPriKeyOperation(
	DEVHANDLE           hDev,
	RSAPRIVATEKEYBLOB * pRSAPriKeyBlob,
	BYTE              * pbInput,
	ULONG               ulInputLen,
	BYTE              * pbOutput,
	ULONG             * pulOutputLen );
////#endif
//ULONG DEVAPI SKF_ExtRSAPubKeyOperation(
//    DEVHANDLE          hDev,
//    RSAPUBLICKEYBLOB * pRSAPubKeyBlob,
//    BYTE             * pbInput,
//    ULONG              ulInputLen,
//    BYTE             * pbOutput,
//    ULONG            * pulOutputLen );
typedef struct Struct_ECCSIGNATUREBLOB
{
    BYTE r[64];  // «©√˚Ω·π˚µƒr≤ø∑÷
    BYTE s[64];  // «©√˚Ω·π˚µƒs≤ø∑÷
}
ECCSIGNATUREBLOB, *PECCSIGNATUREBLOB;
    
typedef struct Struct_ECCPRIVATEKEYBLOB
{
    ULONG AlgID;                                  // À„∑®±Í ∂∫≈
    ULONG BitLen;                                 // ƒ£ ˝µƒ µº Œª≥§∂»
    BYTE  PrivateKey[64];        // ÀΩ”–√‹‘ø
}
ECCPRIVATEKEYBLOB, *PECCPRIVATEKEYBLOB;
typedef struct Struct_BLOCKCIPHERPARAM
{
    BYTE  IV[32];  // ≥ı ºœÚ¡ø
    ULONG IVLen;           // ≥ı ºœÚ¡ø µº ≥§∂»£®∞¥◊÷Ω⁄º∆À„£©
    ULONG PaddingType;     // ÃÓ≥‰∑Ω Ω£¨0±Ì æ≤ªÃÓ≥‰£¨1±Ì æ∞¥’’PKCS#5∑Ω ΩΩ¯––ÃÓ≥‰
    ULONG FeedBitLen;      // ∑¥¿°÷µµƒŒª≥§∂»£®∞¥Œªº∆À„£©£¨÷ª’Î∂‘OFB°¢CFBƒ£ Ω
}
    BLOCKCIPHERPARAM, *PBLOCKCIPHERPARAM;
ULONG DEVAPI SKF_GenECCKeyPair(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pBlob );
ULONG DEVAPI SKF_ImportECCKeyPair(
	HCONTAINER hContainer,
	ULONG      ulSymAlgId,
	BYTE     * pbWrappedKey,
	ULONG      ulWrappedKeyLen,
	BYTE     * pbEncryptedData,
	ULONG      ulEncryptedDataLen );
ULONG DEVAPI SKF_ECCSignData(
	HCONTAINER        hContainer,
	BYTE            * pbData,
	ULONG             ulDataLen,
	PECCSIGNATUREBLOB pSignature );
ULONG DEVAPI SKF_ECCVerify(
	DEVHANDLE          hDev,
	ECCPUBLICKEYBLOB * pECCPubKeyBlob,
	BYTE             * pbData,
	ULONG              ulDataLen,
	PECCSIGNATUREBLOB  pSignature );
ULONG DEVAPI SKF_ECCExportSessionKey(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pPubKey,
	PECCCIPHERBLOB     pData,
	HANDLE           * phSessionKey );
ULONG DEVAPI SKF_ExtECCEncrypt(
	DEVHANDLE          hDev,
	ECCPUBLICKEYBLOB * pECCPubKeyBlob,
	BYTE             * pbPlainText,
	ULONG              ulPlainTextLen,
	PECCCIPHERBLOB     pCipherText );
ULONG DEVAPI SKF_ExtECCDecrypt(
	DEVHANDLE           hDev,
	ECCPRIVATEKEYBLOB * pECCPriKeyBlob,
	PECCCIPHERBLOB      pCipherText,
	BYTE              * pbPlainText,
	ULONG             * pulPlainTextLen );
ULONG DEVAPI SKF_ExtECCSign(
	DEVHANDLE           hDev,
	ECCPRIVATEKEYBLOB * pECCPriKeyBlob,
	BYTE              * pbData,
	ULONG               ulDataLen,
	PECCSIGNATUREBLOB   pSignature );
ULONG DEVAPI SKF_GenerateAgreementDataWithECC(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pTempECCPubKeyBlob,
	BYTE             * pbID,
	ULONG              ulIDLen,
	HANDLE           * phAgreementHandle );
ULONG DEVAPI SKF_GenerateAgreementDataAndKeyWithECC(
	HANDLE             hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pSponsorECCPubKeyBlob,
	ECCPUBLICKEYBLOB * pSponsorTempECCPubKeyBlob,
	ECCPUBLICKEYBLOB * pTempECCPubKeyBlob,
	BYTE             * pbID,
	ULONG              ulIDLen,
	BYTE             * pbSponsorID,
	ULONG              ulSponsorIDLen,
	HANDLE           * phKeyHandle );
ULONG DEVAPI SKF_GenerateKeyWithECC(
	HANDLE             hAgreementHandle,
	ECCPUBLICKEYBLOB * pECCPubKeyBlob,
	ECCPUBLICKEYBLOB * pTempECCPubKeyBlob,
	BYTE             * pbID,
	ULONG              ulIDLen,
	HANDLE           * phKeyHandle );
ULONG DEVAPI SKF_ExportPublicKey(
	HCONTAINER hContainer,
	bool       bSignFlag,
	BYTE     * pbBlob,
	ULONG    * pulBlobLen );
ULONG DEVAPI SKF_ImportSessionKey(
	HCONTAINER hContainer,
	ULONG      ulAlgId,
	BYTE     * pbWrapedData,
	ULONG      ulWrapedLen,
	HANDLE   * phKey );
ULONG DEVAPI SKF_SetSymmKey(
	DEVHANDLE hDev,
	BYTE    * pbKey,
	ULONG     ulAlgID,
	HANDLE  * phKey );
ULONG DEVAPI SKF_EncryptInit( HANDLE hKey, BLOCKCIPHERPARAM EncryptParam );
ULONG DEVAPI SKF_Encrypt(
	HANDLE  hKey,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbEncryptedData,
	ULONG * pulEncryptedLen );
ULONG DEVAPI SKF_EncryptUpdate(
	HANDLE  hKey,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbEncryptedData,
	ULONG * pulEncryptedLen );
ULONG DEVAPI SKF_EncryptFinal(
	HANDLE  hKey,
	BYTE  * pbEncryptedData,
	ULONG * ulEncryptedDataLen );
ULONG DEVAPI SKF_DecryptInit(
	HANDLE           hKey,
	BLOCKCIPHERPARAM DecryptParam );
ULONG DEVAPI SKF_Decrypt(
	HANDLE   hKey,
	BYTE   * pbEncryptedData,
	ULONG    ulEncryptedLen,
	BYTE   * pbData,
	ULONG  * pulDataLen );
ULONG DEVAPI SKF_DecryptUpdate(
	HANDLE   hKey,
	BYTE   * pbEncryptedData,
	ULONG    ulEncryptedLen,
	BYTE   * pbData,
	ULONG  * pulDataLen );
ULONG DEVAPI SKF_DecryptFinal(
	HANDLE  hKey,
	BYTE  * pbDecryptedData,
	ULONG * pulDecryptedDataLen );
ULONG DEVAPI SKF_DigestInit(
	DEVHANDLE  hDev,
	ULONG      ulAlgID,
	HANDLE   * phHash );
ULONG DEVAPI SKF_Digest(
	HANDLE  hHash,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbHashData,
	ULONG * pulHashLen );
ULONG DEVAPI SKF_DigestUpdate(
	HANDLE hHash,
	BYTE * pbData,
	ULONG  ulDataLen );
ULONG DEVAPI SKF_DigestFinal(
	HANDLE  hHash,
	BYTE  * pHashData,
	ULONG * pulHashLen );
ULONG DEVAPI SKF_MacInit(
	HANDLE             hKey,
	BLOCKCIPHERPARAM * pMacParam,
	HANDLE           * phMac );
ULONG DEVAPI SKF_Mac(
	HANDLE  hMac,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbMacData,
	ULONG * pulMacLen );
ULONG DEVAPI SKF_MacUpdate(
	HANDLE hMac,
	BYTE * pbData,
	ULONG  ulDataLen );
ULONG DEVAPI SKF_MacFinal(
	HANDLE  hMac,
	BYTE  * pbMacData,
	ULONG * pulMacDataLen );
ULONG DEVAPI SKF_CloseHandle( HANDLE hHandle );
//0是临时锁定,1是永久锁定
ULONG DEVAPI SKF_BlockApplication(
	HAPPLICATION hApplication,
	ULONG ulBlockType );

ULONG DEVAPI SKF_UnblockApplication(
	HAPPLICATION hApplication );

ULONG DEVAPI SKF_BlockCard(
	HANDLE hDev );

ULONG DEVAPI SKF_InternalAuthentication(
	HANDLE hDev,
	BYTE * pbRandom,
	ULONG  ulRandomLen );
/*****************************************/
ULONG DEVAPI SKF_UnBlockCard();
ULONG DEVAPI SKF_InitCard();
ULONG DEVAPI SKF_LockDev( DEVHANDLE hDev, ULONG ulTimeOut );
ULONG DEVAPI SKF_UnlockDev( DEVHANDLE hDev );
    
PAPPLICATION  GetApplication();
VOID          SetApplication( APPLICATION application );
VOID          ClearApplication();
PCONTAINER    GetContainer();
VOID          SetContainer( CONTAINER container );
VOID          ClearContainer();
CHAR        * GetEA();
VOID          SetEA( CHAR * ea, INT len );
VOID          ClearEA();
//VOID          SetEnv( JNIEnv * env );
//JNIEnv      * GetEnv();
VOID          SetCbf( CHAR * cbf );
CHAR        * GetCbf();
VOID          ClearEnvAndCbf();
CALLBACK_FUNC GetCallbackFun();
VOID          ResetCallFun();
VOID          SetGeneralHandleProc();

#ifdef MOBILE_SHIELD_TOKEN
ULONG DEVAPI SKF_ReadTokenNum();
ULONG DEVAPI SKF_SetCalcEq( BYTE * pData, UINT nLen );
ULONG DEVAPI SKF_ReadEquipmentNum();
ULONG DEVAPI SKF_GeneratePermitCode( BYTE * pData, UINT nLen );
#endif
//#ifdef MOBILE_SHIELD_SHOW
ULONG DEVAPI SKF_TransmitContent( BYTE * pData, UINT nLen );
ULONG DEVAPI SKF_ReadStatus(int p1);
ULONG DEVAPI SKF_HandShakeS(DEVHANDLE hDev);
    ULONG DEVAPI SKF_ImportRSAKeyPair_2048(
                                      HCONTAINER hContainer,
                                      ULONG      ulSymAlgId,
                                      BYTE     * pbWrappedKey,
                                      ULONG      ulWrappedKeyLen,
                                      BYTE     * pbEncryptedData,
                                      ULONG      ulEncryptedDataLen );    
//#endif

//#endif
    
//++++++++++++++*******************集成接口
#pragma mark -
#pragma mark -
#pragma mark - ************************
#pragma mark - 集成接口
    int GenRandom();
    
    bool auth_keyDevice();
    
    int open_Application();
    
    NSArray *enum_container();
    
    NSDictionary * open_contain(NSString *containerName);
    
    BOOL VerifyPinCode(NSString *pin);
    
    NSData * HASHInit(NSString *inStr);
    
    NSData * RSASignData(NSString *pin, NSData *signData);
    
    NSDictionary * changePinCode(NSString *oldPin, NSString *newPin);
    
    NSDictionary * unlockPinCode(NSString *oldPin, NSString *AdminPin, NSString *newUserPin);
    
    BOOL audioRouteIsPlugedIn();
    
#pragma mark - 6100 token interface
    
    NSString * InterceptionFormatPayeeName(NSString *name);
    
    NSDictionary * token_QueueTokenEX();
    
    NSDictionary * token_ActiveTokenPlug(NSString *tokenSN, NSString *activeCode);
    
    NSDictionary * token_UnlockRandomNo(NSString *tokenSN);
    
    NSDictionary * token_UnlockPin(NSString *tokenSN, NSString *unlockCode);
    
    NSDictionary * token_UpdatePin(NSString *tokenSN, NSString *oldPin, NSString *newPin);
    
    NSDictionary * token_GetTokenCodeSafety(NSString *tokenSN, int audioPortPos,
                                            NSString *pin, NSString *utctime,
                                            NSString *verify, NSString *ccountNo,
                                            NSString * money, NSString *name, int currency);
    
    NSDictionary * token_GetTokenCodeSafety_key(NSString *tokenSN, int audioPortPos,
                                                NSString *pin, NSString *utctime,
                                                NSString *verify, NSString *ccountNo,
                                                NSString * money, NSString *name, int currency);
    
    NSDictionary * token_ScanCode(NSString *tokenSN, int audioPortPos,
                                  NSString *pin, NSString *utctime,
                                  NSString *verify, NSString *ccountNo,
                                  NSString * money, NSString *name, int currency);
    
    NSDictionary * startRecordButtonAction();
    NSDictionary * startRecordButtonActionWithType(ApiType type);
    
    void stopAudioSession();
    
    BOOL token_CancelTrans();
    
    
    NSDictionary * token_new_GetTokenCodeSafety(NSString *tokenSN, int audioPortPos,
                                                NSString *pin, NSString *utctime,
                                                NSString *verify, NSString *ccountNo,
                                                NSString * money, NSString *name, int currency);
    
    NSDictionary * token_new_GetTokenCodeSafety_key(NSString *tokenSN, int audioPortPos,
                                                    NSString *pin, NSString *utctime,
                                                    NSString *verify, NSString *ccountNo,
                                                    NSString * money, NSString *name, int currency);
    
    
    int MyOpenFile();
    int check_cert();
    NSArray *readLocalFile();
    
    NSInteger newRSASignData(NSString *pin, NSData *signData);
    NSData * waitRSASignData(NSInteger length);
    
    //++++++++++ by zhangjian 20141010 10:00
    NSDictionary * GetPinInfo(int pType);
    NSInteger newECCSignData(NSString *pin, NSData *signData, NSInteger p1);
    
    //+++++++++++ by zhangjian 20141011 11:35
    NSArray * newRSASignDataByRandom(NSString *pin, NSData *signData, NSData *random);
    NSArray * newECCSignDataByRandom(NSString *pin, NSData *signData, NSInteger p1, NSData *random);
    NSData * GetRandom();
    
    //+++++++++++ by zhangjian 20151022 15:50
    NSString *getICCardNum();
    BOOL SufficientMoney(NSString *money);
    
#ifdef __cplusplus
}
#endif

#endif

