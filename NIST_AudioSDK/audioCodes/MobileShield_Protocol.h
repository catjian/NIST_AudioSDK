
#ifndef __MOBILE_SHIELD_PROTOCOL_H__
#define __MOBILE_SHIELD_PROTOCOL_H__

#include "global.h"


#define L_BYTE( n ) ( BYTE )( n & 0x000000FF )
#define H_BYTE( n ) ( BYTE )( ( n >> 8 ) & 0x000000FF )

#ifdef __cplusplus
extern "C" {
#endif

//#ifdef SKF_INTERFACE

/*******************分组密码算法标识*****************/
#define SGD_SM1_ECB      0x00000101 // SM1   算法ECB 加密模式
#define SGD_SM1_CBC      0x00000102 // SM1   算法CBC 加密模式
#define SGD_SM1_CFB      0x00000104 // SM1   算法CFB 加密模式
#define SGD_SM1_OFB      0x00000108 // SM1   算法OFB 加密模式
#define SGD_SM1_MAC      0x00000110 // SM1   算法MAC 运算
#define SGD_SSF33_ECB    0x00000201 // SSF33算法ECB 加密模式
#define SGD_SSF33_CBC    0x00000202 // SSF33算法CBC加密模式
#define SGD_SSF33_CFB    0x00000204 // SSF33算法CFB加密模式
#define SGD_SSF33_OFB    0x00000208 // SSF33算法OFB加密模式
#define SGD_SSF33_MAC    0x00000210 // SSF33算法MAC运算
#define SGD_SMS4_ECB     0x00000401 // SMS4 算法ECB加密模式
#define SGD_SMS4_CBC     0x00000402 // SMS4 算法CBC加密模式
#define SGD_SMS4_CFB     0x00000404 // SMS4 算法CFB加密模式
#define SGD_SMS4_OFB     0x00000408 // SMS4 算法OFB加密模式
#define SGD_SMS4_MAC     0x00000410 // SMS4 算法MAC运算
/*************************************************************/

/***************** 非对称密码算法标识**************/
#define SGD_RSA          0x00010000 // RSA算法
#define SGD_SM2_1        0x00020100 // 椭圆曲线签名算法
#define SGD_SM2_2        0x00020200 // 椭圆曲线密钥交换协议
#define SGD_SM2_3        0x00020400 // 椭圆曲线加密算法
/*************************************************************/

/***************** 密码杂凑算法标识******************/
#define SGD_SM3          0x00000001 // SM3密码杂凑算法
#define SGD_SHA1         0x00000002 // SHA1密码杂凑算法
#define SGD_SHA256       0x00000004 // SHA256密码杂凑算法
/*************************************************************/

/********************* 权限类型***************************/
#define SECURE_NEVER_ACCOUNT  0x00000000 // 不允许
#define SECURE_ADM_ACCOUNT    0x00000001 // 管理员权限
#define SECURE_USER_ACCOUNT   0x00000010 // 用户权限
#define SECURE_ANYONE_ACCOUNT 0x000000FF // 任何人
/*************************************************************/

/********************* 设备状态***************************/
#define DEV_ABSENT_STATE  0x00000000 // 设备不存在
#define DEV_PRESENT_STATE 0x00000001 // 设备存在
#define DEV_UNKNOW_STATE  0x00000002 // 设备状态未知
/*************************************************************/

#define ADMIN_TYPE        0  // 管理员PIN类型
#define USER_TYPE         1  // 用户PIN类型

#define ALGORITHM_SM1     0x00 // 设备必须支持，默认算法
#define ALGORITHM_SSF33   0x01
#define ALGORITHM_SMS4    0x02
// 摘要算法标识
#define DEGIST_SM3        0x01
#define DEGIST_SHA1       0x02
#define DEGIST_SHA256     0x03
#define DEGIST_SHA384     0x04
#define DEGIST_SHA512     0x05


#define MAX_IV_LEN                    32  // 为初始化向量的最大长度
#define MAX_RSA_MODULUS_LEN          256  //为算法模数的最大长度
#define MAX_RSA_EXPONENT_LEN           4  //为算法指数的最大长度

#define ECC_MAX_MODULUS_BITS_LEN     256  //为ECC算法模数的最大长度
#define ECC_MAX_MODULUS_LEN          ( 64 )
#define ECC_MAX_XCOORDINATE_BITS_LEN 256
#define ECC_MAX_YCOORDINATE_BITS_LEN 256
#define ECC_MAX_XCOORDINATE_LEN      ( ECC_MAX_XCOORDINATE_BITS_LEN / 8 ) //为ECC算法X坐标的最大长度
#define ECC_MAX_YCOORDINATE_LEN      ( ECC_MAX_YCOORDINATE_BITS_LEN / 8 ) //为ECC算法Y坐标的最大长度


/********************* INS 代码***************************/
#define CMD_SET_LABEL                           0x02
#define CMD_GET_DEVINFO                         0x04
#define CMD_DEVAUTH                             0x10
#define CMD_CHANGE_DEVAUTHKEY                   0x12
#define CMD_GET_PININFO                         0x14
#define CMD_CHANGE_PIN                          0x16
#define CMD_VERIFY_PIN                          0x18
#define CMD_UNBLOCK_PIN                         0x1a
#define CMD_CLEAR_SECURESTATE                   0x1c
#define CMD_CREATE_APPLICATION                  0x20
#define CMD_ENUM_APPLICATION                    0x22
#define CMD_DELETE_APPLICATION                  0x24
#define CMD_OPEN_APPLICATION                    0x26
#define CMD_CLOSE_APPLICATION                   0x28
#define CMD_CREATE_FILE                         0x30
#define CMD_DELETE_FILE                         0x32
#define CMD_ENUM_FILES                          0x34
#define CMD_GET_FILEINFO                        0x36
#define CMD_READ_FILE                           0x38
#define CMD_WRITE_FILE                          0x3a
#define CMD_CREATE_CONTAINER                    0x40
#define CMD_OPEN_CONTAINER                      0x42
#define CMD_CLOSE_CONTAINER                     0x44
#define CMD_ENUM_CONTAINER                      0x46
#define CMD_DELETE_CONTAINER                    0x48
#define CMD_GET_CONTAINERINFO                   0x4a
#define CMD_IMPORT_CERTIFICATE                  0x4c
#define CMD_EXPORT_CERTIFICATE                  0x4e
#define CMD_GEN_RANDOM                          0x50
#define CMD_GEN_EXTRSAKEY                       0x52
#define CMD_GEN_RSAKEYPAIR                      0x54
#define CMD_IMPORT_RSAKEYPAIR                   0x56
#define CMD_RSA_SIGNDATA                        0x58
#define CMD_RSA_EXPORTSESSIONKEY                0x5a
#define CMD_RSA_OPERATION                       0x5c
#define CMD_GEN_ECCKEYPAIR                      0x70
#define CMD_IMPORT_ECCKEYPAIR                   0x72
#define CMD_ECC_SIGNDATA                        0x74
#define CMD_ECC_VERIFY                          0x76
#define CMD_ECC_EXPORTSESSIONKEY                0x78
#define CMD_EXTECC_ENCRYPT                      0x7a
#define CMD_EXTECC_DECRYPT                      0x7c
#define CMD_EXTECC_SIGN                         0x7e
#define CMD_GENERATE_AGREEMENTDATAWITHECC       0x82
#define CMD_GENERATE_AGREEMENTDATAANDKEYWITHECC 0x84
#define CMD_GENERATE_KEYWITHECC                 0x86
#define CMD_EXPORT_PUBKEY                       0x88
#define CMD_IMPORT_SESSIONKEY                   0xa0
#define CMD_IMPORT_SYMMKEY                      0xa2
#define CMD_ENCRYPT_INIT                        0xa4
#define CMD_ENCRYPT                             0xa6
#define CMD_ENCRYPT_UPDATE                      0xa8
#define CMD_ENCRYPT_FINAL                       0xaa
#define CMD_DECRYPT_INIT                        0xac
#define CMD_DECRYPT                             0xae
#define CMD_DECRYPT_UPDATE                      0xb0
#define CMD_DECRYPT_FINAL                       0xb2
#define CMD_DIGEST_INIT                         0xb4
#define CMD_DIGEST                              0xb6
#define CMD_DIGEST_UPDATE                       0xb8
#define CMD_DIGEST_FINAL                        0xba
#define CMD_MAC_INIT                            0xbc
#define CMD_MAC                                 0xbe
#define CMD_MAC_UPDATE                          0xc0
#define CMD_MAC_FINAL                           0xc2
#define CMD_DESTORY_SESSIONKEY                  0xc4
/* 自定义，开始 */
#define CMD_APPLICATION_BLOCK                   0xd0
#define CMD_APPLICATION_UNBLOCK                 0xd2
#define CMD_CARD_BLOCK                          0xd4
#define CMD_INTERNAL_AUTHENTICATION             0xd6
#define CMD_CARD_UNBLOCK                        0xf4
#define CMD_CARD_INIT                           0xe4
#ifdef MOBILE_SHIELD_TOKEN
#define CMD_READTOKEN                           0xC0
#define CMD_SETCALCEQ                           0xC1
#define CMD_READEQ                              0xC2
#define CMD_GERPERMIT                           0xC3
#endif
//#ifdef MOBILE_SHIELD_SHOW
#define CMD_SHOWCONTENT                         0xF2
#define CMD_READSTATUS                          0xF3
//#endif
/* 自定义，结束 */
    
//++++++++ by zhangjian 20151022 15:50
#define CMD_GETICCARDNUM                        0xE8
#define CMD_Sufficient                          0xEA

#define MAX_BUF  2560

extern BYTE CmdData[MAX_BUF];

typedef struct _T_PCCmd
{
	BYTE   CLA;
	BYTE   INS;
	BYTE   P1;
	BYTE   P2;
	USHORT LC;
	USHORT LE;
}
TPCCmd;

#define CMD_HEAD_LEN sizeof(TPCCmd)

/* 主版本号和次版本号以“.”分隔，例如 Version 1.0，
    主版本号为1，次版本号为0；
    Version 2.10，主版本号为2，次版本号为10。 */
//typedef struct Struct_Version
//{
//	BYTE major;  // 主版本号
//	BYTE minor;  // 此版本号
//}
//VERSION;

#if 0
typedef struct Struct_DEVINFO
{
	VERSION Version;           // 版本号
	CHAR    Manufacturer[64];  // 设备厂商信息，以 ‘\0’为结束符的ASCII字符串
	CHAR    Issuer[64];        // 发行厂商信息，以 ‘\0’为结束符的ASCII字符串
	CHAR    Label[32];         // 设备标签，以 ‘\0’为结束符的ASCII字符串
	CHAR    SerialNumber[32];  // 序列号，以 ‘\0’为结束符的ASCII字符串
	VERSION HWVersion;         // 设备硬件版本
	VERSION FirmwareVersion;   // 设备本身固件版本
	ULONG   AlgSymCap;         // 分组密码算法标识
	ULONG   AlgAsymCap;        // 非对称密码算法标识
	ULONG   AlgHashCap;        // 密码杂凑算法标识
	ULONG   DevAuthAlgId;      // 设备认证使用的分组密码算法标识
	ULONG   TotalSpace;        // 设备总空间大小
	ULONG   FreeSpace;         // 用户可用空间大小
	BYTE    Reserved[64];      // 保留扩展
}
DEVINFO, *PDEVINFO;
#endif

typedef struct Struct_RSAPUBLICKEYBLOB
{
	ULONG AlgID;                                // 算法标识号
	ULONG BitLen;                               // 模数的实际位长度，必须是8的倍数
	BYTE  Modulus[MAX_RSA_MODULUS_LEN/2];         // 模数n = p * q
	BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN]; // 公开密钥e，一般为00010001
}
RSAPUBLICKEYBLOB, *PRSAPUBLICKEYBLOB;
    
    
typedef struct Struct_MaxLen_RSAPUBLICKEYBLOB
{
    ULONG AlgID;                                // 算法标识号
    ULONG BitLen;                               // 模数的实际位长度，必须是8的倍数
    BYTE  Modulus[MAX_RSA_MODULUS_LEN];         // 模数n = p * q
    BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN*2]; // 公开密钥e，一般为00010001
}
MaxLen_RSAPUBLICKEYBLOB, *MaxLen_PRSAPUBLICKEYBLOB;

typedef struct Struct_RSAPRIVATEKEYBLOB
{
	ULONG AlgID;                                 // 算法标识号
	ULONG BitLen;                                // 模数的实际位长度，必须是8的倍数
	BYTE  Modulus[MAX_RSA_MODULUS_LEN];          // 模数n = p * q，实际长度为BitLen/8字节
	BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN];  // 公开密钥e，一般为00010001
	BYTE  PrivateExponent[MAX_RSA_MODULUS_LEN];  // 私有密钥d，实际长度为BitLen/8字节
	BYTE  Prime1[MAX_RSA_MODULUS_LEN/2];         // 素数p，实际长度为BitLen/16字节
	BYTE  Prime2[MAX_RSA_MODULUS_LEN/2];         // 素数q，实际长度为BitLen/16字节
	BYTE  Prime1Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (p-1)的值，实际长度为BitLen/16字节
	BYTE  Prime2Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (q -1)的值，实际长度为BitLen/16字节
	BYTE  Coefficient[MAX_RSA_MODULUS_LEN/2];    // q模p的乘法逆元，实际长度为BitLen/16字节
}
RSAPRIVATEKEYBLOB, *PRSAPRIVATEKEYBLOB;

    
typedef struct Struct_RSAPRIVATEKEYBLOB_2048
    {
        ULONG AlgID;                                 // 算法标识号
        ULONG BitLen;                                // 模数的实际位长度，必须是8的倍数
        BYTE  Modulus[MAX_RSA_MODULUS_LEN];          // 模数n = p * q，实际长度为BitLen/8字节
        BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN];  // 公开密钥e，一般为00010001
        BYTE  PrivateExponent[MAX_RSA_MODULUS_LEN];  // 私有密钥d，实际长度为BitLen/8字节
        BYTE  Prime1[MAX_RSA_MODULUS_LEN/2];         // 素数p，实际长度为BitLen/16字节
        BYTE  Prime2[MAX_RSA_MODULUS_LEN/2];         // 素数q，实际长度为BitLen/16字节
        BYTE  Prime1Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (p-1)的值，实际长度为BitLen/16字节
        BYTE  Prime2Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (q -1)的值，实际长度为BitLen/16字节
        BYTE  Coefficient[MAX_RSA_MODULUS_LEN/2];    // q模p的乘法逆元，实际长度为BitLen/16字节
    }
    RSAPRIVATEKEYBLOB_2048, *PRSAPRIVATEKEYBLOB_2048;
    
//typedef struct Struct_ECCPUBLICKEYBLOB
//{
//	ULONG AlgID;                                // 算法标识号
//	ULONG BitLen;                               // 模数的实际位长度，必须是8的倍数
//	BYTE  XCoordinate[64]; // 曲线上点的X坐标
//	BYTE  YCoordinate[64]; // 曲线上点的Y坐标
//}
//ECCPUBLICKEYBLOB, *PECCPUBLICKEYBLOB;

//typedef struct Struct_ECCPRIVATEKEYBLOB
//{
//	ULONG AlgID;                                  // 算法标识号
//	ULONG BitLen;                                 // 模数的实际位长度
//	BYTE  PrivateKey[64];        // 私有密钥
//}
//ECCPRIVATEKEYBLOB, *PECCPRIVATEKEYBLOB;

//typedef struct Struct_ECCCIPHERBLOB
//{
//	BYTE XCoordinate[64]; // 与y组成椭圆曲线上的点（x，y）
//	BYTE YCoordinate[64]; // 与x组成椭圆曲线上的点（x，y）
//	BYTE Cipher[64];          // 密文数据
//	BYTE Mac[64];             // 预留，用于支持带MAC的ECC算法
//}
//ECCCIPHERBLOB, *PECCCIPHERBLOB;
//
//typedef struct Struct_ECCSIGNATUREBLOB
//{
//	BYTE r[64];  // 签名结果的r部分
//	BYTE s[64];  // 签名结果的s部分
//}
//ECCSIGNATUREBLOB, *PECCSIGNATUREBLOB;

//typedef struct Struct_BLOCKCIPHERPARAM
//{
//	BYTE  IV[MAX_IV_LEN];  // 初始向量
//	ULONG IVLen;           // 初始向量实际长度（按字节计算）
//	ULONG PaddingType;     // 填充方式，0表示不填充，1表示按照PKCS#5方式进行填充
//	ULONG FeedBitLen;      // 反馈值的位长度（按位计算），只针对OFB、CFB模式
//}
//BLOCKCIPHERPARAM, *PBLOCKCIPHERPARAM;

typedef struct Struct_FILEATTRIBUTE
{
	CHAR  FileName[40];  // 文件名，以‘\0’结束的ASCII字符串，最大长度为32
	ULONG FileSize;      // 文件大小，创建文件时定义的文件大小
	ULONG ReadRights;    // 读取权限，读取文件需要的权限
	ULONG WriteRights;   // 写入权限，写入文件需要的权限
}
FILEATTRIBUTE, *PFILEATTRIBUTE;


/********************** 设备管理指令**********************/
INT CMD_SetLabel( BYTE * pData, UINT nLen );
INT CMD_GetDevInfo( UINT nRetType );
INT CMD_Transmit( BYTE * pCmd, ULONG uCmdLen, BYTE * pData, ULONG uDataLen );
INT CMD_TransmitEx( BYTE * pData, ULONG uDataLen );
/****************************************************************/

/********************** 访问控制指令**********************/
INT CMD_DevAuth( UINT nType, BYTE * pData, UINT nLen );
INT CMD_ChangeDevAuthKey( BYTE nType, BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] );
INT CMD_GetPINInfo( BYTE nType, BYTE * pData, UINT nLen );
INT CMD_ChangePIN( BYTE nType, BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] );
INT CMD_VerifyPIN( BYTE nType, BYTE * pData, UINT nLen );
INT CMD_UnblockPIN( BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] );
INT CMD_ClearSecureState( BYTE * pData, UINT nLen );
/****************************************************************/

/********************** 应用管理指令**********************/
INT CMD_CreateApplication( BYTE * pData, UINT nLen );
INT CMD_EnumApplication( UINT nRetType );
INT CMD_DeleteApplication( BYTE * pData, UINT nLen );
INT CMD_OpenApplication( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_CloseApplication( BYTE * pData, UINT nLen );
/****************************************************************/

/********************** 文件管理指令**********************/
INT  CMD_CreateFile( UINT nAppID, BYTE * pData, UINT nLen );
INT CMD_DeleteFile( UINT nAppID, BYTE * pData, UINT nLen );
INT CMD_EnumFiles( UINT nAppID, UINT nRetType );
INT CMD_GetFileInfo( UINT nAppID, BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ReadFile( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_WriteFile( BYTE * pData, UINT nLen );
/****************************************************************/

/********************** 容器管理指令**********************/
INT CMD_CreateContainer( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_OpenContainer( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_CloseContainer( BYTE * pData, UINT nLen );
INT CMD_EnumContainer( BYTE * pData, UINT nLen );
INT CMD_DeleteContainer( BYTE * pData, UINT nLen );
INT CMD_GetContainerInfo( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ImportCertificate( BYTE * pData, UINT nLen );
INT CMD_ExportCertificate( UINT nType, BYTE * pData, UINT nLen );
/****************************************************************/

/********************** 密码服务指令**********************/
INT CMD_GenRandom( UINT nRetLen );
INT CMD_GenExtRSAKey( BYTE * pData, UINT nLen, UINT nBitsLen );
INT CMD_GenerateRSAKeyPair( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ImportRSAKeyPair( BYTE * pData, UINT nLen );
INT CMD_RSASignData( BYTE p1, BYTE p2, BYTE * pData, UINT nLen );
INT CMD_RSAExportSessionKey( BYTE * pData, UINT nLen, UINT nKey );
INT CMD_ExtRSAKeyOperation( BYTE P1, BYTE P2, BYTE * pData, UINT nLen );
INT CMD_GenECCKeyPair( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ImportECCKeyPair( BYTE * pData, UINT nLen );
INT CMD_ECCSignData( UINT nP1, BYTE * pData, UINT nLen, UINT nRetType );
INT CMD_ECCVerify( BYTE * pData, UINT nLen );
INT CMD_ECCExportSessionKey( BYTE * pData, UINT nLen, UINT nRetType );
INT CMD_ExtECCEncrypt( BYTE * pData, UINT nLen, UINT nRetType );
INT CMD_ExtECCDecrypt( BYTE * pData, UINT nLen, UINT nRetType );
INT CMD_ExtECCSign( BYTE * pData, UINT nLen, UINT nRetType );
INT CMD_GenerateAgreementDataWithECC( BYTE * pData, UINT nLen, UINT nType );
INT CMD_GenerateAgreementDataAndKeyWithECC( BYTE * pData, UINT nLen, UINT nType );
INT CMD_GenerateKeyWithECC( BYTE * pData, UINT nLen, UINT nType );
INT CMD_ExportPublicKey( UINT nType, BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ImportSessionKey( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_SetSymmKey( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_EncryptInit( BYTE * pData, UINT nLen );
INT CMD_Encrypt( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_EncryptUpdate( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_EncryptFinal( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_DecryptInit( BYTE * pData, UINT nLen );
INT CMD_Decrypt( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_DecryptUpdate( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_DecryptFinal( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_DigestInit( BYTE P2, BYTE * pData, UINT nLen );
INT CMD_Digest( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_DigestUpdate( BYTE * pData, UINT nLen );
INT CMD_DigestFinal( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_MacInit( BYTE * pINData, UINT nInLen );
INT CMD_Mac( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_MacUpdate( BYTE * pData, UINT nLen );
INT CMD_MacFinal( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_DestorySessionKey( BYTE * pData, UINT nLen, UINT nRetType );
INT CMD_BlockApplication( UINT nType, BYTE * pData, UINT nLen );
INT CMD_UnblockApplication( BYTE * pData, UINT nLen );
INT CMD_BlockCard();
INT CMD_InternalAuthentication( BYTE * pData, UINT nLen );
/****************************************************************/
INT CMD_LockDev(HANDLE hHandle, BYTE * pIN,UINT nLen);
INT CMD_UnlockDev(HANDLE hHandle);
INT CMD_CardUnBlock();
INT CMD_CardInit();
//#ifdef AUTHENTICATION_TEST
INT TransmitData( BYTE * CmdStr, ULONG nCmdLen, BYTE * KeyMac, BYTE * KeyEnc, BYTE * outBuf );
int TransmitDataEx( BYTE * CmdStr, ULONG nCmdLen, BYTE * KeyMac, BYTE * KeyEnc, BYTE * outBuf);
INT GetMacEx( BYTE * initData, BYTE * strKey, BYTE * inBuf, ULONG * nBufLen );
//#endif
//#ifdef MOBILE_SHIELD_TOKEN
INT CMD_ReadTokenNum();
INT CMD_SetCalcEq( BYTE * pData, UINT nLen );
INT CMD_ReadEquipmentNum();
INT CMD_GeneratePermitCode( BYTE * pData, UINT nLen );
//#endif
//#ifdef MOBILE_SHIELD_SHOW
INT CMD_TransmitContent( BYTE * pData, UINT nLen );
INT CMD_ReadStatus(int p1);
    
VOID *CMD_ReadData(UINT nInLen ,UINT nIndex,UINT *nLen);
//#endif
INT CMD_HandShakeS();

//#endif
    
#pragma mark - 6100 token Interface
    INT CMD_QueueToken(LPSTR tokenSN);
    INT CMD_UpdatePin(LPSTR tokenSN, LPSTR newPin, LPSTR oldPin);
    INT CMD_ActiveTokenPlug(LPSTR tokenSN, LPSTR ActiveCode);
    INT CMD_UnlockRandomNo(LPSTR tokenSN);
    INT CMD_UnlockPin(LPSTR tokenSN, LPSTR unlockCode);
    INT CMD_GetTokenCodeSafety(LPSTR tokenSN, int audioPortPos,
                               LPSTR pin, LPSTR utctime,
                               LPSTR verify, int *ccountNo,
                               int * money, LPSTR name, int currency);
    INT CMD_QueryTokenEX();
    INT CMD_QueryVersionHW();
    INT CMD_CancelTrans();
    INT CMD_ShowWallet(LPSTR tokenSN, int audioPortPos,
                       LPSTR pin, LPSTR utctime,
                       LPSTR verify, int *ccountNo,
                       int * money, LPSTR name, int currency);
    INT CMD_GetTokenCodeSafety_key(LPSTR tokenSN, int audioPortPos,
                                   LPSTR pin, LPSTR utctime,
                                   LPSTR verify, int *ccountNo,
                                   int * money, LPSTR name, int currency);
    INT CMD_ScanCode(LPSTR tokenSN, int audioPortPos,
                     LPSTR pin, LPSTR utctime,
                     LPSTR verify, int *ccountNo,
                     int * money, LPSTR name, int currency);
    
    //++++++++ by zhangjian 20151022 15:50
    INT CMD_GetICCardNum();
    INT CMD_SufficientMoeny(LPSTR money,int lenght);
    

#ifdef __cplusplus
}
#endif

#endif

