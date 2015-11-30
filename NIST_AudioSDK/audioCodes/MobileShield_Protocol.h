
#ifndef __MOBILE_SHIELD_PROTOCOL_H__
#define __MOBILE_SHIELD_PROTOCOL_H__

#include "global.h"


#define L_BYTE( n ) ( BYTE )( n & 0x000000FF )
#define H_BYTE( n ) ( BYTE )( ( n >> 8 ) & 0x000000FF )

#ifdef __cplusplus
extern "C" {
#endif

//#ifdef SKF_INTERFACE

/*******************���������㷨��ʶ*****************/
#define SGD_SM1_ECB      0x00000101 // SM1   �㷨ECB ����ģʽ
#define SGD_SM1_CBC      0x00000102 // SM1   �㷨CBC ����ģʽ
#define SGD_SM1_CFB      0x00000104 // SM1   �㷨CFB ����ģʽ
#define SGD_SM1_OFB      0x00000108 // SM1   �㷨OFB ����ģʽ
#define SGD_SM1_MAC      0x00000110 // SM1   �㷨MAC ����
#define SGD_SSF33_ECB    0x00000201 // SSF33�㷨ECB ����ģʽ
#define SGD_SSF33_CBC    0x00000202 // SSF33�㷨CBC����ģʽ
#define SGD_SSF33_CFB    0x00000204 // SSF33�㷨CFB����ģʽ
#define SGD_SSF33_OFB    0x00000208 // SSF33�㷨OFB����ģʽ
#define SGD_SSF33_MAC    0x00000210 // SSF33�㷨MAC����
#define SGD_SMS4_ECB     0x00000401 // SMS4 �㷨ECB����ģʽ
#define SGD_SMS4_CBC     0x00000402 // SMS4 �㷨CBC����ģʽ
#define SGD_SMS4_CFB     0x00000404 // SMS4 �㷨CFB����ģʽ
#define SGD_SMS4_OFB     0x00000408 // SMS4 �㷨OFB����ģʽ
#define SGD_SMS4_MAC     0x00000410 // SMS4 �㷨MAC����
/*************************************************************/

/***************** �ǶԳ������㷨��ʶ**************/
#define SGD_RSA          0x00010000 // RSA�㷨
#define SGD_SM2_1        0x00020100 // ��Բ����ǩ���㷨
#define SGD_SM2_2        0x00020200 // ��Բ������Կ����Э��
#define SGD_SM2_3        0x00020400 // ��Բ���߼����㷨
/*************************************************************/

/***************** �����Ӵ��㷨��ʶ******************/
#define SGD_SM3          0x00000001 // SM3�����Ӵ��㷨
#define SGD_SHA1         0x00000002 // SHA1�����Ӵ��㷨
#define SGD_SHA256       0x00000004 // SHA256�����Ӵ��㷨
/*************************************************************/

/********************* Ȩ������***************************/
#define SECURE_NEVER_ACCOUNT  0x00000000 // ������
#define SECURE_ADM_ACCOUNT    0x00000001 // ����ԱȨ��
#define SECURE_USER_ACCOUNT   0x00000010 // �û�Ȩ��
#define SECURE_ANYONE_ACCOUNT 0x000000FF // �κ���
/*************************************************************/

/********************* �豸״̬***************************/
#define DEV_ABSENT_STATE  0x00000000 // �豸������
#define DEV_PRESENT_STATE 0x00000001 // �豸����
#define DEV_UNKNOW_STATE  0x00000002 // �豸״̬δ֪
/*************************************************************/

#define ADMIN_TYPE        0  // ����ԱPIN����
#define USER_TYPE         1  // �û�PIN����

#define ALGORITHM_SM1     0x00 // �豸����֧�֣�Ĭ���㷨
#define ALGORITHM_SSF33   0x01
#define ALGORITHM_SMS4    0x02
// ժҪ�㷨��ʶ
#define DEGIST_SM3        0x01
#define DEGIST_SHA1       0x02
#define DEGIST_SHA256     0x03
#define DEGIST_SHA384     0x04
#define DEGIST_SHA512     0x05


#define MAX_IV_LEN                    32  // Ϊ��ʼ����������󳤶�
#define MAX_RSA_MODULUS_LEN          256  //Ϊ�㷨ģ������󳤶�
#define MAX_RSA_EXPONENT_LEN           4  //Ϊ�㷨ָ������󳤶�

#define ECC_MAX_MODULUS_BITS_LEN     256  //ΪECC�㷨ģ������󳤶�
#define ECC_MAX_MODULUS_LEN          ( 64 )
#define ECC_MAX_XCOORDINATE_BITS_LEN 256
#define ECC_MAX_YCOORDINATE_BITS_LEN 256
#define ECC_MAX_XCOORDINATE_LEN      ( ECC_MAX_XCOORDINATE_BITS_LEN / 8 ) //ΪECC�㷨X�������󳤶�
#define ECC_MAX_YCOORDINATE_LEN      ( ECC_MAX_YCOORDINATE_BITS_LEN / 8 ) //ΪECC�㷨Y�������󳤶�


/********************* INS ����***************************/
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
/* �Զ��壬��ʼ */
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
/* �Զ��壬���� */
    
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

/* ���汾�źʹΰ汾���ԡ�.���ָ������� Version 1.0��
    ���汾��Ϊ1���ΰ汾��Ϊ0��
    Version 2.10�����汾��Ϊ2���ΰ汾��Ϊ10�� */
//typedef struct Struct_Version
//{
//	BYTE major;  // ���汾��
//	BYTE minor;  // �˰汾��
//}
//VERSION;

#if 0
typedef struct Struct_DEVINFO
{
	VERSION Version;           // �汾��
	CHAR    Manufacturer[64];  // �豸������Ϣ���� ��\0��Ϊ��������ASCII�ַ���
	CHAR    Issuer[64];        // ���г�����Ϣ���� ��\0��Ϊ��������ASCII�ַ���
	CHAR    Label[32];         // �豸��ǩ���� ��\0��Ϊ��������ASCII�ַ���
	CHAR    SerialNumber[32];  // ���кţ��� ��\0��Ϊ��������ASCII�ַ���
	VERSION HWVersion;         // �豸Ӳ���汾
	VERSION FirmwareVersion;   // �豸����̼��汾
	ULONG   AlgSymCap;         // ���������㷨��ʶ
	ULONG   AlgAsymCap;        // �ǶԳ������㷨��ʶ
	ULONG   AlgHashCap;        // �����Ӵ��㷨��ʶ
	ULONG   DevAuthAlgId;      // �豸��֤ʹ�õķ��������㷨��ʶ
	ULONG   TotalSpace;        // �豸�ܿռ��С
	ULONG   FreeSpace;         // �û����ÿռ��С
	BYTE    Reserved[64];      // ������չ
}
DEVINFO, *PDEVINFO;
#endif

typedef struct Struct_RSAPUBLICKEYBLOB
{
	ULONG AlgID;                                // �㷨��ʶ��
	ULONG BitLen;                               // ģ����ʵ��λ���ȣ�������8�ı���
	BYTE  Modulus[MAX_RSA_MODULUS_LEN/2];         // ģ��n = p * q
	BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN]; // ������Կe��һ��Ϊ00010001
}
RSAPUBLICKEYBLOB, *PRSAPUBLICKEYBLOB;
    
    
typedef struct Struct_MaxLen_RSAPUBLICKEYBLOB
{
    ULONG AlgID;                                // �㷨��ʶ��
    ULONG BitLen;                               // ģ����ʵ��λ���ȣ�������8�ı���
    BYTE  Modulus[MAX_RSA_MODULUS_LEN];         // ģ��n = p * q
    BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN*2]; // ������Կe��һ��Ϊ00010001
}
MaxLen_RSAPUBLICKEYBLOB, *MaxLen_PRSAPUBLICKEYBLOB;

typedef struct Struct_RSAPRIVATEKEYBLOB
{
	ULONG AlgID;                                 // �㷨��ʶ��
	ULONG BitLen;                                // ģ����ʵ��λ���ȣ�������8�ı���
	BYTE  Modulus[MAX_RSA_MODULUS_LEN];          // ģ��n = p * q��ʵ�ʳ���ΪBitLen/8�ֽ�
	BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN];  // ������Կe��һ��Ϊ00010001
	BYTE  PrivateExponent[MAX_RSA_MODULUS_LEN];  // ˽����Կd��ʵ�ʳ���ΪBitLen/8�ֽ�
	BYTE  Prime1[MAX_RSA_MODULUS_LEN/2];         // ����p��ʵ�ʳ���ΪBitLen/16�ֽ�
	BYTE  Prime2[MAX_RSA_MODULUS_LEN/2];         // ����q��ʵ�ʳ���ΪBitLen/16�ֽ�
	BYTE  Prime1Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (p-1)��ֵ��ʵ�ʳ���ΪBitLen/16�ֽ�
	BYTE  Prime2Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (q -1)��ֵ��ʵ�ʳ���ΪBitLen/16�ֽ�
	BYTE  Coefficient[MAX_RSA_MODULUS_LEN/2];    // qģp�ĳ˷���Ԫ��ʵ�ʳ���ΪBitLen/16�ֽ�
}
RSAPRIVATEKEYBLOB, *PRSAPRIVATEKEYBLOB;

    
typedef struct Struct_RSAPRIVATEKEYBLOB_2048
    {
        ULONG AlgID;                                 // �㷨��ʶ��
        ULONG BitLen;                                // ģ����ʵ��λ���ȣ�������8�ı���
        BYTE  Modulus[MAX_RSA_MODULUS_LEN];          // ģ��n = p * q��ʵ�ʳ���ΪBitLen/8�ֽ�
        BYTE  PublicExponent[MAX_RSA_EXPONENT_LEN];  // ������Կe��һ��Ϊ00010001
        BYTE  PrivateExponent[MAX_RSA_MODULUS_LEN];  // ˽����Կd��ʵ�ʳ���ΪBitLen/8�ֽ�
        BYTE  Prime1[MAX_RSA_MODULUS_LEN/2];         // ����p��ʵ�ʳ���ΪBitLen/16�ֽ�
        BYTE  Prime2[MAX_RSA_MODULUS_LEN/2];         // ����q��ʵ�ʳ���ΪBitLen/16�ֽ�
        BYTE  Prime1Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (p-1)��ֵ��ʵ�ʳ���ΪBitLen/16�ֽ�
        BYTE  Prime2Exponent[MAX_RSA_MODULUS_LEN/2]; // d mod (q -1)��ֵ��ʵ�ʳ���ΪBitLen/16�ֽ�
        BYTE  Coefficient[MAX_RSA_MODULUS_LEN/2];    // qģp�ĳ˷���Ԫ��ʵ�ʳ���ΪBitLen/16�ֽ�
    }
    RSAPRIVATEKEYBLOB_2048, *PRSAPRIVATEKEYBLOB_2048;
    
//typedef struct Struct_ECCPUBLICKEYBLOB
//{
//	ULONG AlgID;                                // �㷨��ʶ��
//	ULONG BitLen;                               // ģ����ʵ��λ���ȣ�������8�ı���
//	BYTE  XCoordinate[64]; // �����ϵ��X����
//	BYTE  YCoordinate[64]; // �����ϵ��Y����
//}
//ECCPUBLICKEYBLOB, *PECCPUBLICKEYBLOB;

//typedef struct Struct_ECCPRIVATEKEYBLOB
//{
//	ULONG AlgID;                                  // �㷨��ʶ��
//	ULONG BitLen;                                 // ģ����ʵ��λ����
//	BYTE  PrivateKey[64];        // ˽����Կ
//}
//ECCPRIVATEKEYBLOB, *PECCPRIVATEKEYBLOB;

//typedef struct Struct_ECCCIPHERBLOB
//{
//	BYTE XCoordinate[64]; // ��y�����Բ�����ϵĵ㣨x��y��
//	BYTE YCoordinate[64]; // ��x�����Բ�����ϵĵ㣨x��y��
//	BYTE Cipher[64];          // ��������
//	BYTE Mac[64];             // Ԥ��������֧�ִ�MAC��ECC�㷨
//}
//ECCCIPHERBLOB, *PECCCIPHERBLOB;
//
//typedef struct Struct_ECCSIGNATUREBLOB
//{
//	BYTE r[64];  // ǩ�������r����
//	BYTE s[64];  // ǩ�������s����
//}
//ECCSIGNATUREBLOB, *PECCSIGNATUREBLOB;

//typedef struct Struct_BLOCKCIPHERPARAM
//{
//	BYTE  IV[MAX_IV_LEN];  // ��ʼ����
//	ULONG IVLen;           // ��ʼ����ʵ�ʳ��ȣ����ֽڼ��㣩
//	ULONG PaddingType;     // ��䷽ʽ��0��ʾ����䣬1��ʾ����PKCS#5��ʽ�������
//	ULONG FeedBitLen;      // ����ֵ��λ���ȣ���λ���㣩��ֻ���OFB��CFBģʽ
//}
//BLOCKCIPHERPARAM, *PBLOCKCIPHERPARAM;

typedef struct Struct_FILEATTRIBUTE
{
	CHAR  FileName[40];  // �ļ������ԡ�\0��������ASCII�ַ�������󳤶�Ϊ32
	ULONG FileSize;      // �ļ���С�������ļ�ʱ������ļ���С
	ULONG ReadRights;    // ��ȡȨ�ޣ���ȡ�ļ���Ҫ��Ȩ��
	ULONG WriteRights;   // д��Ȩ�ޣ�д���ļ���Ҫ��Ȩ��
}
FILEATTRIBUTE, *PFILEATTRIBUTE;


/********************** �豸����ָ��**********************/
INT CMD_SetLabel( BYTE * pData, UINT nLen );
INT CMD_GetDevInfo( UINT nRetType );
INT CMD_Transmit( BYTE * pCmd, ULONG uCmdLen, BYTE * pData, ULONG uDataLen );
INT CMD_TransmitEx( BYTE * pData, ULONG uDataLen );
/****************************************************************/

/********************** ���ʿ���ָ��**********************/
INT CMD_DevAuth( UINT nType, BYTE * pData, UINT nLen );
INT CMD_ChangeDevAuthKey( BYTE nType, BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] );
INT CMD_GetPINInfo( BYTE nType, BYTE * pData, UINT nLen );
INT CMD_ChangePIN( BYTE nType, BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] );
INT CMD_VerifyPIN( BYTE nType, BYTE * pData, UINT nLen );
INT CMD_UnblockPIN( BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] );
INT CMD_ClearSecureState( BYTE * pData, UINT nLen );
/****************************************************************/

/********************** Ӧ�ù���ָ��**********************/
INT CMD_CreateApplication( BYTE * pData, UINT nLen );
INT CMD_EnumApplication( UINT nRetType );
INT CMD_DeleteApplication( BYTE * pData, UINT nLen );
INT CMD_OpenApplication( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_CloseApplication( BYTE * pData, UINT nLen );
/****************************************************************/

/********************** �ļ�����ָ��**********************/
INT  CMD_CreateFile( UINT nAppID, BYTE * pData, UINT nLen );
INT CMD_DeleteFile( UINT nAppID, BYTE * pData, UINT nLen );
INT CMD_EnumFiles( UINT nAppID, UINT nRetType );
INT CMD_GetFileInfo( UINT nAppID, BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ReadFile( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_WriteFile( BYTE * pData, UINT nLen );
/****************************************************************/

/********************** ��������ָ��**********************/
INT CMD_CreateContainer( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_OpenContainer( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_CloseContainer( BYTE * pData, UINT nLen );
INT CMD_EnumContainer( BYTE * pData, UINT nLen );
INT CMD_DeleteContainer( BYTE * pData, UINT nLen );
INT CMD_GetContainerInfo( BYTE * pData, UINT nLen, UINT nRetLen );
INT CMD_ImportCertificate( BYTE * pData, UINT nLen );
INT CMD_ExportCertificate( UINT nType, BYTE * pData, UINT nLen );
/****************************************************************/

/********************** �������ָ��**********************/
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

