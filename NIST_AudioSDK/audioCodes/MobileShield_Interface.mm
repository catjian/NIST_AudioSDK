
#include "MobileShield_Interface.h"
#include "MobileShield_Protocol.h"

#include "MobileShield.h"
//#include "Debug_Log.h"
#include <string.h>
#include <stdlib.h>

#include "global.h"
#include "sha-1.h"
#include "SMS4.h"
#include "Function.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

//#ifdef SKF_INTERFACE

typedef struct _tagEA
{
	CHAR data[10];
	INT  len;
}
EA;

EA g_EA = { "msmf2139", 8 };
CALLBACK_FUNC g_Callback = NULL;
BYTE          gWaitFlag  = 0;

DEVHANDLE   g_Dev = NULL;                 // µ±«∞¥Úø™µƒ…Ë±∏
APPLICATION g_Application;                // µ±«∞¥Úø™µƒ”¶”√
CONTAINER   g_Container;                  // µ±«∞»›∆˜ID
//JNIEnv    * g_pEnv = NULL;                // µ±«∞JNIµ˜”√¥´»Îµƒenv
CHAR        g_Cbf[64];                    // µ±«∞JNIµ˜”√¥´»Îµƒªÿµ˜∫Ø ˝√˚
    

PAPPLICATION GetApplication()
{
    DebugAudioLog(@"");
	
	return &g_Application;
}

VOID SetApplication( APPLICATION application )
{
    DebugAudioLog(@"");
	
	//g_Application.wAppID = application.wAppID;
 
    //printf("%d",application.wAppID);
	//memcpy( g_Application.szName, application.szName, 32 );
    g_Application.wAppID = application.wAppID;
}

VOID ClearApplication()
{
    DebugAudioLog(@"");
	
	memset( &g_Application, 0x00, sizeof( APPLICATION ) );
}

PCONTAINER GetContainer()
{
    DebugAudioLog(@"");
	
	return &g_Container;
}

VOID SetContainer( CONTAINER container )
{
    DebugAudioLog(@"");
	
	g_Container.wContainerID = container.wContainerID;
	//memcpy( g_Container.szName, container.szName, 32 );
}

VOID ClearContainer()
{
    DebugAudioLog(@"");
	
	memset( &g_Container, 0x00, sizeof( CONTAINER ) );
}

CHAR * GetEA()
{
    DebugAudioLog(@"");
	
	return g_EA.data;
}

VOID SetEA( CHAR * ea, INT len )
{
    DebugAudioLog(@"");
	
	memset( &g_EA, 0, sizeof( g_EA ) );
	memcpy( g_EA.data, ea, len );
	g_EA.len = len;
}

VOID ClearEA()
{
    DebugAudioLog(@"");
	
	memset( &g_EA, 0, sizeof( g_EA ) );
}

VOID SetCbf( CHAR * cbf )
{
    DebugAudioLog(@"");
	
	memcpy( g_Cbf, cbf, strlen( cbf ) );
}

CHAR * GetCbf()
{
    DebugAudioLog(@"");
	
	return g_Cbf;
}

CALLBACK_FUNC GetCallbackFun()
{
    DebugAudioLog(@"");
	
	return g_Callback;
}

VOID ResetCallFun()
{
    DebugAudioLog(@"");
	
	g_Callback = NULL;
}

static INT CB_GeneralHandleProc( VOID * obj, VOID * cbf, VOID * param )
{
    DebugAudioLog(@"");
	
	Return_Data * pReturnData = ( Return_Data * )param;

	return pReturnData->Status;
}

VOID SetGeneralHandleProc()
{
    DebugAudioLog(@"");
	
	g_Callback = CB_GeneralHandleProc;
}


ULONG DEVAPI SKF_SetLabel( DEVHANDLE hDev, LPSTR szLabel )
{
    DebugAudioLog(@"");
	
	if (szLabel == NULL)
        {
        return SAR_FAIL;
    }
	if ( CMD_SetLabel( ( BYTE * )szLabel, strlen( szLabel ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_GetDevInfo( DEVHANDLE hDev, DEVINFO * pDevInfo )
{
    DebugAudioLog(@"");
	
	//PReturnDataEx pRetData = NULL;

	if ( CMD_GetDevInfo( 0x0000 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
	ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        //printf("SKF_GetDevInfo:tmpReturn->Data = %s, tmpReturn->Length = %d", tmpReturn->Data, tmpReturn->Length);
        if (pDevInfo != NULL)
        {
            memcpy(&pDevInfo->StructVersion.major, tmpReturn->Data, 1);
            memcpy(&pDevInfo->StructVersion.minor, tmpReturn->Data+1, 1);
            memcpy(&pDevInfo->SpecificationVersion.major, tmpReturn->Data+2, 1);
            memcpy(&pDevInfo->SpecificationVersion.minor, tmpReturn->Data+3, 1);
            memcpy(pDevInfo->Manufacturer, tmpReturn->Data+4, 64);
            memcpy(pDevInfo->Issuer, tmpReturn->Data+68, 64);
            memcpy(pDevInfo->Label, tmpReturn->Data+132, 32);
            memcpy(pDevInfo->SerialNumber, tmpReturn->Data + 164, 32);//32
            memcpy(&pDevInfo->HWVersion.major, tmpReturn->Data+196, 1);
            memcpy(&pDevInfo->HWVersion.minor, tmpReturn->Data+197, 1);
            memcpy(&pDevInfo->FirmwareVersion.major, tmpReturn->Data+198, 1);
            memcpy(&pDevInfo->FirmwareVersion.minor, tmpReturn->Data+199, 1);
            memcpy(&pDevInfo->AlgSymCap, tmpReturn->Data+200, 4);
            memcpy(&pDevInfo->AlgAsymCap, tmpReturn->Data+204, 4);
            memcpy(&pDevInfo->AlgHashCap, tmpReturn->Data+208, 4);
            memcpy(&pDevInfo->DevAuthAlgId, tmpReturn->Data+212, 4);
            memcpy(&pDevInfo->TotalSpace, tmpReturn->Data+216, 4);
            memcpy(&pDevInfo->FreeSpace, tmpReturn->Data+220, 4);
            memcpy(&pDevInfo->MaxApduDataLen, tmpReturn->Data+224, 2);
            memcpy(&pDevInfo->UserAuthMethod, tmpReturn->Data+226, 2);
            memcpy(&pDevInfo->DeviceType, tmpReturn->Data+228, 2);
            memcpy(&pDevInfo->MaxContainerNum, tmpReturn->Data+230, 1);
            memcpy(&pDevInfo->MaxCertNum, tmpReturn->Data+231, 1);
            memcpy(&pDevInfo->MaxFileNum, tmpReturn->Data+232, 2);
            memcpy(pDevInfo->Reserved, tmpReturn->Data+234, 54);
        }
        

        return SAR_OK;
    }

	return SAR_FAIL;
}

//#if 0
ULONG DEVAPI SKF_LockDev( DEVHANDLE hDev, ULONG ulTimeOut )
{
//#if 0
	if ( CMD_LockDev(hDev, (BYTE *)&ulTimeOut, 4) != STATUS_SUCCESS )
		return SAR_FAIL;
//#endif
	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_UnlockDev( DEVHANDLE hDev )
{
//#if 0
	if ( CMD_UnlockDev(hDev) != STATUS_SUCCESS )
		return SAR_FAIL;
//#endif
	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}
//#endif

ULONG DEVAPI SKF_Transmit(
	DEVHANDLE hDev,
	BYTE    * pbCommand,
	ULONG     ulCommandLen,
	BYTE    * pbData,
	ULONG   * pulDataLen )
{
    DebugAudioLog(@"");
	
	if (pbCommand == NULL || pbData == NULL)
        {
        return SAR_FAIL;
    }
	if ( CMD_Transmit( pbCommand, ulCommandLen, pbData, *pulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;
    
    //modify by wangzhong at 2012-6-26
	ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbData != NULL)
        {
            memcpy(pbData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulDataLen != NULL)
        {
            *pulDataLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_TransmitEx(
	DEVHANDLE hDev,
	BYTE    * pbData,
	ULONG     ulDataLen )
{
    DebugAudioLog(@"");
	
	if (pbData == NULL || ulDataLen <= 0)
        {
        return SAR_FAIL;
    }
	if ( CMD_TransmitEx( pbData, ulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}
/*****************************************/

/*************  ∑√Œ øÿ÷∆**************/
// ÷¥––¥À√¸¡Ó«∞£¨–Ë“™Õ®π˝»°ÀÊª˙ ˝√¸¡ÓªÒ»°8◊÷Ω⁄ÀÊª˙ ˝
// pbAuthDataŒ™º”√‹µƒ»œ÷§ ˝æ›
ULONG DEVAPI SKF_DevAuth(
	DEVHANDLE hDev,
	BYTE    * pbAuthData,
	ULONG     ulLen )
{
    DebugAudioLog(@"");
	
	if (pbAuthData == NULL || ulLen <= 0)
        {
        return SAR_FAIL;
    }
	if ( CMD_DevAuth( ALGORITHM_SMS4, pbAuthData, ulLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

// ÷¥––¥À√¸¡Ó«∞£¨–Ë“™Õ®π˝»°ÀÊª˙ ˝√¸¡Ó÷¡…ŸªÒ»°8◊÷Ω⁄ÀÊª˙ ˝
// √¸¡Ó±®Œƒ ˝æ›”Ú”…º”√‹µƒ…Ë±∏»œ÷§√‹‘ø ˝æ›∫Õ±®Œƒ»œ÷§¬Î(MAC) ˝æ›‘™◊È≥…£¨
// ”√”⁄º”√‹º∞œﬂ¬∑±£ª§µƒ√‹‘øŒ™‘≠…Ë±∏»œ÷§√‹‘ø°£
ULONG DEVAPI SKF_ChangeDevAuthKey(
	DEVHANDLE hDev,
	BYTE    * pbKeyValue,
	ULONG     ulKeyLen )
{
    DebugAudioLog(@"");
	
	if (pbKeyValue == NULL || ulKeyLen <= 0)
        {
        return SAR_FAIL;
    }
    
	BYTE EncryptedData[2*DATA_BLOCK_LEN] = { 0 };
	BYTE HashKey[DATA_BLOCK_LEN]         = { 0 };
	BYTE Random[DATA_BLOCK_LEN]          = { 0 };

	memcpy( EncryptedData, pbKeyValue, 2 * DATA_BLOCK_LEN );
	memcpy( HashKey, pbKeyValue + 2 * DATA_BLOCK_LEN, DATA_BLOCK_LEN );
	memcpy( Random, pbKeyValue + 3 * DATA_BLOCK_LEN, DATA_BLOCK_LEN );

	if ( CMD_ChangeDevAuthKey( ALGORITHM_SMS4, pbKeyValue, ulKeyLen, HashKey, Random ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_GetPINInfo(
	HAPPLICATION hApplication,
	ULONG        ulPINType,
	ULONG      * pulMaxRetryCount,
	ULONG      * pulRemainRetryCount,
	bool       * pbDefaultPin )
{
    DebugAudioLog(@"");
	
	WORD          wData        = 0;
	UINT          Status       = STATUS_FAILED;
	PReturnDataEx pRetData     = NULL;
	PAPPLICATION  pApplication = ( PAPPLICATION )hApplication;
    if (pApplication == NULL)
        {
        return SAR_FAIL;
    }
	// ªÒµ√”¶”√ID
	wData = pApplication->wAppID;

	Status    = CMD_GetPINInfo( ( BYTE )ulPINType, ( BYTE * )&wData, sizeof( wData ) );
	pRetData  = GetReturnDataEx();

	*pulMaxRetryCount    = pRetData->Data[0];  // ◊Ó¥Û÷ÿ ‘¥Œ ˝
	*pulRemainRetryCount = pRetData->Data[1];  // µ±«∞ £”‡÷ÿ ‘¥Œ ˝
	*pbDefaultPin        = pRetData->Data[2];  // ≥ˆ≥ßƒ¨»œPIN¬Î◊¥Ã¨

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

// ÷¥––¥À√¸¡Ó«∞£¨–Ë“™‘§œ»—°‘Ò”¶”√£¨≤¢Õ®π˝»°ÀÊª˙ ˝√¸¡Ó÷¡…ŸªÒ»°8 ◊÷Ω⁄ÀÊª˙ ˝
// √¸¡Ó±®Œƒ ˝æ›”Ú”…º”√‹µƒ–¬PIN ∫Õ±®Œƒ»œ÷§¬Î(MAC) ˝æ›‘™◊È≥…°£
// º”√‹º∞œﬂ¬∑±£ª§√‹‘øŒ™‘≠PIN æ≠π˝HASH-SHA1 ∫Ûµƒ«∞16 ◊÷Ω⁄ ˝æ›°£
// º”√‹“‘º∞MAC º∆À„≤…”√SMS4 À„∑®°£
ULONG DEVAPI SKF_ChangePIN(
	HAPPLICATION hApplication,
	ULONG        ulPINType,
	LPSTR        szOldPin,
	LPSTR        szNewPin,
	ULONG      * pulRetryCount )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
    {
        return SAR_FAIL;
    }
	BYTE   OldPIN[DATA_BLOCK_LEN]  = { 0 };
	BYTE   NewPIN[DATA_BLOCK_LEN]  = { 0 };
	BYTE   HashKey[DATA_BLOCK_LEN] = { 0 };
	BYTE   Random[DATA_BLOCK_LEN]  = { 0 };
	BYTE   EncData[128]            = { 0 };
	UINT   Status                  = STATUS_FAILED;
	PAPPLICATION  pApplication  = ( PAPPLICATION )hApplication;
	PReturnDataEx pRetData      = NULL;
	SHA1_CONTEXT  Context;

	EncData[0] = L_BYTE( pApplication->wAppID );
	EncData[1] = H_BYTE( pApplication->wAppID );
	// ªÒ»°ÀÊª˙ ˝
	g_Callback = CB_GeneralHandleProc;
	if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
		return STATUS_FAILED;
	pRetData = GetReturnDataEx();
	memset( Random, 0x00, DATA_BLOCK_LEN );
	memcpy( Random, pRetData->Data, RANDOM_LEN );
	// ≤…”√HASH-SHA1∂‘PINΩ¯––º”√‹£¨º”√‹∫Û ˝æ›µƒ«∞16∏ˆ◊÷Ω⁄Œ™√‹‘ø
    
//    BYTE OldPinEncData[DATA_BLOCK_LEN] = { 0 };
//    {
//        BYTE OldHashKey[DATA_BLOCK_LEN] = { 0 };
//        BYTE OldRandom[DATA_BLOCK_LEN]  = { 0 };
//        SHA1_CONTEXT  OldContext;
//        
//        memset( OldRandom, 0x00, DATA_BLOCK_LEN );
//        memcpy( OldRandom, pRetData->Data, RANDOM_LEN );
//        
//        memset( OldPIN, 0x00, DATA_BLOCK_LEN );
//        memcpy( OldPIN, szOldPin, strlen(szOldPin) );
//        SHA1_Init_Sunyard( &OldContext );
//        SHA1_Update_Sunyard( &OldContext, OldPIN, DATA_BLOCK_LEN );
//        SHA1_Final_Sunyard( &OldContext, OldHashKey );
//        SMS4_Init( OldHashKey );
//        SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, OldRandom, OldPinEncData, DATA_BLOCK_LEN, NULL );
//    }
    
//    BYTE NewPinEncData[DATA_BLOCK_LEN] = { 0 };
//    {
//        BYTE NewHashKey[DATA_BLOCK_LEN] = { 0 };
//        BYTE NewRandom[DATA_BLOCK_LEN]  = { 0 };
//        SHA1_CONTEXT  NewContext;
//        
//        memset( NewRandom, 0x00, DATA_BLOCK_LEN );
//        memcpy( NewRandom, pRetData->Data, RANDOM_LEN );
//        
//        memset( NewPIN, 0x00, DATA_BLOCK_LEN );
//        memcpy( NewPIN, szNewPin, strlen(szNewPin) );
//        SHA1_Init_Sunyard( &NewContext );
//        SHA1_Update_Sunyard( &NewContext, NewPIN, DATA_BLOCK_LEN );
//        SHA1_Final_Sunyard( &NewContext, NewHashKey );
//        SMS4_Init( NewHashKey );
//        SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, NewRandom, NewPinEncData, DATA_BLOCK_LEN, NULL );
//    }
    
	memset( OldPIN, 0x00, DATA_BLOCK_LEN );
	memcpy( OldPIN, szOldPin, strlen( szOldPin ) );
	SHA1_Init_Sunyard( &Context );
//	SHA1_Update_Sunyard( &Context, OldPinEncData, DATA_BLOCK_LEN );
    
	SHA1_Update_Sunyard( &Context, OldPIN, DATA_BLOCK_LEN );
	SHA1_Final_Sunyard( &Context, HashKey );
	//  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
	memset( NewPIN, 0x00, DATA_BLOCK_LEN );
	memcpy( NewPIN, szNewPin, strlen( szNewPin ) );
	SMS4_Init( HashKey );
//	SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, NewPinEncData, EncData + 2, DATA_BLOCK_LEN, NULL );
	SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, NewPIN, EncData + 2, DATA_BLOCK_LEN, NULL );
	g_Callback = NULL;
	Status = CMD_ChangePIN( ( BYTE )ulPINType, EncData, DATA_BLOCK_LEN + 2, HashKey, Random );

	if ( Status != STATUS_SUCCESS )
	{
		pRetData = GetReturnDataEx();
		*pulRetryCount = pRetData->Data[0];
		return SAR_FAIL;
	}
	//debug_log( JNI_MODULE, "\nSKF_ChangePIN Finish\n" );
	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        return SAR_OK;
    }
    else
    {
        return SAR_FAIL;
    }
}

// ÷¥––¥À√¸¡Ó«∞£¨–Ë“™‘§œ»—°‘Ò”¶”√£¨≤¢Õ®π˝»°ÀÊª˙ ˝√¸¡Ó÷¡…ŸªÒ»°8 ◊÷Ω⁄ÀÊª˙ ˝
ULONG DEVAPI SKF_VerifyPIN(
	HAPPLICATION hApplication,
	ULONG        ulPINType,
	LPSTR        szPIN,
	ULONG      * pulRetryCount )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szPIN == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
	BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
	BYTE Random[DATA_BLOCK_LEN]  = { 0 };
	BYTE EncData[128]            = { 0 };
	UINT Status = STATUS_FAILED;
	PReturnDataEx pRetData = NULL;
	SHA1_CONTEXT  Context;
	PAPPLICATION  pApplication = ( PAPPLICATION )hApplication;
	
	INT   i = 0;
	// √¸¡Ó±®Œƒ ˝æ›”ÚŒ™”¶”√ID ∫Õ π”√º”√‹√‹‘ø∂‘8 ◊÷Ω⁄ÀÊª˙ ˝Ω¯––º”√‹∫ÛµƒΩ·π˚◊È≥…
	// ªÒµ√”¶”√ID
	//debug_log( JNI_MODULE, "\npApplication->wAppID = %04x\n", pApplication->wAppID );
	EncData[0] = L_BYTE( pApplication->wAppID );
	EncData[1] = H_BYTE( pApplication->wAppID );
	// ªÒ»°ÀÊª˙ ˝
	g_Callback = CB_GeneralHandleProc;
	if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
		return STATUS_FAILED;
	pRetData = GetReturnDataEx();
	//debug_log( JNI_MODULE, "\npRetData = " );
	for ( i = 0; i < DATA_BLOCK_LEN; i++ )
		//debug_log( JNI_MODULE, "%02x ", pRetData->Data[i] );
	//debug_log( JNI_MODULE, "\n");
	memset( Random, 0x00, DATA_BLOCK_LEN );
	memcpy( Random, pRetData->Data, RANDOM_LEN );
	//debug_log( JNI_MODULE, "\nRandom = " );
	for ( i = 0; i < DATA_BLOCK_LEN; i++ )
		//debug_log( JNI_MODULE, "%02x ", Random[i] );
	//debug_log( JNI_MODULE, "\n");
	// ≤…”√HASH-SHA1∂‘PINΩ¯––º”√‹£¨º”√‹∫Û ˝æ›µƒ«∞16∏ˆ◊÷Ω⁄Œ™√‹‘ø
	memset( PIN, 0x00, DATA_BLOCK_LEN );
	memcpy( PIN, szPIN, strlen( szPIN ) );
	SHA1_Init_Sunyard( &Context );
	SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
	SHA1_Final_Sunyard( &Context, HashKey );
	//debug_log( JNI_MODULE, "\nHashKey = " );
	for ( i = 0; i < DATA_BLOCK_LEN; i++ )
		//debug_log( JNI_MODULE, "%02x ", HashKey[i] );
	//debug_log( JNI_MODULE, "\n");
	//  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
	SMS4_Init( HashKey );
	SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, EncData + 2, DATA_BLOCK_LEN, NULL );
	//debug_log( JNI_MODULE, "\nEncData = " );
	for ( i = 0; i < DATA_BLOCK_LEN + 2; i++ )
		//debug_log( JNI_MODULE, "%02x ", EncData[i] );
	//debug_log( JNI_MODULE, "\n");

	g_Callback = NULL;
	Status   = CMD_VerifyPIN( ( BYTE )ulPINType, EncData, DATA_BLOCK_LEN + 2 );
	//debug_log( JNI_MODULE, "\nStatus = %d\n", Status );
	if ( Status != STATUS_SUCCESS )
	{
		pRetData = GetReturnDataEx();
		*pulRetryCount = pRetData->Data[0]; // PIN¬Îµƒ÷ÿ ‘¥Œ ˝
		//debug_log( JNI_MODULE, "\nSKF_VerifyPIN Failed\n" );
		return SAR_FAIL;
	}
	//debug_log( JNI_MODULE, "\nSKF_VerifyPIN Finish\n" );

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        return SAR_OK;
    }
    else
    {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_UnblockPIN(
	HAPPLICATION hApplication,
	LPSTR        szAdminPIN,
	LPSTR        szNewUserPIN,
	ULONG      * pulRetryCount )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
        {
        return SAR_FAIL;
    }
	BYTE   AdminPIN[DATA_BLOCK_LEN] = { 0 };
	BYTE   UserPIN[DATA_BLOCK_LEN]  = { 0 };
	BYTE   HashKey[DATA_BLOCK_LEN]  = { 0 };
	BYTE   Random[DATA_BLOCK_LEN]   = { 0 };
	BYTE   EncData[128]             = { 0 };
	PAPPLICATION     pApplication = ( PAPPLICATION )hApplication;
	PReturnDataEx pRetData = NULL;
	SHA1_CONTEXT     Context;

	EncData[0] = L_BYTE( pApplication->wAppID );
	EncData[1] = H_BYTE( pApplication->wAppID );
	// ªÒ»°ÀÊª˙ ˝
	g_Callback = CB_GeneralHandleProc;
	if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
		return STATUS_FAILED;
	pRetData = GetReturnDataEx();
	memset( Random, 0x00, DATA_BLOCK_LEN );
	memcpy( Random, pRetData->Data, RANDOM_LEN );
	// ≤…”√HASH-SHA1∂‘PINΩ¯––º”√‹£¨º”√‹∫Û ˝æ›µƒ«∞16∏ˆ◊÷Ω⁄Œ™√‹‘ø
	memset( AdminPIN, 0x00, DATA_BLOCK_LEN );
	memcpy( AdminPIN, szAdminPIN, strlen( szAdminPIN ) );
	SHA1_Init_Sunyard( &Context );
	SHA1_Update_Sunyard( &Context, AdminPIN, DATA_BLOCK_LEN );
	SHA1_Final_Sunyard( &Context, HashKey );
	//  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
	memset( UserPIN, 0x00, DATA_BLOCK_LEN );
	memcpy( UserPIN, szNewUserPIN, strlen( szNewUserPIN ) );
	SMS4_Init( HashKey );
	SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, UserPIN, EncData + 2, DATA_BLOCK_LEN, NULL );
	g_Callback = NULL;
	if ( CMD_UnblockPIN( EncData, DATA_BLOCK_LEN + 2, HashKey, Random ) != STATUS_SUCCESS )
	{
		pRetData = GetReturnDataEx();
		*pulRetryCount = pRetData->Data[0]; // PIN¬Îµƒ÷ÿ ‘¥Œ ˝
		return SAR_FAIL;
	}

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_ClearSecureState( HAPPLICATION hApplication )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
        {
        return SAR_FAIL;
    }
	BYTE Blob[2] = { 0 };
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );

	if ( CMD_ClearSecureState( Blob, 2 ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}
/*****************************************/

/*************  ”¶”√π‹¿Ì**************/
// –Ë…Ë±∏»œ÷§Õ®π˝∫Û≤≈ø…“‘÷¥––¥À√¸¡Ó°£Õ¨“ª∏ˆ…Ë±∏÷–≤ª‘ –Ì¥Ê‘⁄œ‡Õ¨√˚≥∆µƒ”¶”√
ULONG DEVAPI SKF_CreateApplication( 
	DEVHANDLE      hDev,
	LPSTR          szAppName,
	LPSTR          szAdminPin,
	DWORD          dwAdminPinRetryCount,
	LPSTR          szUserPin,
	DWORD          dwUserPinRetryCount,
	DWORD          dwCreateFileRights,
	HAPPLICATION * phApplication )
{
    DebugAudioLog(@"");
	
	
	APPLICATIONINFO AppInfo;

	memset( &AppInfo, 0, sizeof( APPLICATIONINFO ) );
	//debug_log( JNI_MODULE, "\nszAppNameLen = %d\n", strlen( szAppName ) );
	memcpy( AppInfo.szApplicatinName, szAppName, strlen( szAppName ) );
	//debug_log( JNI_MODULE, "\n%s\n", AppInfo.szApplicatinName );
	memcpy( AppInfo.szAdminPin, szAdminPin, strlen( szAdminPin ) );
	memcpy( AppInfo.szUserPin, szUserPin, strlen( szUserPin ) );

	AppInfo.dwAdminPinRetryCount = dwAdminPinRetryCount;
	AppInfo.dwUserPinRetryCount  = dwUserPinRetryCount;
	AppInfo.dwCreateFileRights   = dwCreateFileRights;
	AppInfo.byContainerNum       = 16;   //“™«Û”¶”√÷ß≥÷µƒ»›∆˜ ˝¡ø
	AppInfo.byCertNum            = 16;   //“™«Û”¶”√÷ß≥÷µƒ÷§ È ˝¡ø
	AppInfo.wFileNum             = 256;  //“™«Û”¶”√÷ß≥÷µƒŒƒº˛ ˝¡ø
	if ( CMD_CreateApplication( ( BYTE * )&AppInfo, sizeof( APPLICATIONINFO ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        *phApplication = &AppInfo;
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
    
}

ULONG DEVAPI SKF_EnumApplication(
	DEVHANDLE hDev,	LPSTR     szAppName,
	ULONG   * pulSize )
{
    DebugAudioLog(@"");
	
	if ( CMD_EnumApplication( 0x0000 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (szAppName != NULL)
        {
            memcpy(szAppName, tmpReturn->Data, tmpReturn->Length);
        }
        
        if (pulSize != NULL)
        {
            *pulSize = tmpReturn->Length;
        }

        return SAR_OK;
    }
    return SAR_FAIL;
}

// –Ë…Ë±∏»œ÷§Õ®π˝∫Û≤≈ø…“‘÷¥––¥À√¸¡Ó
ULONG DEVAPI SKF_DeleteApplication( DEVHANDLE hDev, LPSTR szAppName )
{
    DebugAudioLog(@"");
	
	if (szAppName == NULL)
        {
        return SAR_FAIL;
    }
	if ( CMD_DeleteApplication( ( BYTE * )szAppName, strlen( szAppName ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_OpenApplication(
	DEVHANDLE      hDev,
	LPSTR          szAppName,
	HAPPLICATION * phApplication )
{
    DebugAudioLog(@"");
	
	if (szAppName == NULL)
        {
        return SAR_FAIL;
    }

	if ( CMD_OpenApplication( ( BYTE * )szAppName, strlen( szAppName ), 10 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //POPENAPPLICATION pInfo = NULL;
	//PReturnDataEx pRetData = NULL;
	//pRetData = GetReturnDataEx();
	//pInfo    = ( POPENAPPLICATION )( pRetData->Data );
	//debug_log( JNI_MODULE, "\n%08x, %02x, %02x, %04x, %04x\n", pInfo->dwCreateFileRights, pInfo->byMaxContainerNum,
	//	pInfo->byMaxCertNum, pInfo->wMaxFileNum, pInfo->wAppID );
	//memcpy( g_Application.szName, szAppName, strlen( szAppName ) );
	//g_Application.wAppID = pInfo->wAppID;
	//debug_log( JNI_MODULE, "\ng_Application.szName = %s\n", g_Application.szName );
	//debug_log( JNI_MODULE, "g_Application.wAppID = %04x", g_Application.wAppID );
    
    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if(tmpReturn->Status == STATUS_SUCCESS)
    { 
        //APPLICATION app;
        //memcpy(&app.wAppID,tmpReturn->Data+8,2);
        memcpy(&g_Application.wAppID,tmpReturn->Data+8,2);
        memcpy(g_Application.szName, szAppName, strlen(szAppName));
        //printf("SKF_OpenApplication:Data=%02x,%02x",g_Application.wAppID[0],g_Application.wAppID[1]);
        if (phApplication != NULL)
        {
             *phApplication = &g_Application;
        }
       
        //*phApplication = &g_Application;
        return SAR_OK;
    }

	return SAR_FAIL;
}

ULONG DEVAPI SKF_CloseApplication( HAPPLICATION hApplication )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE Data[2] = { 0 };
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Data[0] = L_BYTE( pApplication->wAppID );
	Data[1] = H_BYTE( pApplication->wAppID );

	if ( CMD_CloseApplication( Data, sizeof( Data ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}
/*****************************************/

/*************  Œƒº˛π‹¿Ì**************/
ULONG DEVAPI SKF_CreateFile(
	HAPPLICATION hApplication,
	LPSTR        szFileName,
	ULONG        ulFileSize,
	ULONG        ulReadRights,
	ULONG        ulWriteRights )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szFileName == NULL)
        {
        return SAR_FAIL;
    }
    
	FILEATTRIBUTE FileAttribute;
	PAPPLICATION  pApplication = ( PAPPLICATION )hApplication;

	memset( FileAttribute.FileName, 0, 40 );
	memcpy( FileAttribute.FileName, szFileName, strlen( szFileName ) );
	FileAttribute.FileSize    = ulFileSize;
	FileAttribute.ReadRights  = ulReadRights;
	FileAttribute.WriteRights = ulWriteRights;
       //LOGW("creat file d%d",sizeof( FileAttribute ) );
	if ( CMD_CreateFile( pApplication->wAppID, ( BYTE * )&FileAttribute, sizeof( FileAttribute ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_DeleteFile( HAPPLICATION hApplication, LPSTR szFileName )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szFileName == NULL)
        {
        return SAR_FAIL;
    }
    
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;
	if ( CMD_DeleteFile( pApplication->wAppID, ( BYTE * )szFileName, strlen( szFileName ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	return SAR_OK;
}

ULONG DEVAPI SKF_EnumFiles( HAPPLICATION hApplication, LPSTR szFileList, ULONG * pulSize )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
        {
        return SAR_FAIL;
    }
    
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	if ( CMD_EnumFiles( pApplication->wAppID, 0x0000 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (szFileList != NULL)
        {
            memcpy(szFileList, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulSize != NULL)
        {
            *pulSize = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_GetFileInfo(
	HAPPLICATION    hApplication,
	LPSTR           szFileName,
	FILEATTRIBUTE * pFileInfo )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szFileName == NULL)
        {
        return SAR_FAIL;
    }
    
	PAPPLICATION     pApplication = ( PAPPLICATION )hApplication;

	if ( CMD_GetFileInfo( pApplication->wAppID, ( BYTE * )szFileName, strlen( szFileName ), 0 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pFileInfo != NULL)
        {
            memcpy(&pFileInfo->FileSize, tmpReturn->Data, 4);
            memcpy(&pFileInfo->ReadRights, tmpReturn->Data + 4, 4);
            memcpy(&pFileInfo->WriteRights, tmpReturn->Data + 8, 4);
            memcpy(&pFileInfo->FileName, tmpReturn->Data+12, tmpReturn->Length-12);
        }
        
        return SAR_OK;
    }
    
	return SAR_FAIL;
}

ULONG DEVAPI SKF_ReadFile(
	HAPPLICATION hApplication,
	LPSTR        szFileName,
	ULONG        ulOffset,
	ULONG        ulSize,
	BYTE       * pbOutData,
	ULONG      * pulOutLen )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szFileName == NULL)
        {
        return SAR_FAIL;
    }
    
	READFILE         File;
	PAPPLICATION     pApplication = ( PAPPLICATION )hApplication;

	File.wAppID       = pApplication->wAppID;
	File.wOffset      = ( WORD )ulOffset;
	File.wFileNameLen = ( WORD )strlen( szFileName );
	memset( File.chFileName, 0, 40 );
	memcpy( File.chFileName, szFileName, strlen( szFileName ) );
	if ( CMD_ReadFile( ( BYTE * )&File, sizeof( READFILE ), ulSize ) != STATUS_SUCCESS )        
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if(tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbOutData != NULL)
        {
            memcpy(pbOutData, tmpReturn->Data, ulSize);
        }
        if (pulOutLen != NULL)
        {
            *pulOutLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;			
}

ULONG DEVAPI SKF_WriteFile(
	HAPPLICATION hApplication,
	LPSTR        szFileName,
	ULONG        ulOffset,
	BYTE       * pbData,
	ULONG        ulSize )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szFileName == NULL || pbData == NULL || ulSize <= 0)
        {
        return SAR_FAIL;
    }
    
	UINT         Status       = STATUS_FAILED;
	UINT         nLen         = 0;
	BYTE       * pData        = NULL;
	BYTE       * pTemp        = NULL;
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;
	WRITEFILE    File;
	
	nLen = strlen( szFileName ) + ulSize + 8;
	pData = ( BYTE * )calloc( nLen, sizeof( BYTE) );
	if(pData==NULL)
        {
		//LOGD("no memory");
	}
	nLen  = 0;

	pTemp = pData;
	File.wAppID = pApplication->wAppID;
	nLen = sizeof( File.wAppID );
	memcpy( pTemp, &( File.wAppID ), nLen );

	pTemp += nLen;
	File.wOffset = ( USHORT )ulOffset;
	nLen = sizeof( File.wOffset );
	memcpy( pTemp, &( File.wOffset ), nLen );

	pTemp += nLen;
	File.wFileNameLen = strlen( szFileName );
	nLen = sizeof( File.wFileNameLen );
	memcpy( pTemp, &( File.wFileNameLen ), nLen );

	pTemp += nLen;
	nLen = strlen( szFileName );
	memcpy( pTemp, szFileName, nLen );

	pTemp += nLen;
	File.wDataLen = ( USHORT )ulSize;
	nLen = sizeof( File.wDataLen );
	memcpy( pTemp, &( File.wDataLen ), nLen );

	pTemp += nLen;
	nLen = ulSize;
	memcpy( pTemp, pbData, nLen );

	pTemp += nLen;
	nLen = pTemp - pData;

	Status = CMD_WriteFile( pData, nLen );
	if(pData)
    {
		//LOGD("free memory");
		free( pData );
        pData = NULL;
		//LOGD("free memoryOK");
	}
	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}
/*****************************************/

/*************  »›∆˜π‹¿Ì**************/
ULONG DEVAPI SKF_CreateContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName,
	HCONTAINER * phContainer )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szContainerName == NULL)
        {
        return SAR_FAIL;
    }
    
	UINT Status    = STATUS_FAILED;
	BYTE Data[128] = { 0 };
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Data[0] = L_BYTE( pApplication->wAppID );
	Data[1] = H_BYTE( pApplication->wAppID );
	memcpy( Data + 2, szContainerName, strlen( szContainerName ) );

	Status = CMD_CreateContainer( Data, strlen( szContainerName ) + 2, 0x0002 );
	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;
  
    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        memcpy(g_Container.szName, szContainerName, strlen( szContainerName ));
        memcpy(&g_Container.wContainerID,tmpReturn->Data,2);
        if (phContainer != NULL)
        {
            *phContainer = &g_Container;
        }
        
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }

}

ULONG DEVAPI SKF_OpenContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName,
	HCONTAINER * phContainer )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szContainerName == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE         Data[128]    = { 0 };
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;
	//PReturnDataEx pRetData = NULL;

	Data[0] = L_BYTE( pApplication->wAppID );
	Data[1] = H_BYTE( pApplication->wAppID );
	memcpy( Data + 2, szContainerName, strlen( szContainerName ) );
	if ( CMD_OpenContainer( Data, strlen( szContainerName ) + 2, 0x0002 ) != STATUS_SUCCESS )
	{
		//*phContainer = NULL;
		return SAR_FAIL;
	}

    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        memcpy( g_Container.szName, szContainerName, strlen( szContainerName ) );
        memcpy(&g_Container.wContainerID,tmpReturn->Data,2);
        
        if (phContainer != NULL)
        {
            *phContainer = &g_Container;
        }
        

        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
	
}

ULONG DEVAPI SKF_CloseContainer( HCONTAINER hContainer )
{
    DebugAudioLog(@"");
	
	if (hContainer == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE Data[4] = { 0 };
	PCONTAINER pContainer = ( PCONTAINER )hContainer;

	Data[0] = L_BYTE( g_Application.wAppID );
	Data[1] = H_BYTE( g_Application.wAppID );
	Data[2] = L_BYTE( pContainer->wContainerID );
	Data[3] = H_BYTE( pContainer->wContainerID );

	if ( CMD_CloseContainer( Data, 4 ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
}

// –Ë“™ÕÍ…∆
ULONG DEVAPI SKF_EnumContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName,
	ULONG      * pulSize )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE         Data[2]      = { 0 };
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Data[0] = L_BYTE( pApplication->wAppID );
	Data[1] = H_BYTE( pApplication->wAppID );
	if ( CMD_EnumContainer( Data, 2 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if(tmpReturn->Status == STATUS_SUCCESS)
    {
        DebugAudioLog(@"");
	if (szContainerName != NULL)
        {
            memcpy(szContainerName, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulSize != NULL)
        {
            *pulSize = tmpReturn->Length;
        }
        
        return SAR_OK;	
    }
	return SAR_FAIL;	
}

ULONG DEVAPI SKF_DeleteContainer(
	HAPPLICATION hApplication,
	LPSTR        szContainerName )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szContainerName == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE         Data[128] = { 0 };
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Data[0] = L_BYTE( pApplication->wAppID );
	Data[1] = H_BYTE( pApplication->wAppID );
	memcpy( Data + 2, szContainerName, strlen( szContainerName ) );
	if ( CMD_DeleteContainer( Data, strlen( szContainerName ) + 2 ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
}

ULONG DEVAPI SKF_GetContainerInfo(
	HAPPLICATION    hApplication,
	LPSTR           szContainerName,
	CONTAINERINFO * pFileInfo )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || szContainerName == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE         Blob[512]    = { 0 };
	UINT         nLen         = 0;
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );
	memcpy( Blob + 2, szContainerName, strlen( szContainerName ) );
	nLen = strlen( szContainerName ) + 2;

	if ( CMD_GetContainerInfo( Blob, nLen, 0x000B ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
}

ULONG DEVAPI SKF_ImportCertificate(
	HAPPLICATION hApplication,
	BYTE         bCertificate,
	BYTE       * pbData,
	ULONG        ulDataLen )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL || pbData == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE         Blob[2048]   = { 0 };
	UINT         nLen         = 0;
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = bCertificate;
	*( ( ULONG * )( Blob + 5 ) ) = ulDataLen;
	memcpy( Blob + 9, pbData, ulDataLen );
	nLen = ulDataLen + 9;

	if ( CMD_ImportCertificate( Blob, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
}

ULONG DEVAPI SKF_ExportCertificate(
	HAPPLICATION hApplication,
	ULONG        ulExportType,
	ULONG      * ulRetDataLen,
	BYTE       * pbRetData )
{
    DebugAudioLog(@"");
	
	if (hApplication == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE         Blob[512]    = { 0 };
	UINT         nLen         = 0;
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	nLen = 4;

	if ( CMD_ExportCertificate( ( BYTE )ulExportType, Blob, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
}
/*****************************************/

/*************  √‹¬Î∑˛ŒÒ**************/
ULONG DEVAPI SKF_GenRandom(
	DEVHANDLE hDev,
	BYTE    * pbRandom,
	ULONG     ulRandomLen )
{
    DebugAudioLog(@"");
	
	if (ulRandomLen <= 0.0)
        {
        return SAR_FAIL;
    }
    
	if ( CMD_GenRandom( ulRandomLen ) != STATUS_SUCCESS )
		return SAR_FAIL;
    
    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == 0x0001)
        {
        if (pbRandom != NULL && ulRandomLen > 0) 
        {
            memcpy(pbRandom,tmpReturn->Data,tmpReturn->Length);
        }
        return SAR_OK;
    }
    else 
    {
        return SAR_FAIL;
    }
}

//#ifdef RSA_INTERFACE
ULONG DEVAPI SKF_GenExtRSAKey(
	DEVHANDLE           hDev,
	ULONG               ulBitsLen,
	RSAPRIVATEKEYBLOB * pBlob )
{
    DebugAudioLog(@"");
	
	
	WORD Blob = ( WORD )ulBitsLen;

	//debug_log( JNI_MODULE, "\nulBitsLen = %08x, Blob = %08x\n", ulBitsLen, Blob );

	if ( CMD_GenExtRSAKey( ( BYTE * )&Blob, sizeof( WORD ), ulBitsLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == 0x0001)
        {
        if (pBlob != NULL)
        {
            pBlob->BitLen = ulBitsLen;
            memcpy(pBlob->Modulus,tmpReturn->Data, ulBitsLen/8);
            memcpy(pBlob->PublicExponent, tmpReturn->Data+ulBitsLen/8, ulBitsLen/256);
            memcpy(pBlob->PrivateExponent, tmpReturn->Data +ulBitsLen/8+ulBitsLen/256, ulBitsLen/8);
            memcpy(pBlob->Prime1, tmpReturn->Data +ulBitsLen/8+ulBitsLen/256+ulBitsLen/8, ulBitsLen/16);
            memcpy(pBlob->Prime2, tmpReturn->Data + ulBitsLen/8+ulBitsLen/256+ulBitsLen/8+ulBitsLen/16, ulBitsLen/16);
            memcpy(pBlob->Prime1Exponent, tmpReturn->Data + ulBitsLen/8+ulBitsLen/256+ulBitsLen/8+2*ulBitsLen/16, ulBitsLen/16);
            memcpy(pBlob->Prime2Exponent, tmpReturn->Data + ulBitsLen/8+ulBitsLen/256+ulBitsLen/8+3*ulBitsLen/16, ulBitsLen/16);
            memcpy(pBlob->Coefficient, tmpReturn->Data + ulBitsLen/8+ulBitsLen/256+ulBitsLen/8+4*ulBitsLen/16, ulBitsLen/16);
        }
        
        return SAR_OK;

    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_GenRSAKeyPair(
	HCONTAINER hContainer,
	ULONG ulBitsLen,
	RSAPUBLICKEYBLOB *pBlob )
{
    DebugAudioLog(@"");
	
	UINT nRet = 0;
	WORD Blob[3] = { 0 };
	PCONTAINER   pContainer = ( PCONTAINER )hContainer;
	PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
    
    if (pContainer == NULL || pApplication == NULL)
        {
        return SAR_FAIL;
    }

	Blob[0] = ( WORD )pApplication->wAppID;
	Blob[1] = ( WORD )pContainer->wContainerID;
	Blob[2] = ( WORD )ulBitsLen;
	//≤˙…˙√‹‘ø∂‘
	if ( CMD_GenerateRSAKeyPair( ( BYTE * )Blob, 6, nRet ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == 0x0001)
        {
        if (pBlob != NULL) 
        {
            pBlob->BitLen = ulBitsLen;
            memcpy(pBlob->Modulus, tmpReturn->Data, ulBitsLen/8);//128,256
            memcpy(pBlob->PublicExponent, tmpReturn->Data + 128, ulBitsLen/8);
        }
        return SAR_OK;
        
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_ImportRSAKeyPair(
	HCONTAINER hContainer,
	ULONG      ulSymAlgId,
	BYTE     * pbWrappedKey,
	ULONG      ulWrappedKeyLen,
	BYTE     * pbEncryptedData,
	ULONG      ulEncryptedDataLen )
{
    DebugAudioLog(@"");
	
	BYTE       * pBlob        = ( BYTE * )calloc( sizeof( IMPORTRSAKEYPAIRBLOB ), sizeof( BYTE ) );
	BYTE       * pTemp        = NULL;
	UINT         nLen         = 0;
	UINT         Status       = STATUS_FAILED;
	ULONG        ulBitLens    = 1024;
	PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
	PCONTAINER   pContainer   = ( PCONTAINER )hContainer;
    
    if (pContainer == NULL || pApplication == NULL)
    {
        free(pBlob);
        pBlob = NULL;
        return SAR_FAIL;
    }

	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( pApplication->wAppID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( pContainer->wContainerID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulSymAlgId, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulWrappedKeyLen, nLen );
	pTemp += nLen;
	nLen   = ulWrappedKeyLen;
	memcpy( pTemp, pbWrappedKey, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulBitLens, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulEncryptedDataLen, nLen );
	pTemp += nLen;
	nLen   = ulEncryptedDataLen;
	memcpy( pTemp, pbEncryptedData, nLen );
	nLen += pTemp - pBlob;

	Status = CMD_ImportRSAKeyPair( pBlob, nLen );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
}

    
ULONG DEVAPI SKF_RSASignData(
	HCONTAINER hContainer,
	BYTE     * pbData,
	ULONG      ulDataLen,
	BYTE     * pbSignature,
	ULONG    * pulSignLen,
    LPSTR        szPIN,
    UINT       CertFlag)
{
    DebugAudioLog(@"");
	
	
    BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
    BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
    BYTE Random[DATA_BLOCK_LEN]  = { 0 };
    BYTE EncData[128]            = { 0 };
    PReturnDataEx pRetData = NULL;
    SHA1_CONTEXT  Context;
    
	BYTE         bP1          = 2;
	BYTE         bP2          = 4;
    if(CertFlag == 1)
    {
        bP1          = 3;
        bP2          = 4;
    }
    else
    {
        bP1          = 3;
        bP2          = 2;
    }
    //BYTE         bP1          = pbSignature[0];
	//BYTE         bP2          = pbSignature[1];
    BYTE         Blob[2060]    = { 0 };
	PCONTAINER   pContainer   = ( PCONTAINER )hContainer;
	PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
    
    if (pContainer == NULL || pApplication == NULL || pbData == NULL || ulDataLen == 0)
        {
        return SAR_FAIL;
    }

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );
	Blob[2] = L_BYTE( pContainer->wContainerID );
	Blob[3] = H_BYTE( pContainer->wContainerID );
    
    
    INT i = 0;
    /*
     g_Callback = CB_GeneralHandleProc;
     if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
     {
     return STATUS_FAILED;
     }
     pRetData = GetReturnDataEx();
     memset( Random, 0x00, DATA_BLOCK_LEN );
     memcpy( Random, pRetData->Data, RANDOM_LEN );
     
     memset( PIN, 0x00, DATA_BLOCK_LEN );
     memcpy( PIN, szPIN, strlen( szPIN ) );
     SHA1_Init( &Context );
     SHA1_Update( &Context, PIN, DATA_BLOCK_LEN );
     SHA1_Final( &Context, HashKey );
     
     SMS4_Init( HashKey );
     SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, EncData + 2, DATA_BLOCK_LEN, NULL );
     
     g_Callback = NULL;
     */
    
    g_Callback = CB_GeneralHandleProc;
    if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
        return STATUS_FAILED;
    pRetData = GetReturnDataEx();
    //debug_log( JNI_MODULE, "\npRetData = " );
    for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        //debug_log( JNI_MODULE, "%02x ", pRetData->Data[i] );
        //debug_log( JNI_MODULE, "\n");
        memset( Random, 0x00, DATA_BLOCK_LEN );
    memcpy( Random, pRetData->Data, RANDOM_LEN );
    //debug_log( JNI_MODULE, "\nRandom = " );
    for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        //debug_log( JNI_MODULE, "%02x ", Random[i] );
        //debug_log( JNI_MODULE, "\n");
        // ≤…”√HASH-SHA1∂‘PINΩ¯––º”√‹£¨º”√‹∫Û ˝æ›µƒ«∞16∏ˆ◊÷Ω⁄Œ™√‹‘ø
        memset( PIN, 0x00, DATA_BLOCK_LEN );
    memcpy( PIN, szPIN, strlen( szPIN ) );
    SHA1_Init_Sunyard( &Context );
    SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
    SHA1_Final_Sunyard( &Context, HashKey );
    //debug_log( JNI_MODULE, "\nHashKey = " );
    for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        //debug_log( JNI_MODULE, "%02x ", HashKey[i] );
        //debug_log( JNI_MODULE, "\n");
        //  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
        SMS4_Init( HashKey );
    SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, EncData, DATA_BLOCK_LEN, NULL );
    //debug_log( JNI_MODULE, "\nEncData = " );
    for ( i = 0; i < DATA_BLOCK_LEN + 2; i++ )
        //debug_log( JNI_MODULE, "%02x ", EncData[i] );
        //debug_log( JNI_MODULE, "\n");
        
        g_Callback = NULL;
    
    memcpy( Blob + 4, pbData, ulDataLen );
    memcpy(Blob + 4 + ulDataLen, EncData, DATA_BLOCK_LEN);
    
    for (int j = 0;  j < (DATA_BLOCK_LEN); j++)
    {
        printf("EncData:%02x\n",EncData[j]);
    }
    if ( CMD_RSASignData( bP1, bP2, Blob, ulDataLen + 4 + 16) != STATUS_SUCCESS )
        return SAR_FAIL;
    
//	memcpy( Blob + 4, pbData, ulDataLen );
//    //if((bP1<1)||(bP1>2))bP1=2;
//	//if((bP2<1)||(bP2>4))bP1=2;
//	if ( CMD_RSASignData( bP1, bP2, Blob, ulDataLen + 4 ) != STATUS_SUCCESS )
//		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbSignature != NULL)
        {
            memcpy(pbSignature, tmpReturn->Data+6, 128);
            printf("pbSignature:\n");
            for(int i=0; i<128; i++)
            {
                printf("%02x ", pbSignature[i]);
            }
            printf("\n");
        }
        if (pulSignLen != NULL)
        {
            *pulSignLen = 128;
        }
        return SAR_OK;
        
    }
	return SAR_FAIL;
}
    
    //++++++++++++++++++++++++
    ULONG DEVAPI SKF_ECCSignData_new(
                                 HCONTAINER hContainer,
                                 BYTE     * pbData,
                                 ULONG      ulDataLen,
                                 BYTE     * pbSignature,
                                 ULONG    * pulSignLen,
                                 LPSTR        szPIN,
                                 UINT       CertFlag)
    {
        DebugAudioLog(@"");
        
        
        BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
        BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
        BYTE Random[DATA_BLOCK_LEN]  = { 0 };
        BYTE EncData[128]            = { 0 };
        PReturnDataEx pRetData = NULL;
        SHA1_CONTEXT  Context;
        
        BYTE         bP1          = CertFlag;
        
        BYTE         Blob[2060]    = { 0 };
        PCONTAINER   pContainer   = ( PCONTAINER )hContainer;
        PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
        
        if (pContainer == NULL || pApplication == NULL || pbData == NULL || ulDataLen == 0)
        {
            return SAR_FAIL;
        }
        
        Blob[0] = L_BYTE( pApplication->wAppID );
        Blob[1] = H_BYTE( pApplication->wAppID );
        Blob[2] = L_BYTE( pContainer->wContainerID );
        Blob[3] = H_BYTE( pContainer->wContainerID );
        
        
        INT i = 0;
        
        g_Callback = CB_GeneralHandleProc;
        if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
            return STATUS_FAILED;
        pRetData = GetReturnDataEx();
        
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            memset( Random, 0x00, DATA_BLOCK_LEN );
        }
        memcpy( Random, pRetData->Data, RANDOM_LEN );
        
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            memset( PIN, 0x00, DATA_BLOCK_LEN );
        }
        memcpy( PIN, szPIN, strlen( szPIN ) );
        SHA1_Init_Sunyard( &Context );
        SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
        SHA1_Final_Sunyard( &Context, HashKey );
        
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            SMS4_Init( HashKey );
        }
        SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, EncData, DATA_BLOCK_LEN, NULL );
        
//        for ( i = 0; i < DATA_BLOCK_LEN + 2; i++ )            
        g_Callback = NULL;
        
        memcpy( Blob + 4, pbData, ulDataLen );
        memcpy(Blob + 4 + ulDataLen, EncData, DATA_BLOCK_LEN);
        
        for (int j = 0;  j < (DATA_BLOCK_LEN); j++)
        {
            printf("EncData:%02x\n",EncData[j]);
        }
        
        if(CMD_ECCSignData(bP1, Blob, ulDataLen+4+16, 0) != STATUS_SUCCESS)
            return SAR_FAIL;
        
        //modify by wangzhong at 2012-6-26
        ReturnDataEx *tmpReturn = GetReturnDataEx();
        if (tmpReturn->Status == STATUS_SUCCESS)
        {
            if (pbSignature != NULL)
            {
                memcpy(pbSignature, tmpReturn->Data+6, 128);
                printf("pbSignature:\n");
                for(int i=0; i<128; i++)
                {
                    printf("%02x ", pbSignature[i]);
                }
                printf("\n");
            }
            if (pulSignLen != NULL)
            {
                *pulSignLen = 128;
            }
            return SAR_OK;
            
        }
        return SAR_FAIL;
    }
    //++++++++++++++++++++++++

//ULONG DEVAPI SKF_RSAVerify(
//	RSAPUBLICKEYBLOB * pRSAPubKeyBlob,
//	BYTE             * pbData,
//	ULONG              ulDataLen,
//	BYTE             * pbSignature,
//	ULONG              ulSignLen )
//{
//	return SAR_OK;
//}

    
    
ULONG DEVAPI SKF_RSAExportSessionKey(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	RSAPUBLICKEYBLOB * pPubKey,
	BYTE             * pbData,
	ULONG            * pulDataLen,
	HANDLE           * phSessionKey )
{
    DebugAudioLog(@"");
	
	BYTE       * pBlob        = ( BYTE * )calloc( sizeof( RSAEXPORTSESSIONKEY ), sizeof( BYTE ) );
    BYTE       * pTemp        = NULL;
	UINT         nLen         = 0;
	UINT         Status       = STATUS_FAILED;
	ULONG        ulBitLens    = 0x01000100;
	PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
	PCONTAINER   pContainer   = ( PCONTAINER )hContainer;
    
    if (pContainer == NULL || pApplication == NULL ||pPubKey == NULL)
    {
        free(pBlob);
        pBlob = NULL;
        return SAR_FAIL;
    }
	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( pApplication->wAppID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( pContainer->wContainerID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulAlgId, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( pPubKey->BitLen ), nLen );
	pTemp += nLen;
	nLen   = pPubKey->BitLen / 8;
	memcpy( pTemp, &(pPubKey->Modulus), 64 );//64 no 128 
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulBitLens, nLen );
	nLen += pTemp - pBlob;
	Status = CMD_RSAExportSessionKey( pBlob, nLen, 0 );
	free( pBlob );
    pBlob = NULL;
	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (phSessionKey != NULL)
        {
            memcpy(phSessionKey, tmpReturn->Data, 2);
        }
        if (pbData != NULL)
        {
            memcpy(pbData, tmpReturn->Data+2, 128);
            
        }
        if (pulDataLen != NULL)
        {
            *pulDataLen = 128;
        }
        return SAR_OK;
    }
    return SAR_FAIL;
}
    

ULONG DEVAPI SKF_DestroySessionKey(HCONTAINER hContainer,BYTE *pKeyId,INT keyIdLen)
{
    DebugAudioLog(@"");
	
	BYTE *pBlob = (BYTE*)calloc(6,sizeof(BYTE));
    BYTE *pTemp = NULL;
    UINT nLen = 0;
    UINT Status = STATUS_FAILED;
    PAPPLICATION pApplication = (PAPPLICATION)&g_Application;
    PCONTAINER pContainer = (PCONTAINER)hContainer;
    
    if (pContainer == NULL || pApplication == NULL)
    {
        free(pBlob);
        pBlob = NULL;
        return SAR_FAIL;
    }
    
    pTemp = pBlob;
    nLen = sizeof(WORD);
    memcpy(pTemp,&(pApplication->wAppID),2);
    pTemp += 2;
    nLen = sizeof(WORD);
    memcpy(pTemp,&pContainer->wContainerID,2);
    pTemp += 2;
    nLen = sizeof(WORD);
    memcpy(pTemp,pKeyId,2);
    Status = CMD_DestorySessionKey(pBlob,6,0);
    free(pBlob);
    pBlob = NULL;
    if(Status != STATUS_SUCCESS)
        return SAR_FAIL;
    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }	
        
}


ULONG DEVAPI SKF_ExtRSAPubKeyOperation(
	DEVHANDLE          hDev,
	RSAPUBLICKEYBLOB * pRSAPubKeyBlob,
	BYTE             * pbInput,
	ULONG              ulInputLen,
	BYTE             * pbOutput,
	ULONG            * pulOutputLen )
{
    DebugAudioLog(@"");
	
	BYTE   Blob[2048] = { 0 };
	BYTE   KeyType    = 0;  //0 «©√˚; 1 º”√‹
	BYTE   OpType     = 1;  // 0 ÀΩ‘øΩ‚√‹£ª1 π´‘øº”√‹
	//BYTE * pTemp      = ( BYTE * )pRSAPubKeyBlob;
	UINT   nLen       = 0;
	PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
	PCONTAINER   pContainer   = ( PCONTAINER )&g_Container;

    if (pContainer == NULL || pApplication == NULL || pbInput == NULL)
        {
        return SAR_FAIL;
    }
	//KeyType = pTemp[0];
	//OpType  = pTemp[1];

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );
	Blob[2] = L_BYTE( pContainer->wContainerID );
	Blob[3] = H_BYTE( pContainer->wContainerID );
	memcpy( Blob + 4, pbInput, ulInputLen );
	nLen = ulInputLen + 4;

	if ( CMD_ExtRSAKeyOperation( KeyType, OpType, Blob, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbOutput != NULL)
        {
            memcpy(pbOutput,tmpReturn->Data+4,tmpReturn->Length-4);
            
        }
        if (pulOutputLen != NULL)
        {
             *pulOutputLen = tmpReturn->Length-4;//tmpReturn->Length;
        }
       
        return SAR_OK;
        
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_ExtRSAPriKeyOperation(
	DEVHANDLE           hDev,
	RSAPRIVATEKEYBLOB * pRSAPriKeyBlob,
	BYTE              * pbInput,
	ULONG               ulInputLen,
	BYTE              * pbOutput,
	ULONG             * pulOutputLen )
{
    DebugAudioLog(@"");
	
	BYTE   Blob[2048] = { 0 };
	BYTE   KeyType    = 0;  // 0 «©√˚; 1 º”√‹
	BYTE   OpType     = 0;  // 0 ÀΩ‘øΩ‚√‹£ª1 π´‘øº”√‹
	BYTE * pTemp      = ( BYTE * )pRSAPriKeyBlob;
	UINT   nLen       = 0;
	PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
	PCONTAINER   pContainer   = ( PCONTAINER )&g_Container;
    
    if (pContainer == NULL || pApplication == NULL || pbInput == NULL)
        {
        return SAR_FAIL;
    }
    
	KeyType = pTemp[0];
	OpType  = pTemp[1];

	Blob[0] = L_BYTE( pApplication->wAppID );
	Blob[1] = H_BYTE( pApplication->wAppID );
	Blob[2] = L_BYTE( pContainer->wContainerID );
	Blob[3] = H_BYTE( pContainer->wContainerID );
	memcpy( Blob + 4, pbInput, ulInputLen );
	nLen = ulInputLen + 4;

	if ( CMD_ExtRSAKeyOperation( KeyType, OpType, Blob, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbOutput != NULL)
        {
            memcpy(pbOutput,tmpReturn->Data, tmpReturn->Length);
            
        }
        if (pulOutputLen != NULL)
        {
            *pulOutputLen = tmpReturn->Length;
        }
        
        return SAR_OK;
        
    }
	return SAR_FAIL;

}
//#endif

// GenECCKeyPair √¸¡Ó”√”⁄‘⁄µ±«∞”¶”√µƒµ±«∞»›∆˜÷–…˙≥…ECC «©√˚√‹‘ø∂‘≤¢ ‰≥ˆ«©√˚π´‘ø°£
// –Ë”√ªß»œ÷§Õ®π˝∫Û≤≈ø…“‘÷¥––¥À√¸¡Ó°£
ULONG DEVAPI SKF_GenECCKeyPair(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pBlob )
{
    DebugAudioLog(@"");
	
	PCONTAINER    pContainer = ( PCONTAINER )hContainer;
    if (pContainer == NULL)
        {
        return SAR_FAIL;
    }
    
	UINT          nRetLen    = 0;
	//UINT          Status     = STATUS_FAILED;
	//PReturnDataEx pRetData   = NULL;
	ECCKEYPAIR    ECCKeyPair;
    //printf("%lu",&g_Application.wAppID);

	ECCKeyPair.wAppID       = g_Application.wAppID;
    
	ECCKeyPair.wContainerID = pContainer->wContainerID;
	ECCKeyPair.ulBits       = ECC_MAX_MODULUS_BITS_LEN;

	if ( CMD_GenECCKeyPair( ( BYTE * )&ECCKeyPair, sizeof( ECCKEYPAIR ), nRetLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//
//	pBlob->AlgID  = ulAlgId;
//	pBlob->BitLen = ECC_MAX_MODULUS_BITS_LEN;
//	memcpy( pBlob->XCoordinate, pRetData->Data, ECC_MAX_XCOORDINATE_LEN );
//	memcpy( pBlob->YCoordinate, pRetData->Data + ECC_MAX_XCOORDINATE_LEN, ECC_MAX_YCOORDINATE_LEN );

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pBlob != NULL)
        {
            memcpy(pBlob->XCoordinate, tmpReturn->Data, 32);
            memcpy(pBlob->YCoordinate, tmpReturn->Data+32, 32);
            pBlob->BitLen = tmpReturn->Length;// 256;
        }
        
        
        return SAR_OK;
        
    }
	return SAR_FAIL;
}

// –Ë”√ªß»œ÷§Õ®π˝∫Û≤≈ø…“‘÷¥––¥À√¸¡Ó
ULONG DEVAPI SKF_ImportECCKeyPair(
	HCONTAINER hContainer,
	ULONG      ulSymAlgId,
	BYTE     * pbWrappedKey,
	ULONG      ulWrappedKeyLen,
	BYTE     * pbEncryptedData,
	ULONG      ulEncryptedDataLen )
{

        UINT  nCmdLen;
        BYTE CMD_BUF[512];
        ULONG PriKeyByteLen = 0, pubKeyByteLen = 0, cipherLen = 0;
    
        PCONTAINER         pContainer  = ( PCONTAINER )hContainer;
        ENVELOPEDKEYBLOB * pEnvBlob = (ENVELOPEDKEYBLOB *)pbWrappedKey;
        ECCCIPHERBLOB * pCipherBlob = (ECCCIPHERBLOB *)pbEncryptedData;
        
        if (pContainer == NULL || pEnvBlob == NULL || pCipherBlob == NULL)
        {
            return SAR_FAIL;
        }
    
        PriKeyByteLen = pEnvBlob->ulBits / 8;
        
        memcpy(CMD_BUF, &g_Application.wAppID, 2);
        memcpy(CMD_BUF + 2, &pContainer->wContainerID, 2);
        memcpy(CMD_BUF + 2 + 2, &pEnvBlob->Version, 4);
        memcpy(CMD_BUF + 2 + 2 + 4, &pEnvBlob->ulSymmAlgID, 4);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4, &pEnvBlob->ulBits, 4);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4, &PriKeyByteLen, 4);
        
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4, &pEnvBlob->cbEncryptedPriKey, PriKeyByteLen);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen, &pEnvBlob->PubKey.XCoordinate, PriKeyByteLen);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 2, &pEnvBlob->PubKey.YCoordinate, PriKeyByteLen);
        
        pubKeyByteLen = pEnvBlob->ulBits / 8;
        //pubKeyByteLen = 32;
        //cipherLen = pCipherBlob->CipherLen;
        cipherLen = 16;
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3, &pEnvBlob->ulBits, 4);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3 + 4, &pCipherBlob->XCoordinate, pubKeyByteLen);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3 + 4 + pubKeyByteLen, &pCipherBlob->YCoordinate, pubKeyByteLen);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3 + 4 + pubKeyByteLen * 2, &pCipherBlob->HASH, 32);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3 + 4 + pubKeyByteLen * 2 + 32, &cipherLen, 4);
        memcpy(CMD_BUF + 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3 + 4 + pubKeyByteLen * 2 + 32 + 4, &pCipherBlob->Cipher, cipherLen);
        
        nCmdLen = 2 + 2 + 4 + 4 + 4 + 4 + PriKeyByteLen * 3 + 4 + pubKeyByteLen * 2 + 32 + 4 + cipherLen;
        //nRet = CMD_ImportECCKeyPair(phContainer->phDev, CMD_BUF, nCmdLen);
    if ( CMD_ImportECCKeyPair( CMD_BUF, nCmdLen ) != STATUS_SUCCESS )
        return SAR_FAIL;
    
    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }

}

ULONG DEVAPI SKF_ECCSignData(
	HCONTAINER        hContainer,
	BYTE            * pbData,
	ULONG             ulDataLen,
	PECCSIGNATUREBLOB pSignature )
{
    DebugAudioLog(@"");
	
	if (hContainer == NULL || pbData == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE * pBlob  = ( BYTE * )calloc( ulDataLen + 4, sizeof( BYTE ) );
	BYTE * pTemp  = NULL;
	UINT   nLen   = 0;
	UINT   Status = STATUS_FAILED;

	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( g_Application.wAppID ), nLen );
	pTemp += nLen;
	memcpy( pTemp, &( g_Container.wContainerID ), nLen );
	pTemp += nLen;
	memcpy( pTemp, pbData, ulDataLen );
	nLen = nLen+nLen+ulDataLen;

	//LOGW("ECC SignData %d",nLen);
	Status = CMD_ECCSignData( 2, pBlob, nLen, 0x0000 );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pSignature != NULL)
        {
            memcpy(pSignature->r, tmpReturn->Data+4,32);
            memcpy(pSignature->s, tmpReturn->Data+36,32);
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_ECCVerify(
	DEVHANDLE          hDev,
	ECCPUBLICKEYBLOB * pECCPubKeyBlob,
	BYTE             * pbData,
	ULONG              ulDataLen,
	PECCSIGNATUREBLOB  pSignature )
{
    DebugAudioLog(@"");
	
	if (pECCPubKeyBlob == NULL || pbData == NULL || pSignature == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE * pBlob  = ( BYTE * )calloc( sizeof( ECCVERIFY ) + ulDataLen, sizeof( BYTE ) );
	BYTE * pTemp  = NULL;
	UINT   nLen   = 0;
	UINT   Status = STATUS_FAILED;

	pTemp = pBlob;
	nLen  = sizeof( ULONG );
	memcpy( pTemp, &( pECCPubKeyBlob->BitLen ), nLen );
	pTemp += nLen;
	nLen   = pECCPubKeyBlob->BitLen / 8;
	memcpy( pTemp, pECCPubKeyBlob->XCoordinate, nLen );
	pTemp += nLen;
	nLen   = pECCPubKeyBlob->BitLen / 8;
	memcpy( pTemp, pECCPubKeyBlob->YCoordinate, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulDataLen, nLen );
	pTemp += nLen;
	nLen   = ulDataLen;
	memcpy( pTemp, pbData, nLen );
	pTemp += nLen;
	nLen   = pECCPubKeyBlob->BitLen / 8;
	memcpy( pTemp, pSignature->r, nLen );
	pTemp += nLen;
	nLen   = pECCPubKeyBlob->BitLen / 8;
	memcpy( pTemp, pSignature->s, nLen );
	nLen += pTemp - pBlob;

	Status = CMD_ECCVerify( pBlob, nLen );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_ECCExportSessionKey(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pPubKey,
	PECCCIPHERBLOB     pData,
	HANDLE           * phSessionKey )
{

    //UINT nRet;
	BYTE CMD_BUF[1024];//, pOut[1024];
	UINT nByteLen = 0, nCmdLen = 0;
	//ULONG ulBitLen = 0;
    if (hContainer == NULL || pPubKey == NULL)
        {
        return SAR_FAIL;
    }
    
	PCONTAINER   pContainer = ( PCONTAINER )hContainer;    //	KEYHANDLE * pKeyHandle = *(KEYHANDLE * *)phSessionKey;
  
	nByteLen = pPubKey->BitLen / 8;
    
	memcpy(CMD_BUF, &g_Application.wAppID, 2);
	nCmdLen += 2;
	memcpy(CMD_BUF + 2, &pContainer->wContainerID, 2);
	nCmdLen += 2;
	memcpy(CMD_BUF + 2 + 2, &pPubKey->BitLen, 4);
	nCmdLen += 4;
	memcpy(CMD_BUF + 2 + 2 + 4, pPubKey->XCoordinate, nByteLen);
	nCmdLen += nByteLen;
	memcpy(CMD_BUF + 2 + 2 + 4 + nByteLen, pPubKey->YCoordinate, nByteLen);
	nCmdLen += nByteLen;
	memcpy(CMD_BUF + 2 + 2 + 4 + nByteLen * 2, &ulAlgId, 4);
	nCmdLen += 4;
    if ( CMD_ECCExportSessionKey( CMD_BUF,nCmdLen, 0x0000 ) != STATUS_SUCCESS )
        return SAR_FAIL;
    
    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pData != NULL)
        {
            memcpy(&pData->HASH, tmpReturn->Data,32);
            memcpy(&pData->CipherLen, tmpReturn->Data+32,4);
            memcpy(&pData->Cipher, tmpReturn->Data+36,pData->CipherLen);
            memcpy(&pData->BitLen, tmpReturn->Data+38+pData->CipherLen,4);
            memcpy(&pData->XCoordinate, tmpReturn->Data+42+pData->CipherLen,pData->BitLen/8);
            memcpy(&pData->YCoordinate, tmpReturn->Data+42+pData->CipherLen+pData->BitLen/8,pData->BitLen/8);
        }
        
        
// another opertion;        
//        memcpy(&pData->BitLen,tmpReturn->Data, 4);
//        memcpy(&pData->XCoordinate, tmpReturn->Data + 4,32);
//        memcpy(&pData->YCoordinate, tmpReturn->Data + 36, 32);
//        memcpy(&pData->HASH, tmpReturn->Data+ 68 , 32);
//        memcpy(&pData->CipherLen, tmpReturn->Data + 100, 4);
//        memcpy(&pData->Cipher, tmpReturn->Data + 104, 16);
        if (phSessionKey != NULL)
        {
            WORD* wSessionKeyID;
            memcpy(&wSessionKeyID, tmpReturn->Data+pData->CipherLen+36, 2);
            phSessionKey = (HANDLE*)wSessionKeyID;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;


}

ULONG DEVAPI SKF_ExtECCEncrypt(
	DEVHANDLE          hDev,
	ECCPUBLICKEYBLOB * pECCPubKeyBlob,
	BYTE             * pbPlainText,
	ULONG              ulPlainTextLen,
	PECCCIPHERBLOB     pCipherText )
{
    DebugAudioLog(@"");
	
	if (pECCPubKeyBlob == NULL || pbPlainText == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE             * pBlob    = ( BYTE * )calloc( sizeof( EXTECCENCRYPT ) + ulPlainTextLen, sizeof( BYTE ) );
	BYTE             * pTemp    = NULL;
	UINT               nLen     = 0;
	UINT               Status   = STATUS_FAILED;
	//PEXTECCENCRYPTINFO pInfo    = NULL;
	//PReturnDataEx      pRetData = NULL;

	pTemp = pBlob;
	nLen  = sizeof( ULONG );
	memcpy( pTemp, &( pECCPubKeyBlob->BitLen ), nLen );
	pTemp += nLen;
	nLen   = pECCPubKeyBlob->BitLen / 8;
	memcpy( pTemp, pECCPubKeyBlob->XCoordinate, nLen );
	pTemp += nLen;
	nLen   = pECCPubKeyBlob->BitLen / 8;
	memcpy( pTemp, pECCPubKeyBlob->YCoordinate, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulPlainTextLen, nLen );
	pTemp += nLen;
	nLen   = ulPlainTextLen;
	memcpy( pTemp, pbPlainText, nLen );
	nLen += pTemp - pBlob;

	Status = CMD_ExtECCEncrypt( pBlob, nLen, 0x0000 );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//	pInfo = ( PEXTECCENCRYPTINFO )pRetData->Data;
//	memcpy( pCipherText->XCoordinate, pInfo->XCoordinate, ECC_MAX_XCOORDINATE_LEN );
//	memcpy( pCipherText->YCoordinate, pInfo->YCoordinate, ECC_MAX_YCOORDINATE_LEN );
//	memcpy( pCipherText->Cipher, pInfo->Cipher, ECC_MAX_MODULUS_LEN );
//	memcpy( pCipherText->Mac, pInfo->HASH, ECC_MAX_MODULUS_LEN );

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pCipherText != NULL)
        {
            memcpy(&pCipherText->BitLen,tmpReturn->Data, 4);
            memcpy(&pCipherText->XCoordinate, tmpReturn->Data + 4,32);
            memcpy(&pCipherText->YCoordinate, tmpReturn->Data + 36, 32);
            memcpy(&pCipherText->HASH, tmpReturn->Data+ 68 , 32);
            memcpy(&pCipherText->CipherLen, tmpReturn->Data + 100, 4);
            memcpy(&pCipherText->Cipher, tmpReturn->Data + 104, 16);
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_ExtECCDecrypt(
	DEVHANDLE           hDev,
	ECCPRIVATEKEYBLOB * pECCPriKeyBlob,
	PECCCIPHERBLOB      pCipherText,
	BYTE              * pbPlainText,
	ULONG             * pulPlainTextLen )
{
    DebugAudioLog(@"");
	
	if (pECCPriKeyBlob == NULL || pCipherText == NULL)
        {
        return SAR_FAIL;
    }

    //UINT nRet;
	BYTE CMD_BUF[MAX_BUF];//, pOut[1024];
	UINT nByteLen = 0, nCmdLen = 0;
	//ULONG ulBitLen = 0;
    UINT  Status   = STATUS_FAILED;
	
    //	if( pbPlainText == NULL)
    //		return OP_FAILED;
	
    //	if(*pulPlainTextLen > (MAX_BUF - 100))
    //		return OP_FAILED;
    //    
	nByteLen = pECCPriKeyBlob->BitLen / 8;
    
	memcpy(CMD_BUF, &pECCPriKeyBlob->BitLen, 4);
	nCmdLen += 4;
	memcpy(CMD_BUF + 4, pECCPriKeyBlob->PrivateKey, nByteLen);
	nCmdLen += nByteLen;
	memcpy(CMD_BUF + 4 + nByteLen, pCipherText->XCoordinate, nByteLen);		//**长度是否如此再确认
	nCmdLen += nByteLen;
	memcpy(CMD_BUF + 4 + nByteLen * 2, pCipherText->YCoordinate, nByteLen);
	nCmdLen += nByteLen;
	memcpy(CMD_BUF + 4 + nByteLen * 3, pCipherText->HASH, 32);
	nCmdLen += 32;
	memcpy(CMD_BUF + 4 + nByteLen * 3 + 32, &pCipherText->CipherLen, 4);
	nCmdLen += 4;
	memcpy(CMD_BUF + 4 + nByteLen * 3 + 32 + 4, pCipherText->Cipher, pCipherText->CipherLen);
	nCmdLen += pCipherText->CipherLen;
    Status = CMD_ExtECCDecrypt( CMD_BUF, nCmdLen, 0x0000 );
    if ( Status != STATUS_SUCCESS )
        return SAR_FAIL;
   
    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbPlainText != NULL)
        {
            memcpy(pbPlainText, tmpReturn->Data+4, 16);
        }
        if (pulPlainTextLen != NULL)
        {
            memcpy(&pulPlainTextLen, tmpReturn->Data, 4);
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}
    
ULONG DEVAPI SKF_ExtECCSign(
                            DEVHANDLE           hDev,
                            ECCPRIVATEKEYBLOB * pECCPriKeyBlob,
                            BYTE              * pbData,
                            ULONG               ulDataLen,
                            PECCSIGNATUREBLOB   pSignature )
{
    DebugAudioLog(@"");
	
	if (pECCPriKeyBlob == NULL || pbData == NULL)
        {
        return SAR_FAIL;
    }
    
    BYTE * pBlob  = ( BYTE * )calloc( sizeof( ECCPRIVATEKEYBLOB ) + ulDataLen + 4, sizeof( BYTE ) );
    BYTE * pTemp  = NULL;
    UINT   nLen   = 0;
    UINT   Status = STATUS_FAILED;
    
    pTemp = pBlob;
    nLen  = sizeof( ULONG );
    memcpy( pTemp, &( pECCPriKeyBlob->BitLen ), nLen );
    pTemp += nLen;
    nLen   = pECCPriKeyBlob->BitLen / 8;
    memcpy( pTemp, pECCPriKeyBlob->PrivateKey, nLen );
    pTemp += nLen;
    nLen   = sizeof( ULONG );
    memcpy( pTemp, &ulDataLen, nLen );
    pTemp += nLen;
    nLen   = ulDataLen;
    memcpy( pTemp, pbData, ulDataLen );
    nLen += pTemp - pBlob;
    
    Status = CMD_ExtECCSign( pBlob, nLen, 0x0000 );
    free( pBlob );
    pBlob = NULL;
    
    if ( Status != STATUS_SUCCESS )
        return SAR_FAIL;
    
    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pSignature != NULL)
        {
            memcpy(pSignature->r, tmpReturn->Data+4,32);
            memcpy(pSignature->s, tmpReturn->Data+36,32);
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_GenerateAgreementDataWithECC(
	HCONTAINER         hContainer,
	ULONG              ulAlgId,
	ECCPUBLICKEYBLOB * pTempECCPubKeyBlob,
	BYTE             * pbID,
	ULONG              ulIDLen,
	HANDLE           * phAgreementHandle )
{
    DebugAudioLog(@"");
	
	if (hContainer == NULL)
        {
        return SAR_FAIL;
    }
    
	GENERATEAGREEMENTDATAWITHECCBLOB  Blob;
	//PGENERATEAGREEMENTDATAWITHECCINFO pInfo = NULL;
	PCONTAINER pContainer = ( PCONTAINER )hContainer;
	//PReturnDataEx pRetData = NULL;

	Blob.wAppID       = g_Application.wAppID;
	Blob.wContainerID = pContainer->wContainerID;
	Blob.ulAlgId      = ulAlgId;
	Blob.ulIDLen      = ulIDLen;
	memcpy( Blob.pbID, pbID, ulIDLen );

	if( CMD_GenerateAgreementDataWithECC( ( BYTE * )&Blob, sizeof( Blob ), 0x0000 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    
    //modify by wangzhong at 2012-6-26
//    ReturnDataEx *tmpReturn = GetReturnDataEx();
//    if (tmpReturn->Status == STATUS_SUCCESS)
//    {
//        memcpy(pTempECCPubKeyBlob->XCoordinate, tmpReturn->Data, 32);
//        memcpy(pTempECCPubKeyBlob->YCoordinate, tmpReturn->Data+32, 32);
//        pTempECCPubKeyBlob->BitLen = tmpReturn->Length;// 256;
//        return SAR_OK;
//    }
//	return SAR_FAIL;
    
    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        //pInfo    = ( PGENERATEAGREEMENTDATAWITHECCINFO )tmpReturn->Data;
        return SAR_OK;
    }
    else
    {
        return SAR_FAIL;
    }
}

    ULONG DEVAPI SKF_GenerateAgreementDataAndKeyWithECC(HANDLE             hContainer,
                                                        ULONG              ulAlgId,
                                                        ECCPUBLICKEYBLOB * pSponsorECCPubKeyBlob,
                                                        ECCPUBLICKEYBLOB * pSponsorTempECCPubKeyBlob,
                                                        ECCPUBLICKEYBLOB * pTempECCPubKeyBlob,
                                                        BYTE             * pbID,
                                                        ULONG              ulIDLen,
                                                        BYTE             * pbSponsorID,
                                                        ULONG              ulSponsorIDLen,
                                                        HANDLE           * phKeyHandle )
                                                        
    {
    DebugAudioLog(@"");
	
	if (hContainer == NULL || pSponsorECCPubKeyBlob == NULL || pSponsorTempECCPubKeyBlob == NULL)
    {
        return SAR_FAIL;
    }
    
	GENERATEAGREEMENTDATAANDKEYWITHECCBLOB  Blob;
	PGENERATEAGREEMENTDATAANDKEYWITHECCINFO pInfo = NULL;
	PCONTAINER       pContainer = ( PCONTAINER )hContainer;
	//PReturnDataEx pRetData = NULL;

	Blob.wAppID = g_Application.wAppID;
	Blob.wContainerID = pContainer->wContainerID;
	Blob.ulAlgId = ulAlgId;
	Blob.ulSponsorBits = pSponsorECCPubKeyBlob->BitLen;
	memcpy( Blob.SponsorXCoordinate, pSponsorECCPubKeyBlob->XCoordinate, ECC_MAX_XCOORDINATE_LEN );
	memcpy( Blob.SponsorYCoordinate, pSponsorECCPubKeyBlob->YCoordinate, ECC_MAX_YCOORDINATE_LEN );
	Blob.ulSponsorTempBits = pTempECCPubKeyBlob->BitLen;
	memcpy( Blob.SponsorTempXCoordinate, pSponsorTempECCPubKeyBlob->XCoordinate, ECC_MAX_XCOORDINATE_LEN );
	memcpy( Blob.SponsorTempYCoordinate, pSponsorTempECCPubKeyBlob->YCoordinate, ECC_MAX_YCOORDINATE_LEN );
	Blob.ulSponsorIDLen = ulSponsorIDLen;
	memcpy( Blob.pbSponsorID, pbID, ECC_MAX_MODULUS_LEN );
	Blob.ulIDLen = ulIDLen;
	memcpy( Blob.pbID, pbID, ECC_MAX_MODULUS_LEN );

	if ( CMD_GenerateAgreementDataAndKeyWithECC( ( BYTE * )&Blob, sizeof( Blob ), 0x0000 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    
    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        if (phKeyHandle != NULL)
        {
            pInfo    = ( PGENERATEAGREEMENTDATAANDKEYWITHECCINFO )tmpReturn->Data;
            *phKeyHandle = pInfo;
        }
        
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_GenerateKeyWithECC(
	HANDLE             hAgreementHandle,
	ECCPUBLICKEYBLOB * pECCPubKeyBlob,
	ECCPUBLICKEYBLOB * pTempECCPubKeyBlob,
	BYTE             * pbID,
	ULONG              ulIDLen,
	HANDLE           * phKeyHandle )
{
    DebugAudioLog(@"");
	
	GENERATEKEYWITHECCBLOB Blob;
	//PReturnDataEx pRetData = NULL;
	UINT          nLen     = 0;

    if (pECCPubKeyBlob == NULL || pTempECCPubKeyBlob == NULL)
        {
        return SAR_FAIL;
    }
    
	Blob.wAppID = g_Application.wAppID;
	Blob.wContainerID = g_Container.wContainerID;
	Blob.hAgreementHandle = *( ( ULONG * )hAgreementHandle );
	Blob.ulResponserBits = pECCPubKeyBlob->BitLen;
	memcpy( Blob.ResponserXCoordinate, pECCPubKeyBlob->XCoordinate, ECC_MAX_XCOORDINATE_LEN );
	memcpy( Blob.ResponserYCoordinate, pECCPubKeyBlob->YCoordinate, ECC_MAX_YCOORDINATE_LEN );
	Blob.ulResponserTempBits = pTempECCPubKeyBlob->BitLen;
	memcpy( Blob.ResponserTempXCoordinate, pTempECCPubKeyBlob->XCoordinate, ECC_MAX_XCOORDINATE_LEN );
	memcpy( Blob.ResponserTempYCoordinate, pTempECCPubKeyBlob->YCoordinate, ECC_MAX_YCOORDINATE_LEN );
	Blob.ulResponserIDLen = ulIDLen;
	memcpy( Blob.pbResponserID, pbID, ulIDLen );
	nLen = sizeof( Blob ) - ECC_MAX_MODULUS_BITS_LEN + ulIDLen;

	if ( CMD_GenerateKeyWithECC( ( BYTE * )&Blob, nLen, 0x0004 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (phKeyHandle != NULL)
        {
            *phKeyHandle = tmpReturn->Data;
        }
        
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_ExportPublicKey(
	HCONTAINER hContainer,
	bool       bSignFlag,
	BYTE     * pbBlob,
	ULONG    * pulBlobLen )
{
    DebugAudioLog(@"");
	
	if (hContainer == NULL)
        {
        return SAR_FAIL;
    }
	WORD          Blob[2]    = { 0 };
	PCONTAINER    pContainer = ( PCONTAINER )hContainer;
	//PReturnDataEx pRetData   = NULL;

	Blob[0] = g_Application.wAppID;
	Blob[1] = pContainer->wContainerID;

	if ( CMD_ExportPublicKey( bSignFlag, ( BYTE * )Blob, sizeof( ULONG ), ECC_MAX_MODULUS_LEN ) != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//	memcpy( pbBlob, pRetData->Data, sizeof( EXPORTPUBLICKEYINFO ) );
//	*pulBlobLen = ECC_MAX_MODULUS_LEN;

    
	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbBlob != NULL)
        {
            pbBlob = (BYTE*)tmpReturn->Data;
        }
        
        if (pulBlobLen != NULL)
        {
            *pulBlobLen = tmpReturn->Length;//68
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_ImportSessionKey(
	HCONTAINER hContainer,
	ULONG      ulAlgId,
	BYTE     * pbWrapedData,
	ULONG      ulWrapedLen,
	HANDLE   * phKey )
{
    DebugAudioLog(@"");
	
	if (hContainer == NULL || pbWrapedData == NULL)
        {
        return SAR_FAIL;
    }
	BYTE        * pBlob      = ( BYTE * )calloc( sizeof( IMPORTSESSIONKEYBLOB ) + ulWrapedLen, sizeof( BYTE ) );
	BYTE        * pTemp      = NULL;
	UINT          nLen       = 0;
	UINT          Status     = STATUS_FAILED;
	PCONTAINER    pContainer = ( PCONTAINER )hContainer;
	//PReturnDataEx pRetData   = NULL;

	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( g_Application.wAppID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( pContainer->wContainerID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulAlgId, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulWrapedLen, nLen);
	pTemp += nLen;
	nLen   = ulWrapedLen;
	memcpy( pTemp, pbWrapedData, nLen );
	nLen += pTemp - pBlob;

	Status = CMD_ImportSessionKey( pBlob, nLen, 0x0002 );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (phKey != NULL)
        {
            *phKey = tmpReturn->Data;
        }
        
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }

}

ULONG DEVAPI SKF_SetSymmKey(
	DEVHANDLE hDev,
	BYTE    * pbKey,
	ULONG     ulAlgID,
	HANDLE  * phKey )
{
    DebugAudioLog(@"");
	
	UINT              nLen = 0;
	IMPORTSYMMKEYBLOB Blob;

    if (pbKey == NULL)
        {
        return SAR_FAIL;
    }
	Blob.wAppID[0]       = L_BYTE( g_Application.wAppID );
	Blob.wAppID[1]       = H_BYTE( g_Application.wAppID );
	Blob.wContainerID[0] = L_BYTE( g_Container.wContainerID );
	Blob.wContainerID[1] = H_BYTE( g_Container.wContainerID );
	Blob.ulAlgID         = ulAlgID;
	Blob.wSymKeyLen      = ECC_MAX_MODULUS_LEN;
	memcpy( Blob.pbSymKey, pbKey, ECC_MAX_MODULUS_LEN );
	nLen = sizeof( IMPORTSYMMKEYBLOB );

	if ( CMD_SetSymmKey( ( BYTE * )&Blob, nLen, 0x0002 ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (phKey != NULL)
        {
            *phKey = tmpReturn->Data;
        }
        
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }

}

ULONG DEVAPI SKF_EncryptInit( HANDLE hKey, BLOCKCIPHERPARAM EncryptParam )
{
    DebugAudioLog(@"");
	
	if (&EncryptParam == NULL)
        {
        return SAR_FAIL;
    }
    
	BYTE * pBlob   = ( BYTE * )calloc( sizeof( ENCRYPTINITBLOB ) + EncryptParam.IVLen, sizeof( BYTE ) );
	BYTE * pTemp   = NULL;
	UINT   nLen    = 0;
	UINT   Status  = STATUS_FAILED;
	WORD   ulKeyID = *( ( WORD * )hKey );
	ULONG  ulAlgID = SGD_SMS4_ECB;

	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( g_Application.wAppID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( g_Container.wContainerID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &ulKeyID, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulAlgID, nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( EncryptParam.IVLen ), nLen );
	pTemp += nLen;
	nLen   = EncryptParam.IVLen;
	memcpy( pTemp, EncryptParam.IV, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( EncryptParam.PaddingType ), nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( EncryptParam.FeedBitLen ), nLen );
	nLen += pTemp - pBlob;

	Status = CMD_EncryptInit( pBlob, nLen );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_Encrypt(
	HANDLE  hKey,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbEncryptedData,
	ULONG * pulEncryptedLen )
{
    DebugAudioLog(@"");
	
	BYTE Blob[512] = { 0 };
	//PReturnDataEx pRetData = NULL;
    if (pbData == NULL)
        {
        return SAR_FAIL;
    }

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hKey );
	Blob[5] = H_BYTE( *( WORD * )hKey );
	memcpy( Blob + 6, pbData, ulDataLen );

	if ( CMD_Encrypt( Blob, ulDataLen + 6, ulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//	memcpy( pbEncryptedData, pRetData->Data, *pulEncryptedLen );

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbEncryptedData != NULL)
        {
            memcpy(pbEncryptedData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulEncryptedLen != NULL)
        {
            *pulEncryptedLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_EncryptUpdate(
	HANDLE  hKey,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbEncryptedData,
	ULONG * pulEncryptedLen )
{
    DebugAudioLog(@"");
	
	BYTE Blob[512] = { 0 };
	//PReturnDataEx pRetData = NULL;
    if (pbData == NULL)
        {
        return SAR_FAIL;
    }

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hKey );
	Blob[5] = H_BYTE( *( WORD * )hKey );
	memcpy( Blob + 6, pbData, ulDataLen );

	if ( CMD_EncryptUpdate( Blob, ulDataLen + 6, ulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//	memcpy( pbEncryptedData, pRetData->Data, *pulEncryptedLen );

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbEncryptedData != NULL)
        {
            memcpy(pbEncryptedData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulEncryptedLen != NULL)
        {
            *pulEncryptedLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;

}

ULONG DEVAPI SKF_EncryptFinal(
	HANDLE  hKey,
	BYTE  * pbEncryptedData,
	ULONG * ulEncryptedDataLen )
{
    DebugAudioLog(@"");
	
	BYTE Blob[512] = { 0 };
	//PReturnDataEx pRetData = NULL;

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hKey );
	Blob[5] = H_BYTE( *( WORD * )hKey );
	memcpy( Blob + 6, pbEncryptedData, *ulEncryptedDataLen + 6 );

	if ( CMD_EncryptFinal( Blob, *ulEncryptedDataLen + 6, *ulEncryptedDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//	memcpy( pbEncryptedData, pRetData->Data, *ulEncryptedDataLen );

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbEncryptedData != NULL)
        {
            memcpy(pbEncryptedData, tmpReturn->Data, tmpReturn->Length);
        }
        if (ulEncryptedDataLen != NULL)
        {
            *ulEncryptedDataLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_DecryptInit(
	HANDLE           hKey,
	BLOCKCIPHERPARAM DecryptParam )
{
    DebugAudioLog(@"");
	
	if (&DecryptParam == NULL)
        {
        return SAR_FAIL;
    }
	BYTE * pBlob   = ( BYTE * )calloc( sizeof( DECRYPTINITBLOB ) + DecryptParam.IVLen, sizeof( BYTE ) );
	BYTE * pTemp   = NULL;
	UINT   nLen    = 0;
	UINT   Status  = STATUS_FAILED;

	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( g_Application.wAppID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( g_Container.wContainerID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, hKey, nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( DecryptParam.IVLen ), nLen );
	pTemp += nLen;
	nLen   = DecryptParam.IVLen;
	memcpy( pTemp, DecryptParam.IV, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( DecryptParam.PaddingType ), nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( DecryptParam.FeedBitLen ), nLen );
	nLen += pTemp - pBlob;

	Status = CMD_DecryptInit( pBlob, nLen );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_Decrypt(
	HANDLE   hKey,
	BYTE   * pbEncryptedData,
	ULONG    ulEncryptedLen,
	BYTE   * pbData,
	ULONG  * pulDataLen )
{
    DebugAudioLog(@"");
	
	BYTE Blob[512] = { 0 };
	//PReturnDataEx pRetData = NULL;

    if (&pbEncryptedData == NULL)
        {
        return SAR_FAIL;
    }
	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hKey );
	Blob[5] = H_BYTE( *( WORD * )hKey );
	memcpy( Blob + 6, pbEncryptedData, ulEncryptedLen );	
	// √¸¡Ó±®Œƒ ˝æ›”Ú”…”¶”√ID°¢»›∆˜ID°¢√‹‘øID£®2 ◊÷Ω⁄£©∫Õ¥˝Ω‚√‹µƒ∑÷◊È ˝æ›◊È≥…
	if ( CMD_Decrypt( Blob, ulEncryptedLen + 6, ulEncryptedLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

//	pRetData = GetReturnDataEx();
//	memcpy( pbEncryptedData, pRetData->Data, *pulDataLen );
    
    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbData != NULL)
        {
            memcpy(pbData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulDataLen != NULL)
        {
            *pulDataLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;

}

ULONG DEVAPI SKF_DecryptUpdate(
	HANDLE   hKey,
	BYTE   * pbEncryptedData,
	ULONG    ulEncryptedLen,
	BYTE   * pbData,
	ULONG  * pulDataLen )
{
    DebugAudioLog(@"");
	
	// √¸¡Ó±®Œƒ ˝æ›”Ú”…”¶”√ID°¢»›∆˜ID°¢√‹‘øID ∫Õ¥˝Ω‚√‹µƒ∑÷◊È ˝æ›◊È≥…
	BYTE          Blob[512] = { 0 };
	//PReturnDataEx pRetData  = NULL;
    if ( &pbEncryptedData == NULL)
        {
        return SAR_FAIL;
    }

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hKey );
	Blob[5] = H_BYTE( *( WORD * )hKey );

	memcpy( Blob + 6, pbEncryptedData, ulEncryptedLen );
	if ( CMD_DecryptUpdate( Blob, ulEncryptedLen + 6, ulEncryptedLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbData != NULL)
        {
            memcpy(pbData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulDataLen != NULL)
        {
            *pulDataLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_DecryptFinal(
	HANDLE  hKey,
	BYTE  * pbDecryptedData,
	ULONG * pulDecryptedDataLen )
{
    DebugAudioLog(@"");
	
	// √¸¡Ó±®Œƒ ˝æ›”Ú”…”¶”√ID°¢»›∆˜ID°¢√‹‘øID ∫Õ¥˝Ω‚√‹µƒ◊Ó∫Û“ª∂Œ ˝æ›£®ø…“‘≤ª¥Ê‘⁄£©°£
	BYTE          Blob[512] = { 0 };
	//PReturnDataEx pRetData  = NULL;

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hKey );
	Blob[5] = H_BYTE( *( WORD * )hKey );
	memcpy( Blob + 6, pbDecryptedData, *pulDecryptedDataLen );

	if ( CMD_DecryptFinal( Blob, *pulDecryptedDataLen + 6, *pulDecryptedDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

    //modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbDecryptedData != NULL)
        {
            memcpy(pbDecryptedData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulDecryptedDataLen != NULL)
        {
            *pulDecryptedDataLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_DigestInit(
	DEVHANDLE  hDev,
	ULONG      ulAlgID,
	HANDLE   * phHash )
{
    DebugAudioLog(@"");
	
	BYTE * pBlob   = NULL;
	UINT   nLen    = 0;
	//UINT   Status  = STATUS_FAILED;

	if ( ( ( BYTE )ulAlgID ) == DEGIST_SM3 )
	{
		pBlob = ( BYTE * )*phHash;
		nLen  = sizeof( DIGESTINITBLOB ) - ECC_MAX_MODULUS_LEN +
			( ( PDIGESTINITBLOB )pBlob )->ulIDLen;
	}

	if ( CMD_DigestInit( ( BYTE )ulAlgID, pBlob, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (phHash != NULL)
        {
            memcpy(phHash, tmpReturn->Data, tmpReturn->Length);
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_Digest(
	HANDLE  hHash,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbHashData,
	ULONG * pulHashLen )
{
    DebugAudioLog(@"");
	
	if (pbData == NULL || ulDataLen <= 0)
    {
        return SAR_FAIL;
    }
    
	if ( CMD_Digest( pbData, ulDataLen, ulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbHashData != NULL)
        {
            memcpy(pbHashData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulHashLen != NULL)
        {
            *pulHashLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_DigestUpdate(
	HANDLE hHash,
	BYTE * pbData,
	ULONG  ulDataLen )
{
    DebugAudioLog(@"");
	
	if (pbData == NULL || ulDataLen <= 0)
        {
        return SAR_FAIL;
    }
    
	if ( CMD_DigestUpdate( pbData, ulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_DigestFinal(
	HANDLE  hHash,
	BYTE  * pHashData,
	ULONG * pulHashLen )
{
    DebugAudioLog(@"");
	
	if (pHashData == NULL)
        {
        return SAR_FAIL;
    }
	if ( CMD_DigestFinal( pHashData, *pulHashLen, *pulHashLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pHashData != NULL)
        {
            memset(pHashData, 0, *pulHashLen);
            memcpy(pHashData, tmpReturn->Data, tmpReturn->Length);
        }
       
        if (pulHashLen != NULL)
        {
             *pulHashLen = tmpReturn->Length;
        }
       
        return SAR_OK;
    }
	return SAR_FAIL;
}

ULONG DEVAPI SKF_MacInit(
	HANDLE             hKey,
	BLOCKCIPHERPARAM * pMacParam,
	HANDLE           * phMac )
{
    DebugAudioLog(@"");
	
	BYTE * pBlob   = ( BYTE * )calloc( sizeof( MACINIT ), sizeof( BYTE ) );
	BYTE * pTemp   = NULL;
	UINT   nLen    = 0;
	UINT   Status  = STATUS_FAILED;
	WORD   ulKeyID = *( ( WORD * )hKey );
	ULONG  ulAlgID = SGD_SMS4_ECB;

	pTemp = pBlob;
	nLen  = sizeof( WORD );
	memcpy( pTemp, &( g_Application.wAppID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( g_Container.wContainerID ), nLen );
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &ulKeyID, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &ulAlgID, nLen );  // Temp
	pTemp += nLen;
	nLen   = sizeof( WORD );
	memcpy( pTemp, &( pMacParam->IVLen ), nLen );
	pTemp += nLen;
	nLen   = pMacParam->IVLen;
	memcpy( pTemp, pMacParam->IV, nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( pMacParam->PaddingType ), nLen );
	pTemp += nLen;
	nLen   = sizeof( ULONG );
	memcpy( pTemp, &( pMacParam->FeedBitLen ), nLen );
	nLen += pTemp - pBlob;

	Status = CMD_MacInit( pBlob, nLen );
	free( pBlob );
    pBlob = NULL;

	if ( Status != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        { 
        if (phMac != NULL)
        {
            *phMac = tmpReturn->Data;
        }
        
        return SAR_OK;
    }
    return SAR_FAIL;
}

ULONG DEVAPI SKF_Mac(
	HANDLE  hMac,
	BYTE  * pbData,
	ULONG   ulDataLen,
	BYTE  * pbMacData,
	ULONG * pulMacLen )
{
    DebugAudioLog(@"");
	
	BYTE          Blob[512] = { 0 };
	//PReturnDataEx pRetData  = NULL;

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hMac );
	Blob[5] = H_BYTE( *( WORD * )hMac );
	memcpy( Blob + 6, pbData, ulDataLen );

	if ( CMD_Mac( Blob, ulDataLen + 6, ulDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbMacData != NULL)
        {
            memcpy(pbMacData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulMacLen != NULL)
        {
            *pulMacLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
    return SAR_FAIL;
}

ULONG DEVAPI SKF_MacUpdate(
	HANDLE hMac,
	BYTE * pbData,
	ULONG  ulDataLen )
{
    DebugAudioLog(@"");
	
	BYTE          Blob[512] = { 0 };
	//PReturnDataEx pRetData  = NULL;

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hMac );
	Blob[5] = H_BYTE( *( WORD * )hMac );
	memcpy( Blob + 6, pbData, ulDataLen );
	if ( CMD_MacUpdate( Blob, ulDataLen + 6 ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_MacFinal(
	HANDLE  hMac,
	BYTE  * pbMacData,
	ULONG * pulMacDataLen )
{
    DebugAudioLog(@"");
	
	BYTE          Blob[512] = { 0 };
	//PReturnDataEx pRetData  = NULL;

	Blob[0] = L_BYTE( g_Application.wAppID );
	Blob[1] = H_BYTE( g_Application.wAppID );
	Blob[2] = L_BYTE( g_Container.wContainerID );
	Blob[3] = H_BYTE( g_Container.wContainerID );
	Blob[4] = L_BYTE( *( WORD * )hMac );
	Blob[5] = H_BYTE( *( WORD * )hMac );
	memcpy( Blob + 6, pbMacData, *pulMacDataLen );
	if ( CMD_MacFinal( Blob, *pulMacDataLen + 6, *pulMacDataLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//modify by wangzhong at 2012-6-26
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        if (pbMacData != NULL)
        {
            memcpy(pbMacData, tmpReturn->Data, tmpReturn->Length);
        }
        if (pulMacDataLen != NULL)
        {
            *pulMacDataLen = tmpReturn->Length;
        }
        
        return SAR_OK;
    }
    return SAR_FAIL;
}

ULONG DEVAPI SKF_CloseHandle( HANDLE hHandle )
{
    DebugAudioLog(@"");
	
	BYTE Data[6] = { 0 };

	Data[0] = L_BYTE( g_Container.wContainerID );
	Data[1] = H_BYTE( g_Container.wContainerID );
	Data[2] = L_BYTE( g_Application.wAppID );
	Data[3] = H_BYTE( g_Application.wAppID );
	// √‹‘øID?????
	Data[4] = 0x00;
	Data[5] = 0x00;

	if ( CMD_DestorySessionKey( Data, 6, 0x0000 ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_BlockApplication(
	HAPPLICATION hApplication,
	ULONG ulBlockType )
{
    DebugAudioLog(@"");
	
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;
	BYTE       * pData        = ( BYTE * )( &( pApplication->wAppID ) );

	if ( CMD_BlockApplication( ulBlockType, pData, sizeof( WORD ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	return SAR_OK;
}

ULONG DEVAPI SKF_UnblockApplication(
	HAPPLICATION hApplication )
{
    DebugAudioLog(@"");
	
	PAPPLICATION pApplication = ( PAPPLICATION )hApplication;
	BYTE       * pData        = ( BYTE * )( &( pApplication->wAppID ) );

	if ( CMD_UnblockApplication( pData, sizeof( WORD ) ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_BlockCard(
	HANDLE hDev )
{
    DebugAudioLog(@"");
	
	if ( CMD_BlockCard() != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_InternalAuthentication(
	HANDLE hDev,
	BYTE * pbRandom,
	ULONG  ulRandomLen )
{
    DebugAudioLog(@"");
	
	if ( CMD_InternalAuthentication( pbRandom, ulRandomLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

/*****************************************/
ULONG DEVAPI SKF_UnBlockCard()
{
    DebugAudioLog(@"");
	
	if ( CMD_CardUnBlock() != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_InitCard()
{
    DebugAudioLog(@"");
	
	if ( CMD_CardInit() != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}


#ifdef MOBILE_SHIELD_TOKEN
ULONG DEVAPI SKF_ReadTokenNum()
{
    DebugAudioLog(@"");
	
	if ( CMD_ReadTokenNum() != STATUS_SUCCESS )
		return SAR_FAIL;

	return SAR_OK;
}

ULONG DEVAPI SKF_SetCalcEq( BYTE * pData, UINT nLen )
{
    DebugAudioLog(@"");
	
	if ( CMD_SetCalcEq( pData, nLen) != STATUS_SUCCESS )
		return SAR_FAIL;

	return SAR_OK;
}

ULONG DEVAPI SKF_ReadEquipmentNum()
{
    DebugAudioLog(@"");
	
	if ( CMD_ReadEquipmentNum() != STATUS_SUCCESS )
		return SAR_FAIL;

	return SAR_OK;
}

ULONG DEVAPI SKF_GeneratePermitCode( BYTE * pData, UINT nLen )
{
    DebugAudioLog(@"");
	
	if ( CMD_GeneratePermitCode( pData, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	return SAR_OK;
}
#endif

//#ifdef MOBILE_SHIELD_SHOW
ULONG DEVAPI SKF_TransmitContent( BYTE * pData, UINT nLen )
{
    DebugAudioLog(@"");
	
	if ( CMD_TransmitContent( pData, nLen ) != STATUS_SUCCESS )
		return SAR_FAIL;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
        {
        return SAR_OK;
    }
    else {
        return SAR_FAIL;
    }
}

ULONG DEVAPI SKF_ReadStatus(int p1)
{
    DebugAudioLog(@"");
	
    ULONG status = CMD_ReadStatus(p1);
	if ( status != STATUS_SUCCESS )
		return status;

	//add by wangzhong
    ReturnDataEx *tmpReturn = GetReturnDataEx();
    if (tmpReturn->Status == STATUS_SUCCESS)
    {
        tmpReturn = NULL;
        return SAR_OK;
    }
    else
    {
        tmpReturn = NULL;
        return SAR_FAIL;
    }
}
ULONG DEVAPI SKF_HandShakeS(DEVHANDLE hDev )
    {
        DebugAudioLog(@"");
	if ( CMD_HandShakeS() != STATUS_SUCCESS )
            return SAR_FAIL;
        //add by wangzhong
        ReturnDataEx *tmpReturn = GetReturnDataEx();
        if (tmpReturn->Status == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else {
            return SAR_FAIL;
        }
        
        
    }
//#endif

//#endif
    
    
    
    //++++++++++++
    int get_int32(Byte *res_str, int begin)
    {
        int a0 = (int) res_str[begin + 3];
        if (a0 < 0)
            a0 += 256;
        int a1 = (int) res_str[begin + 2];
        if (a1 < 0)
            a1 += 256;
        int a2 = (int) res_str[begin + 1];
        if (a2 < 0)
            a2 += 256;
        int a3 = (int) res_str[begin + 0];
        if (a3 < 0)
            a3 += 256;
        return ((a3 << 24) + (a2 << 16) + (a1 << 8) + a0);
    }
    //++++++++++++
    
    //++++++++++++++*******************集成接口
#pragma mark - *****集成接口*****
    unsigned char AppID[2]={0};
    unsigned char g_ContainerID[2];
    BYTE pbRandom[16] = {0};
    int NewNumber=0;//新证书文件数目
    int filecount=0;//证书文件数目
    RSAPUBLICKEYBLOB pBlob;
    APPLICATION app;
    NSString * GuestPIN;//用户pin码
    NSMutableArray*Name = [[NSMutableArray alloc] init];//存储检测到的证书文件名
    NSMutableArray*NameData = [[NSMutableArray alloc] init];//储存所有证书文件名
    NSMutableArray*addName = [[NSMutableArray alloc] init];//存储检测到的新证书文件名
    
    
    BOOL audioRouteIsPlugedIn()
    {
        return [[CMobileShield shareMobileShield] audioRoute_IsPlugedIn];
    }
    
//********************获取证书文件数***************************//
#pragma mark - 获取证书文件数
    int MyFileNumber()
    {
        int number=0;
        ULONG pulSize = 10;
//        APPLICATION  application;
//        memcpy(&application.wAppID, AppID, 2);
        if(SKF_EnumFiles (&app, nil, &pulSize) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Status == STATUS_SUCCESS)
            {
                int length = tmpReturn->Length;
                BYTE result[length];
                memcpy(result, tmpReturn->Data, length);
                for (int i=0; i<length; i++)
                {
                    if (result[0] =='\0')
                    {
                        number++;
                        break;
                    }
                    if (result[i] =='\0')
                    {
                        number++;
                    }
                }
                filecount = number-1;
            }
            else
            {
                filecount = 0;
            }
        }
        else
        {
            filecount = 0;
        }
        NewNumber = filecount;
        return filecount;
    }
    
//********************获取证书文件名***************************//
#pragma mark - 获取证书文件名
    NSMutableArray* MyEnumFile()
    {
        printf("开始枚举文件\n");
//        APPLICATION  application;
//        memcpy(&application.wAppID, AppID, 2);
        ULONG pulSize = 10;
        int flag = 0;
        int number=0;
        if(SKF_EnumFiles (&app, nil, &pulSize) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Status == STATUS_SUCCESS)
            {
                int length = tmpReturn->Length;
                BYTE result[length];
                memcpy(result, tmpReturn->Data, length);
                //++++++++++ by zhangjian 20141012 10:30
                for (int i=0; i<length; i++)
                {
                    if (result[0] =='\0')
                    {
                        number++;
                        break;
                    }
                    if (result[i] =='\0')
                    {
                        number++;
                    }
                }
                filecount = number-1;
//                NewNumber = filecount;
                //+++++++++++
                number = 0;
                NSString *fileName[filecount+1];
                for (int n =0; n< length; n++)
                {
                    if (n==0||number!=flag)
                    {
                        fileName[number] = [NSString stringWithFormat:@"%c",result[n]];
                        flag=number;
                        continue;
                    }
                    if (result[n] == 0x00)
                    {
                        fileName[number] = [NSString stringWithFormat:@"%@\0",fileName[number]];
                        number++;
                    }
                    else
                    {
                        fileName[number] = [NSString stringWithFormat:@"%@%c",fileName[number],result[n]];
                        flag=number;
                    }
                }
                for (int i = 0; i<filecount; i++)
                {
//                    [Name addObject:fileName[i]];
                    //++++++by zhangjian 20141013 10:35
                    BOOL isHave = NO;
                    for(NSString *str in Name)
                    {
                        if([str isEqualToString:fileName[i]])
                        {
                            isHave = YES;
                        }
                    }
                    if(!isHave)
                    {
                        [Name addObject:fileName[i]];
                    }
                    //++++++
                }
                return Name;
            }
            else
            {
                //++++++++++ by zhangjian 20141012 10:30
                filecount = 0;
//                NewNumber = filecount;
                //++++++++++
                return nil;
            }
        }
        else
        {
            //++++++++++ by zhangjian 20141012 10:30
            filecount = 0;
//            NewNumber = filecount;
            //++++++++++
            return nil;
        }
    }


//********************将证书存储到本地文件*********************//
#pragma mark - 将证书存储到本地文件
    void StoreCertFile(NSString *Local_filename,BYTE *content,int nfileLen)
    {
        NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [ doc objectAtIndex:0 ];
        NSLog(@"docPath =%@",docPath);
        NSString *filePath = [docPath stringByAppendingPathComponent:Local_filename];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:filePath];
        if (!fileExists)
        {
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        //    const char *myfile=NULL;
        //    myfile = [filePath UTF8String];
        //    FILE *fp = fopen(myfile, "r+");
        //    //转化pem编码格式
        //    long length=PEM_write(fp, "CERTIFICATE","", (unsigned char*)content, nfileLen);
        //    DebugAudioLog(@"length=%ld",length);
        //    fclose(fp);
        //    fp = fopen(myfile, "r+");
        //    X509 * x509return = PEM_read_X509(fp, NULL, NULL, NULL);
        //    fclose(fp);
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendBytes:content length:nfileLen+1];
        [writer writeToFile:filePath atomically:YES];
    }
    
    
    
    //********************将证书名存入Plist*********************//
#pragma mark - 将证书名存入Plist
    void StoreCertName(NSArray *name)
    {
        NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [ doc objectAtIndex:0 ];
        DebugAudioLog(@"docPath =%@",docPath);
        NSMutableDictionary *newDic = [ [ NSMutableDictionary alloc ] init ];
        for (int i=0; i<NewNumber; i++)
        {
            NSString*str;
            str=[NSString stringWithFormat:@"certificate%d",i];
            str=[NSString stringWithFormat:@"%@.plist",str];
            [newDic setValue:name[i] forKey:name[i]];
            [newDic writeToFile:[docPath stringByAppendingPathComponent:str] atomically:YES ];
        }
        
    }
    
    NSArray *readLocalFile()
    {
        if (filecount==0)
        {
            return NULL;
        }
        NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:filecount];
        NSString*str;
        str=[NSString stringWithFormat:@"certificate%d",filecount-1];
        str=[NSString stringWithFormat:@"%@.plist",str];
        NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [ doc objectAtIndex:0 ];
        NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:str]];
        if(dic)
        {
            [names setArray:dic.allKeys];
        }
        return names;
    }
    
//********************读取手机盾证书文件***************************//
#pragma mark - 读取手机盾证书文件
    //int MyOpenFile(X509 * x509return)
    int MyOpenFile()
    {
        ULONG  pulOutLen = 0;
        ULONG ulOffset = 0;
        LPSTR fname;
        int nfileLen;
        
        NSMutableArray*NameData = [[NSMutableArray alloc] init];
        NameData=Name;
//        APPLICATION  application;
//        memcpy(&application.wAppID, AppID, 2);
        NSString*Local_filename;
        NSMutableArray *name = [[NSMutableArray alloc] initWithCapacity:NewNumber];
        for (int i =0; i < NewNumber; i++)
        {
            // 获得文件名
            Local_filename=[[addName objectAtIndex:i] copy]; //from Local_filename=[[NameData objectAtIndex:i] copy] change by zhangjian 20141013 10:25
            fname =(LPSTR)[Local_filename UTF8String];
            //读取文件信息
            if(SKF_GetFileInfo(&app, fname, nil) == SAR_OK)
            {
                ReturnDataEx *getinfo = GetReturnDataEx();
                if (getinfo->Status != 1)
                {
                    DebugAudioLog(@"get file info failed");
                    return 0;
                }
                memcpy(&nfileLen, getinfo->Data, 4);
                NSLog(@"nfilelen = %d", nfileLen);
//                nfileLen /= 2;
                //读取文件
                unsigned char* fileContent = (unsigned char*)calloc(nfileLen+1,sizeof(unsigned char));//free
                BYTE *content = (BYTE*)calloc(nfileLen+1,sizeof(BYTE));
                if(SKF_ReadFile(&app,fname, ulOffset,nfileLen,content,&pulOutLen) == SAR_OK)
                {
                    ReturnDataEx *tmpReturn = GetReturnDataEx();
                    if(tmpReturn != NULL && tmpReturn->Status == STATUS_SUCCESS && tmpReturn->Data !=NULL)
                    {
                        memcpy(content, tmpReturn->Data, tmpReturn->Length);
                        NSMutableData *mtr = [[NSMutableData alloc]initWithBytes:content length:nfileLen+1];
                        DebugAudioLog(@"FileRead success! mtr = %@\n", mtr);
                    }
                    else
                    {
                        free(fileContent);
                        fileContent = nil;
                        free(content);
                        content = nil;
                        DebugAudioLog(@"FileRead fail!\n");
                        return 0;
                    }
                    fileContent=content;
                    [name addObject:Local_filename];
//                    name[i]=Local_filename;
                    //将证书存储到本地文件中
                    StoreCertFile(Local_filename, content, nfileLen);
        
                    //+++++++
                    /*/
                     //将证书文件转换成X50格式
                     NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                     NSString *docPath = [ doc objectAtIndex:0 ];
                     DebugAudioLog(@"docPath =%@",docPath);
                     NSString *filePath = [docPath stringByAppendingPathComponent:Local_filename];
                     const char *myfile=NULL;
                     myfile = [filePath UTF8String];
                     FILE *fp = fopen(myfile, "r+");
                     x509return = PEM_read_X509(fp, NULL, NULL, NULL);
                     fclose(fp);
                     NSMutableData *writer = [[NSMutableData alloc] initWithContentsOfFile:filePath];
                     unsigned char *ch=(unsigned char*)malloc([writer length]+1);
                     ch=(unsigned char*)[writer bytes];
                     x509return=d2i_X509(NULL,(const unsigned char **)&ch,[writer length]+1);
                     //*/
                }
                else
                {
                    free(fileContent);
                    fileContent = nil;
                    free(content);
                    content = nil;
                    return 0;
                }
            }
            else
            {
                return 0;
            }
        }
        //++++++by zhangjian 20141013 10:40
        NewNumber = NameData.count;
        //将证书名存入Plist中
        StoreCertName(NameData);    //from StoreCertName(name); change by zhangjian 20141013 10:25
        //++++++by zhangjian 20141013 10:40
        [addName removeAllObjects];
        return 1;
    }
    
//********************查看是否有新证书*********************//
#pragma mark - 查看是否有新证书
    int check_cert()
    {
        int certnum=0;
        int flag=0;
        NSMutableArray*Namedata = [[NSMutableArray alloc] init];
        
        /*/++++++++++ by zhangjian 20141012 10:30
        MyFileNumber();
        if (filecount==0)
        {
            return -1;
        }
        */
        
        Namedata = MyEnumFile();
        if (Namedata==nil)
        {
            return -2;
        }
        certnum=filecount;
        
        //++++++++++ by zhangjian 20141012 10:30
        NewNumber=0;
        
        //++++++++++ by zhangjian 20141013 10:30
        BOOL isHave = NO;
        int x = 0;
        //++++++
        
        for (int i=0; i<certnum; i++)
        {
            NSString*fileName;
            /**
            NSString*str;
            str=[NSString stringWithFormat:@"certificate%d",i];
            str=[NSString stringWithFormat:@"%@.plist",str];
            NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [ doc objectAtIndex:0 ];
            NSDictionary *dic = [ NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:str]];
            fileName=[[Namedata objectAtIndex:i] copy];
            NSString*str1=[dic objectForKey:fileName];
            if(str1==nil)
            {
                [Name addObject:fileName];
                flag=1;
                if(dic != nil)
                {
                    NewNumber++;
                }
            }
             //*/
            
            //+++++++++++ by zhangjian 20141013 09:00
            fileName=[[Namedata objectAtIndex:i] copy];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [ doc objectAtIndex:0 ];
            NSError *error = nil;
            NSArray *fileList = [[NSArray alloc] init];
            //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
            fileList = [fileManager contentsOfDirectoryAtPath:docPath error:&error];
            if(fileList.count == 0)
            {
                flag = 1;
                NewNumber = filecount;
                addName = Namedata;
                return flag;
            }
            for(int j=0; j<fileList.count; j++)
            {
                NSString *nowName = fileList[j];
                NSString *rfileName = [fileName substringToIndex:fileName.length-1];
                if([nowName  isEqualToString:rfileName] && [nowName rangeOfString:@"certificate"].location == NSNotFound)
                {
                    isHave = YES;
                    break;
                }
                else
                {
                    isHave = NO;
                    x = i;
                }
            }
            if(!isHave)
            {
                flag = 1;
                [addName addObject:[[Namedata objectAtIndex:x] copy]];
            }
            //++++++++
        }
        
        
        
        //+++++++++++ by zhangjian 20141013 09:00
        if(flag == 0)
        {
            //将证书名存入Plist中
            NewNumber = Name.count;
            StoreCertName(Name);
        }
        else
        {
            NewNumber = addName.count;
        }
        //++++++++
        return flag;
    }
    
//********************读取本地证书文件*********************//
#pragma mark - 读取本地证书文件
    //int ReadLocalCert(X509 ** x509return)
    int ReadLocalCert()
    {
        int certnum=0;
        int length[10];
        int nfileLen;
        LPSTR fname;
//        APPLICATION  application;
//        memcpy(&application.wAppID, AppID, 2);
        NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [ doc objectAtIndex:0 ];
        certnum=filecount;
        NSString*fileName[certnum];
        NSMutableArray*Namedata = [[NSMutableArray alloc] init];
        Namedata = MyEnumFile();
        if (Namedata==nil)
        {
            return -1;
        }
        for (int i =0; i < certnum; i++)
        {
            fileName[i]=[[Namedata objectAtIndex:i] copy];
            fname =(LPSTR)[fileName[i] UTF8String];
            if(SKF_GetFileInfo(&app, fname, nil) == SAR_OK)
            {
                ReturnDataEx *getinfo = GetReturnDataEx();
                memcpy(&nfileLen, getinfo->Data, 4);
                DebugAudioLog(@"nfilelen = %d", nfileLen);
                length[i]=nfileLen;
                NSString *filePath = [docPath stringByAppendingPathComponent:fileName[i]];
                NSMutableData *writer = [[NSMutableData alloc] initWithContentsOfFile:filePath];
                DebugAudioLog(@"FileRead success! writer = %@\n", writer);
            }
            else
            {
                return -1;
            }
            //        unsigned char *ch=(unsigned char*)malloc(length[i]+1);
            //        ch=(unsigned char*)[writer bytes];
            //        x509return[i]=d2i_X509(NULL,(const unsigned char **)&ch,length[i]);
            
        }
        return certnum;
    }
    
    
//********************获取随机数***************************//
#pragma mark - 获取随机数
    int GenRandom()
    {
        if(SKF_GenRandom(NULL,pbRandom,16) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Status == 0x0001)
            {
                memcpy(pbRandom,tmpReturn->Data,tmpReturn->Length);
                return 1;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }
    //++++++++ by zhangjian 20141011 15:38
    NSData * GetRandom()
    {
        NSData *random = nil;
        if(SKF_GenRandom(NULL,pbRandom,16) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Status == 0x0001)
            {
                memcpy(pbRandom,tmpReturn->Data,tmpReturn->Length);
                random = [NSData dataWithBytes:pbRandom length:tmpReturn->Length];
                return random;
            }
            else
            {
                return random;
            }
        }
        else
        {
            return random;
        }
    }
    
    
//    **********************设备认证***********************//
    bool auth_keyDevice()
    {
        BYTE pbRandom[16] = {};
        if(SKF_GenRandom(NULL,pbRandom,16) == SAR_OK)
        {
            ReturnDataEx *tmpReturn1 = GetReturnDataEx();
            if (tmpReturn1->Status == 0x0001)
            {
                memcpy(pbRandom,tmpReturn1->Data,tmpReturn1->Length);
                
                unsigned char *gOut1 = (unsigned char *)calloc(16,sizeof(unsigned char));
                SMS4_ENC(pbRandom,gOut1,16);
                SKF_DevAuth(nil, gOut1, 16);
                ReturnDataEx *tmpReturn2 = GetReturnDataEx();
                free(gOut1);
                gOut1 = NULL;
                if (tmpReturn2->Status == 0x0001)
                {
                    return YES;
                }
            }
        }
        DebugAudioLog(@"设备认证失败！");
        return NO;
    }
    
//********************打开应用***************************//
#pragma mark - 打开应用
    int open_Application()
    {
//        //设备认证
//        ULONG uRes = SKF_GenRandom(NULL,pbRandom,16);
//        if (SAR_FAIL == uRes)
//        {
//            DebugAudioLog(@"设备认证失败！");
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"设备认证失败!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            return 0;
//        }
        
        
        //++++++++++
        /*   测试代码  不进行网络连接*/
        //枚举应用
        /**
        LPSTR szAppName = nullptr ;
        ULONG    pulSize;
        SKF_EnumApplication(nil, szAppName, &pulSize);
        ReturnDataEx *tmpReturn1 = GetReturnDataEx();
        if (tmpReturn1->Status == STATUS_SUCCESS)
        {
            DebugAudioLog(@"tmpReturn1->Type %d",tmpReturn1->Type);
            DebugAudioLog(@"tmpReturn1->Length %d",tmpReturn1->Length);
            DebugAudioLog(@"tmpReturn1->Data %s",tmpReturn1->Data);
            DebugAudioLog(@"tmpReturn1->Data sizeof %zu",strlen(tmpReturn1->Data));
            szAppName = (LPSTR) malloc(sizeof(LPSTR)* (strlen(tmpReturn1->Data)+1));
            bzero(szAppName, (strlen(tmpReturn1->Data)+1));
            memcpy(szAppName, tmpReturn1->Data, strlen(tmpReturn1->Data));
            DebugAudioLog(@"szAppName %s",szAppName);
        }
        else
        {
            DebugAudioLog(@"APP fail");
        }
        //*/
        
        //打开应用
//        SKF_OpenApplication(nil,szAppName,nil);
//        if(app.wAppID != 0 )
//        {
//            return 1;
//        }
        
        if(SKF_OpenApplication(nil,(LPSTR)"cfca_app",nil) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                BYTE result[10];
                memcpy(result,tmpReturn2->Data,10);
                AppID[0] = result[8];
                AppID[1] = result[9];
                memcpy(&app.wAppID,AppID,2);
                DebugAudioLog(@"APP success");
            }
            else
            {
                DebugAudioLog(@"APP fail");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"智能密码钥匙启动失败!请检查设备" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return 0;
            }
        }
        else
        {
            return 0;
        }
        return 1;
    }
    
//********************检测手机盾是否插入***************************//
#pragma mark - 检测手机盾是否插入
    int Check_mobilshield()
    {
        if (!GenRandom())
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请插入手机盾" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return 0;
        }
        else
        {
            return 1;
        }
    }
    
//********************获得容器名***************************//
#pragma mark - 获得容器名
    NSString * GetContainName(int index)
    {
        NSString *fileName =[[NameData objectAtIndex:index]copy];
        NSString *containerName = [fileName substringToIndex:[fileName length]-2];
        return containerName;
    }
    
//********************打开容器***************************//
#pragma mark - 打开容器
    NSArray *enum_container()
    {
        //枚举容器
        char szContainerName[128]={0};
        ULONG pUlContanerLen = 0;
        ULONG l2 = SKF_EnumContainer(&app,szContainerName, &pUlContanerLen);
        NSArray *names = nil;
        if (l2 == SAR_OK)
        {
            NSMutableString* mstr = [[ NSMutableString alloc] init];
            NSString *str;
            for (int i =0; i < pUlContanerLen; i++)
            {
                if (szContainerName[i] == 0x00)
                {
                    str = @",";
                }
                else
                {
                    str = [NSString stringWithFormat:@"%c",szContainerName[i]];
                }
                [mstr appendString:str];
            }
            DebugAudioLog(@"SKF_EnumContainer:%@",mstr);
            names = [mstr componentsSeparatedByString:@","];
        }
        return names;
    }
    
    NSDictionary * open_contain(NSString *containerName)
    {
        NSDictionary *dic = nil;
        //打开容器
        if(SKF_OpenContainer(&app,(LPSTR)[containerName UTF8String],nil) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Status == STATUS_SUCCESS)
            {
                memcpy(g_ContainerID,tmpReturn->Data,2);
                DebugAudioLog(@"opencontainer success");
                Byte SignKeyLen[4];
                Byte ExchgKeyLen[4];
                memcpy(SignKeyLen, tmpReturn->Data+3, 4);
                memcpy(ExchgKeyLen, tmpReturn->Data+7, 4);
                dic = @{@"type": [NSNumber numberWithInt:tmpReturn->Data[2]],
                        @"SignKeyLen":[NSNumber numberWithInt:get_int32(SignKeyLen, 0)],
                        @"ExchgKeyLen":[NSNumber numberWithInt:get_int32(ExchgKeyLen, 0)],
                        @"SignCertFlag": [NSNumber numberWithInt:tmpReturn->Data[11]],
                        @"ExchgCertFlag": [NSNumber numberWithInt:tmpReturn->Data[12]]};
                return dic;
            }
            else
            {
                DebugAudioLog(@"opencontainer fail");
                return dic;
            }
        }
        else
        {
            return dic;
        }
    }
    
//********************获得证书内容***************************//
#pragma mark - 获得证书内容
    NSString * ReadCer  ()
    {
//        //打开容器
//        BOOL OpenContain = open_contain();
//        if (!OpenContain)
//        {
//            return  nil;
//        }
        //导出证书内容
        ULONG pUlCerLen = 0;
        ULONG ulExportType = 1;
        unsigned char* szCer = (unsigned char*)calloc(2048,sizeof(unsigned char));//free
        ULONG l2 = SKF_ExportCertificate(&app, ulExportType, &pUlCerLen, szCer);
        if (l2 == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Length == 0)
            {
                free(szCer);
                szCer = NULL;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"读取客户端证书失败!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                DebugAudioLog(@"ExportCertificate Fail!");
                return nil;
            }
            memcpy(szCer, tmpReturn->Data+2, tmpReturn->Length-2);
            //存储证书
            NSArray *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docPath = [ doc objectAtIndex:0 ];
            DebugAudioLog(@"docPath =%@",docPath);
            NSString *filePath = [docPath stringByAppendingPathComponent:@"Certificate"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL fileExists = [fileManager fileExistsAtPath:filePath];
            if (!fileExists)
            {
                [fileManager createFileAtPath:filePath contents:nil attributes:nil];
            }
            NSMutableData *writer = [[NSMutableData alloc] init];
            [writer appendBytes:szCer length:tmpReturn->Length-2];
            [writer writeToFile:filePath atomically:YES];
            
            //+++++++++++
            //转化为X509格式证书
            //        X509 *cert;
            //        cert = d2i_X509(NULL,(const unsigned char **)&szCer,tmpReturn->Length);
            //        //取得证书所属者
            //        NSString * str=[[NSString alloc] initWithUTF8String:X509_NAME_oneline(X509_get_subject_name(cert), 0, 0)];
            //        NSString *str1 = @"CN=";
            //        NSString *str2 = @"";
            //        NSRange range = [str rangeOfString:str1];
            //        const char *certname=[str UTF8String];
            //        for (int i=range.location+3;i<[str length]; i++)
//        {
            //            if (certname[i]=='/')
//        {
            //                break;
            //            }
            //            else {
            //                str2=[NSString stringWithFormat:@"%@%c",str2,certname[i]];
            //            }
            //        }
            //        return str2;
            
        }
        else
        {
            free(szCer);
            szCer = NULL;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"读取客户端证书失败!" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            DebugAudioLog(@"ExportCertificate Fail!");
            return nil;
        }
        free(szCer);
        szCer = NULL;
        return nil;
    }
  
//********************校验PIN码***************************//
#pragma mark - 校验PIN码
    BOOL VerifyPinCode(NSString *pin)
    {
        ULONG pulRetryCount ;
        if(SKF_VerifyPIN(&app, USER_TYPE, (LPSTR)[pin UTF8String], &pulRetryCount) == SAR_OK)
        {
            ReturnDataEx *tmpReturn1 = GetReturnDataEx();
            if (tmpReturn1->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn1->Type %d",tmpReturn1->Type);
                DebugAudioLog(@"tmpReturn1->Length %d",tmpReturn1->Length);
                DebugAudioLog(@"tmpReturn1->Data %s",tmpReturn1->Data);
                DebugAudioLog(@"tmpReturn1->Data sizeof %zu",strlen(tmpReturn1->Data));
                return YES;
            }
            else
            {
                DebugAudioLog(@"APP fail");
                return NO;
            }
        }
        return NO;
    }
    
    NSData * HASHInit(NSString *inStr)
    {
        HANDLE   * phHash = nullptr;
        if(SKF_DigestInit(0, 2, phHash) == SAR_OK)
        {
            ReturnDataEx *tmpReturn1 = GetReturnDataEx();
            if (tmpReturn1->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn1->Length %d",tmpReturn1->Length);
                DebugAudioLog(@"tmpReturn1->Data %s",tmpReturn1->Data);
                DebugAudioLog(@"tmpReturn1->Data sizeof %zu",strlen(tmpReturn1->Data));
                BYTE * buf=(BYTE *)[inStr UTF8String];
                BYTE *pbHashData = nullptr;
                ULONG pulHashLen = (ULONG)strlen((char *)buf);
                
                [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                if(SKF_Digest(phHash, buf, pulHashLen, pbHashData, &pulHashLen) == SAR_OK)
                {
                    ReturnDataEx *tmpReturn2 = GetReturnDataEx();
                    if (tmpReturn2->Status == STATUS_SUCCESS)
                    {
                        if(tmpReturn2->Length <= 0)
                        {
                            return nil;
                        }
                        DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                        DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                        DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                        BYTE returnData[1024];
                        memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                        printf("hash returnData: \n");
                        for(int i=0; i<tmpReturn2->Length; i++)
                        {
                            printf("%02x ", returnData[i]);
                        }
                        printf("\nhash returnData length = %zu \n",strlen((char *)returnData));
                        NSData *retData = [NSData dataWithBytes:returnData length:tmpReturn2->Length];
                        return retData;
                    }
                    else
                    {
                        DebugAudioLog(@"APP fail");
                        return nil;
                    }
                }
                else
                {
                    return nil;
                }
            }
            else
            {
                DebugAudioLog(@"APP fail");
                return nil;
            }
        }
        return nil;
    }
    
    NSData * RSASignData(NSString *pin, NSData *signData)
    {
        NSData *RsaData = nil;
        CONTAINER container = g_Container;
        BYTE pbSignature[500] = {0};
        ULONG pulSignLen;
        BYTE hashD[signData.length];
        memcpy(hashD, [signData bytes], signData.length);
        if(SKF_RSASignData(&container, hashD, signData.length, pbSignature, &pulSignLen, (LPSTR)[pin UTF8String], 4) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                BYTE returnData[1024];
                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                for(int i=0; i<tmpReturn2->Length; i++)
                {
                    printf("%02x ", returnData[i]);
                }
                printf("\n");
                while (1)
                {
                    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
                    {
                        break;
                    }
                    
                    SKF_ReadStatus(0);
                    ReturnDataEx *RSAData1 = GetReturnDataEx();
                    if (RSAData1->Status == 0x0001)
                    {
                        unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                        memcpy(result, RSAData1->Data, 2);
                        if (result[0] == 0x77 && result[1] == 0x77)
                        { //已确认
                            free(result);
                            result = NULL;
                            RsaData = [NSData dataWithBytes:RSAData1->Data length:tmpReturn2->Length];
                            DebugAudioLog(@"RsaData = %@",RsaData);
                            return RsaData;
                            break ;
                        }
                        else if(result[0] == 0x66 && result[1] == 0x66)
                        {//已取消
                            free(result);
                            result = NULL;
                            RsaData =nil;
                            break;
                        }
                        else if (result[0] == 0x88 && result[1] == 0x88)
                        {
                            free(result);
                            result = NULL;
                            RsaData =nil;
                            continue;
                        }
                        else if(result[0] == 0x99 && result[1] == 0x99)
                        {//已超时
                            free(result);
                            result = NULL;
                            RsaData = nil;
                            break;
                        }
                        free(result);
                        result = NULL;
                    }
                    else
                    {
                        break;
                    }
                }
                return RsaData;
            }
            else
            {
                DebugAudioLog(@"APP fail");
                return RsaData;
            }
        }
        return RsaData;
    }
    

    
    NSDictionary * changePinCode(NSString *oldPin, NSString *newPin)
    {
        NSDictionary *dic = nil;
        int PinRe = open_Application();
        DebugAudioLog(@"PIN = %d",PinRe);
        if(PinRe <= 0)
        {
            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"打开应用失败"};
            return dic;
        }
        ULONG *count = (ULONG *)calloc(2,sizeof(ULONG));
//        if(SKF_VerifyPIN(&app, 0x01, (LPSTR)[oldPin UTF8String], count) == SAR_OK)
//        {
//            ReturnDataEx *tmpReturn = GetReturnDataEx();
//            if(tmpReturn->Status == STATUS_SUCCESS)
//            {
                if(SKF_ChangePIN(&app, 0x01, (LPSTR)[oldPin UTF8String], (LPSTR)[newPin UTF8String], count) == SAR_OK)
                {
                    ReturnDataEx *tmpReturn = GetReturnDataEx();
                    if(tmpReturn->Status == STATUS_SUCCESS)
                    {
                        if(tmpReturn->Type == 0x6666)
                        {
                            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"用户取消修改"};
                        }
                        else if(tmpReturn->Type == 0x3333)
                        {
                            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"按键超时"};
                        }
                        else if (tmpReturn->Type >= 0x63C0 && tmpReturn->Type < 0x63Cf )
                        {
                            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":[NSString stringWithCString:tmpReturn->Data encoding:NSUTF8StringEncoding]};
                        }
                        else
                        {
                            dic = @{@"statue": [NSNumber numberWithBool:YES], @"errorMsg":@"修改成功"};
                        }
                        free(count);
                        count = NULL;
                        return dic;
                    }
                    else
                    {
                        NSData *data = [[NSData alloc] initWithBytes:tmpReturn->Data length:tmpReturn->Length];
                        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":str};
                    }
                }
                else
                {
                    dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"修改失败"};
                }
//            }
//            else
//            {
//                NSData *data = [[NSData alloc] initWithBytes:tmpReturn->Data length:tmpReturn->Length];
//                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":str};
//            }
//        }
//        else
//        {
//            ReturnDataEx *tmpReturn = GetReturnDataEx();
//            NSData *data = [[NSData alloc] initWithBytes:tmpReturn->Data length:tmpReturn->Length];
//            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":str};
    //        }
        free(count);
        count = NULL;
        return dic;
    }
    
    NSDictionary * unlockPinCode(NSString *oldPin, NSString *AdminPin, NSString *newUserPin)
    {
        NSDictionary *dic = nil;
        int PinRe = open_Application();
        DebugAudioLog(@"PIN = %d",PinRe);
        if(PinRe <= 0)
        {
            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"打开应用失败"};
            return dic;
        }
        ULONG *count = (ULONG *)calloc(2,sizeof(ULONG));
        if(SKF_UnblockPIN(&app, (LPSTR)[AdminPin UTF8String], (LPSTR)[newUserPin UTF8String], count) == SAR_OK)
        {
            ReturnDataEx* tmpReturn = GetReturnDataEx();
            if(tmpReturn->Status == STATUS_SUCCESS)
            {
                free(count);
                count = NULL;
                dic = @{@"statue": [NSNumber numberWithBool:YES], @"errorMsg":@"修改成功"};
                return dic;
            }
            else
            {
                NSData *data = [[NSData alloc] initWithBytes:tmpReturn->Data length:tmpReturn->Length];
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":str};
            }
        }
        else
        {
            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"修改失败"};
        }
        free(count);
        count = NULL;
        return dic;
    }
    
#pragma mark - 6100 token Interface
    
    ULONG SKF_QueueToken(LPSTR tokenSN)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_QueueToken(tokenSN);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        ReturnDataEx *tmpReturn = GetReturnDataEx();
        if (tmpReturn->Status == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
    }
    
    NSDictionary * token_QueryToken(NSString *tokenSN)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ErrorNum: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(SKF_QueueToken((LPSTR)[tokenSN UTF8String]) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if (tmpReturn->Status == STATUS_SUCCESS)
            {
                
            }
            else
            {
                
            }
        }
        else
        {
            
        }
        return dic;
    }
    
    ULONG SKF_UpdatePin(LPSTR tokenSN, LPSTR oldPin, LPSTR newPin)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_UpdatePin(tokenSN, oldPin, newPin);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_UpdatePin(NSString *tokenSN, NSString *oldPin, NSString *newPin)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ErrorNum: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!oldPin || oldPin.length <= 0 || [oldPin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ErrorNum: @"-1", reciveKey_ErrorMessage: @"oldPIN不能为空"};
            return dic;
        }
        if(!newPin || newPin.length <= 0 || [newPin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ErrorNum: @"-1", reciveKey_ErrorMessage: @"newPIN不能为空"};
            return dic;
        }
        if(SKF_UpdatePin((LPSTR)[tokenSN UTF8String],(LPSTR)[oldPin UTF8String],(LPSTR)[newPin UTF8String]) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    ULONG SKF_QueueTokenEX()
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_QueryTokenEX();
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_QueueTokenEX()
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        if(SKF_QueueTokenEX() == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    ULONG SKF_ActiveTokenPlug(LPSTR tokenSN, LPSTR ActiveCode)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_ActiveTokenPlug(tokenSN, ActiveCode);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    unsigned char * stringFromHexString(NSString *strOld)
    {
        //DebugAudioLog(@"hexString = %@, length = %d",self,self.length);
        unsigned char *myBuffer = (unsigned char *)calloc(strOld.length/2+1,sizeof(unsigned char));
        bzero(myBuffer, (strOld.length/2+1));
        NSMutableString *str = [[NSMutableString alloc] initWithString:strOld];
        if(str.length %2 != 0)
        {
            [str insertString:@"0" atIndex:0];
        }
        if(str.length>0 && str.length %2 == 0)
        {
            for(int i=0 ;i<str.length-1; i+=2)
            {
                uint atint;
                NSString *hexCharStr = [str substringWithRange:NSMakeRange(i, 2)];
                __autoreleasing NSScanner *scanner = [[NSScanner alloc]initWithString:hexCharStr];
                [scanner scanHexInt:&atint];
                myBuffer[i/2] = (unsigned char)atint;
            }
        }
        return myBuffer;
    }
    
    NSDictionary * token_ActiveTokenPlug(NSString *tokenSN, NSString *activeCode)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(SKF_ActiveTokenPlug((LPSTR)[tokenSN UTF8String], (LPSTR)stringFromHexString(activeCode)) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    ULONG SKF_UnlockRandomNo(LPSTR tokenSN)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_UnlockRandomNo(tokenSN);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_UnlockRandomNo(NSString *tokenSN)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(SKF_UnlockRandomNo((LPSTR)[tokenSN UTF8String]) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    ULONG SKF_UnlockPin(LPSTR tokenSN, LPSTR unlockCode)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_UnlockPin(tokenSN, unlockCode);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_UnlockPin(NSString *tokenSN, NSString *unlockCode)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!unlockCode || unlockCode.length <= 0 || [unlockCode isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"unlockCode不能为空"};
            return dic;
        }
        unsigned char *unlockCode_c = (unsigned char *)calloc(strlen([unlockCode UTF8String]), sizeof(unsigned char));
        if(unlockCode.length == 8)
        {
            unlockCode_c = stringFromHexString(unlockCode);
        }
        else
        {
            memcpy(unlockCode_c ,[unlockCode UTF8String], strlen([unlockCode UTF8String]));
        }
        if(SKF_UnlockPin((LPSTR)[tokenSN UTF8String], (LPSTR)unlockCode_c) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
        }
        free(unlockCode_c);
        unlockCode_c = NULL;
        return dic;
    }
    
    
    
    int getByteForStringLenth(NSString * string)
    {
        NSData *_data = [string dataUsingEncoding:NSUTF8StringEncoding];
        return (int)[_data length];
    }
    
    int InterceptionFormatRecordName(LPSTR str, NSString *name, int begin)
    {
        int index = -1;
        int nameUtf8Length = getByteForStringLenth(name);
        DebugAudioLog(@"nameUtf8Length = %d",nameUtf8Length);
        if(nameUtf8Length > 14)
        {
            for(index = name.length-1; index>=0; index--)
            {
                if(getByteForStringLenth([name substringFromIndex:index]) > 14)
                {
                    DebugAudioLog(@"index = %d",index);
                    break;
                }
            }
        }
        DebugAudioLog(@"index = %d",index);
        NSString *subName=nil;
        if(index<0)
        {
            subName = name;
        }
        else
        {
            subName=[NSString stringWithFormat:@"*%@",[name substringFromIndex:index+1]];
        }
        DebugAudioLog(@"subName = %@",subName);
        Byte buffer[19];
        memset(buffer,'\0', 19);
        Byte *subNameByte = (Byte *)[[subName dataUsingEncoding:NSUTF8StringEncoding] bytes];
        int subNameByteLength = getByteForStringLenth(subName);
        for(int i=0; i<subNameByteLength; i++)
        {
            buffer[i] = subNameByte[i];
        }
        for(int i=0; i<19; i++)
        {
            str[begin+i] = buffer[i];
        }
        return begin+19;
    }
    
    NSString * InterceptionFormatPayeeName(NSString *name)
    {
        int index = -1;
        int nameUtf8Length = getByteForStringLenth(name);
        DebugAudioLog(@"nameUtf8Length = %d",nameUtf8Length);
        if(nameUtf8Length > 14)
        {
            for(index = name.length-1; index>=0; index--)
            {
                if(getByteForStringLenth([name substringFromIndex:index]) > 14)
                {
                    DebugAudioLog(@"index = %d",index);
                    break;
                }
            }
        }
        DebugAudioLog(@"index = %d",index);
        NSString *subName=nil;
        if(index<0)
        {
            subName = name;
        }
        else
        {
            subName=[NSString stringWithFormat:@"*%@",[name substringFromIndex:index+1]];
        }
        return subName;
    }
    
    NSArray * FormatBankCcountNumToArray(NSString *ccountNO)
    {
        NSMutableArray *array=[[NSMutableArray alloc] initWithCapacity:3];
        NSString *substr1=[ccountNO substringToIndex:2];
        [array addObject:substr1];
        NSString *substr2=[ccountNO substringWithRange:NSMakeRange(2, 9)];
        [array addObject:substr2];
        NSString *substr3=[ccountNO substringFromIndex:11];
        [array addObject:substr3];
        return array;
    }
    
    
    ULONG SKF_GetTokenCodeSafety(LPSTR tokenSN, int audioPortPos,
                                 LPSTR pin, LPSTR utctime,
                                 LPSTR verify, int *ccountNo,
                                 int * money, LPSTR name, int currency)
    {
        printf("\n SKF_GetTokenCodeSafety PINData =  ");
        for(int i=0; i<16; i++)
        {
            printf("%02x ",pin[i]);
        }
        printf("\n\n");
        UINT Status = STATUS_FAILED;
        Status = CMD_GetTokenCodeSafety(tokenSN, audioPortPos, pin, utctime, verify, ccountNo, money, name, currency);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS  || statues.intValue == 0x3333 || statues.intValue == 0x6666)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_GetTokenCodeSafety(NSString *tokenSN, int audioPortPos,
                                            NSString *pin, NSString *utctime,
                                            NSString *verify, NSString *ccountNo,
                                            NSString * money, NSString *name, int currency)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        int ccountNumInt[3] = {0, 0, 0};
        int moneyInt[2] = {0, 0};
        CHAR nameSt[23] = {0};

        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"PIN码不能为空"};
            return dic;
        }
        if(!utctime || utctime.length <= 0 || [utctime isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"utctime不能为空"};
            return dic;
        }
        if(!verify || verify.length <= 0 || [verify isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"verify不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"unlockCode不能为空"};
            return dic;
        }
        if(!ccountNo || ccountNo.length <= 0 || [ccountNo isKindOfClass:[NSNull class]])
        {
            ccountNo = @"";
        }
        else
        {
            if(ccountNo.length<20)
            {
                NSMutableString *ccountNostr=[NSMutableString stringWithFormat:@"%@",ccountNo];
                for(int i=0;i<(20-ccountNo.length);i++)
                {
                    [ccountNostr insertString:@"0" atIndex:0];
                }
                NSArray *ccountStrArray = FormatBankCcountNumToArray(ccountNostr);
                
                ccountNumInt[0] = [[ccountStrArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountStrArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountStrArray objectAtIndex:2] intValue];
            }
            else
            {
                NSArray *ccountArray = FormatBankCcountNumToArray(ccountNo);
                ccountNumInt[0] = [[ccountArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountArray objectAtIndex:2] intValue];
            }
        }
        if(!money || money.length <= 0 || [money isKindOfClass:[NSNull class]])
        {
            money = @"";
        }
        else
        {
            NSRange rang = [money rangeOfString:@"."];
            if(rang.location != NSNotFound)
            {
                money = [money floatToIntWithCentMoney];
            }
            NSMutableString *MoneyN = [NSMutableString stringWithFormat:@"%@",money];
            if(money.length <= 9)
            {
                moneyInt[0] = 0;
                for(int i=0; i<9-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                moneyInt[1] = [MoneyN intValue];
            }
            else
            {
                for(int i=0; i<12-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                DebugAudioLog(@"ApiTypeGetTokenCodeSafety Money = %@",MoneyN);
                moneyInt[0] = [MoneyN substringToIndex:3].intValue;
                moneyInt[1] = [[MoneyN substringFromIndex:(MoneyN.length-9)] intValue];
            }
        }
        if(!name || name.length <= 0 || [name isKindOfClass:[NSNull class]])
        {
            name = @"";
        }
        else
        {
            InterceptionFormatRecordName(nameSt, name, 0);
        }
        if(SKF_GetTokenCodeSafety((LPSTR)[tokenSN UTF8String], audioPortPos,
                                  (LPSTR)[pin UTF8String], (LPSTR)stringFromHexString(utctime),
                                  (LPSTR)stringFromHexString(verify), ccountNumInt,
                                  moneyInt, nameSt, currency) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x3333)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"按键超时" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x6666)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"用户取消操作" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    ULONG SKF_GetTokenCodeSafety_key(LPSTR tokenSN, int audioPortPos,
                                 LPSTR pin, LPSTR utctime,
                                 LPSTR verify, int *ccountNo,
                                 int * money, LPSTR name, int currency)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_GetTokenCodeSafety_key(tokenSN, audioPortPos, pin, utctime, verify, ccountNo, money, name, currency);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS || statues.intValue == 0x3333 || statues.intValue == 0x6666)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_GetTokenCodeSafety_key(NSString *tokenSN, int audioPortPos,
                                                NSString *pin, NSString *utctime,
                                                NSString *verify, NSString *ccountNo,
                                                NSString * money, NSString *name, int currency)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        int ccountNumInt[3] = {0, 0, 0};
        int moneyInt[2] = {0, 0};
        CHAR nameSt[23] = {0};
        
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"PIN码不能为空"};
            return dic;
        }
        if(!utctime || utctime.length <= 0 || [utctime isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"utctime不能为空"};
            return dic;
        }
        if(!verify || verify.length <= 0 || [verify isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"verify不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"unlockCode不能为空"};
            return dic;
        }
        if(!ccountNo || ccountNo.length <= 0 || [ccountNo isKindOfClass:[NSNull class]])
        {
            ccountNo = @"";
        }
        else
        {
            if(ccountNo.length<20)
            {
                NSMutableString *ccountNostr=[NSMutableString stringWithFormat:@"%@",ccountNo];
                for(int i=0;i<(20-ccountNo.length);i++)
                {
                    [ccountNostr insertString:@"0" atIndex:0];
                }
                NSArray *ccountStrArray = FormatBankCcountNumToArray(ccountNostr);
                
                ccountNumInt[0] = [[ccountStrArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountStrArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountStrArray objectAtIndex:2] intValue];
            }
            else
            {
                NSArray *ccountArray = FormatBankCcountNumToArray(ccountNo);
                ccountNumInt[0] = [[ccountArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountArray objectAtIndex:2] intValue];
            }
        }
        if(!money || money.length <= 0 || [money isKindOfClass:[NSNull class]])
        {
            money = @"";
        }
        else
        {
            NSRange rang = [money rangeOfString:@"."];
            if(rang.location != NSNotFound)
            {
                money = [money floatToIntWithCentMoney];
            }
            NSMutableString *MoneyN = [NSMutableString stringWithFormat:@"%@",money];
            if(money.length <= 9)
            {
                moneyInt[0] = 0;
                for(int i=0; i<9-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                moneyInt[1] = [MoneyN intValue];
            }
            else
            {
                for(int i=0; i<12-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                DebugAudioLog(@"ApiTypeGetTokenCodeSafety Money = %@",MoneyN);
                moneyInt[0] = [MoneyN substringToIndex:3].intValue;
                moneyInt[1] = [[MoneyN substringFromIndex:(MoneyN.length-9)] intValue];
            }
        }
        if(!name || name.length <= 0 || [name isKindOfClass:[NSNull class]])
        {
            name = @"";
        }
        else
        {
            InterceptionFormatRecordName(nameSt, name, 0);
        }
        if(SKF_GetTokenCodeSafety_key((LPSTR)[tokenSN UTF8String], audioPortPos,
                                      (LPSTR)[pin UTF8String], (LPSTR)stringFromHexString(utctime),
                                      (LPSTR)stringFromHexString(verify), ccountNumInt,
                                      moneyInt, nameSt, currency) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x3333)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"按键超时" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x6666)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"用户取消操作" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    ULONG SKF_ScanCode(LPSTR tokenSN, int audioPortPos,
                       LPSTR pin, LPSTR utctime,
                       LPSTR verify, int *ccountNo,
                       int * money, LPSTR name, int currency)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_ScanCode(tokenSN, audioPortPos, pin, utctime, verify, ccountNo, money, name, currency);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSDictionary * token_ScanCode(NSString *tokenSN, int audioPortPos,
                                  NSString *pin, NSString *utctime,
                                  NSString *verify, NSString *ccountNo,
                                  NSString * money, NSString *name, int currency)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        int ccountNumInt[3] = {0, 0, 0};
        int moneyInt[2] = {0, 0};
        CHAR nameSt[23] = {0};
        
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"PIN码不能为空"};
            return dic;
        }
        if(!utctime || utctime.length <= 0 || [utctime isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"utctime不能为空"};
            return dic;
        }
        if(!verify || verify.length <= 0 || [verify isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"verify不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"unlockCode不能为空"};
            return dic;
        }
        if(!ccountNo || ccountNo.length <= 0 || [ccountNo isKindOfClass:[NSNull class]])
        {
            ccountNo = @"";
        }
        else
        {
            if(ccountNo.length<20)
            {
                NSMutableString *ccountNostr=[NSMutableString stringWithFormat:@"%@",ccountNo];
                for(int i=0;i<(20-ccountNo.length);i++)
                {
                    [ccountNostr insertString:@"0" atIndex:0];
                }
                NSArray *ccountStrArray = FormatBankCcountNumToArray(ccountNostr);
                
                ccountNumInt[0] = [[ccountStrArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountStrArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountStrArray objectAtIndex:2] intValue];
            }
            else
            {
                NSArray *ccountArray = FormatBankCcountNumToArray(ccountNo);
                ccountNumInt[0] = [[ccountArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountArray objectAtIndex:2] intValue];
            }
        }
        if(!money || money.length <= 0 || [money isKindOfClass:[NSNull class]])
        {
            money = @"";
        }
        else
        {
            NSRange rang = [money rangeOfString:@"."];
            if(rang.location != NSNotFound)
            {
                money = [money floatToIntWithCentMoney];
            }
            NSMutableString *MoneyN = [NSMutableString stringWithFormat:@"%@",money];
            if(money.length <= 9)
            {
                moneyInt[0] = 0;
                for(int i=0; i<9-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                moneyInt[1] = [MoneyN intValue];
            }
            else
            {
                for(int i=0; i<12-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                DebugAudioLog(@"ApiTypeGetTokenCodeSafety Money = %@",MoneyN);
                moneyInt[0] = [MoneyN substringToIndex:3].intValue;
                moneyInt[1] = [[MoneyN substringFromIndex:(MoneyN.length-9)] intValue];
            }
        }
        if(!name || name.length <= 0 || [name isKindOfClass:[NSNull class]])
        {
            name = @"";
        }
        else
        {
            InterceptionFormatRecordName(nameSt, name, 0);
        }
        if(SKF_GetTokenCodeSafety_key((LPSTR)[tokenSN UTF8String], audioPortPos,
                                      (LPSTR)[pin UTF8String], (LPSTR)stringFromHexString(utctime),
                                      (LPSTR)stringFromHexString(verify), ccountNumInt,
                                      moneyInt, nameSt, currency) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    NSDictionary * startRecordButtonAction()
    {
        return startRecordButtonActionWithType(ApiTypeGetTokenCodeSafety);
    }
    
    NSDictionary * startRecordButtonActionWithType(ApiType type)
    {
        [CMobileShield shareMobileShield].waitApiType = type;
        NSDictionary *dic = nil;
        while (1)
        {
            if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            {
                break;
            }
            
            ULONG status = SKF_ReadStatus(0xcc);
            if(status != SAR_OK)
            {
                if(status == SAR_TIMEOUT)
                {
                    DebugAudioLog(@"");
                    dic = @{reciveKey_ResponseCode:@"-1", reciveKey_ErrorMessage:@"通讯超时!"};
                    
                    DebugAudioLog(@"%@",dic);
                    continue;
                }
                else
                {
                    NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
                    NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
                    if (statues.intValue == STATUS_SUCCESS)
                    {
                        [tmpReturn removeObjectForKey:@"return_status"];
                        dic = @{reciveKey_ResponseCode:@"3", reciveKey_ErrorMessage:@"请在耳机孔插入CCRT的Key设备!"};
                    }
                }
                break;
            }
            ReturnDataEx *RSAData1 = GetReturnDataEx();
            if (RSAData1->Status == 0x0001)
            {
                unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                memcpy(result, RSAData1->Data, 2);
                if (result[0] == 0x77 && result[1] == 0x77)
                { //已确认
//                    free(RSAData1);
                    RSAData1 = NULL;
                    free(result);
                    result = NULL;
                    NSLog(@"----7777----");
                    NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
                    NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
                    if (statues.intValue == STATUS_SUCCESS)
                    {
                        [tmpReturn removeObjectForKey:@"return_status"];
                        dic = (NSDictionary *)tmpReturn;
                    }
                    break ;
                }
                else if(result[0] == 0x66 && result[1] == 0x66)
                {//已取消
//                    free(RSAData1);
                    RSAData1 = NULL;
                    free(result);
                    result = NULL;
                    NSLog(@"----6666----");
                    NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
                    NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
                    if (statues.intValue == STATUS_SUCCESS)
                    {
                        [tmpReturn removeObjectForKey:@"return_status"];
                        if(ApiTypeUpdatePin == type)
                        {
                            dic = @{reciveKey_ResponseCode:@"1", reciveKey_ErrorMessage:@"取消修改"};
                        }
                        else
                        {
                            dic = @{reciveKey_ResponseCode:@"1", reciveKey_ErrorMessage:@"交易取消"};
                        }
                    }
                    break;
                }
                else if (result[0] == 0x88 && result[1] == 0x88)
                {
                    NSLog(@"----8888----");
//                    free(RSAData1);
                    RSAData1 = NULL;
                    free(result);
                    result = NULL;
//                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
                    continue;
                }
                else if(result[0] == 0x99 && result[1] == 0x99)
                {//已超时
                    NSLog(@"----9999----");
//                    free(RSAData1);
                    RSAData1 = NULL;
                    free(result);
                    result = NULL;
                    NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
                    NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
                    if (statues.intValue == STATUS_SUCCESS)
                    {
                        [tmpReturn removeObjectForKey:@"return_status"];
                        if(ApiTypeUpdatePin == type)
                        {
                            dic = @{reciveKey_ResponseCode:@"2", reciveKey_ErrorMessage:@"等待按键超时"};
                        }
                        else
                        {
                            dic = @{reciveKey_ResponseCode:@"2", reciveKey_ErrorMessage:@"交易超时"};
                        }
                    }
                    break;
                }
                free(result);
                result = NULL;
            }
            else
            {
                NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
                NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
                if (statues.intValue == STATUS_SUCCESS)
                {
                    [tmpReturn removeObjectForKey:@"return_status"];
                    dic = @{reciveKey_ResponseCode:@"3", reciveKey_ErrorMessage:@"请在耳机孔插入CCRT的Key设备!"};
                }
                break;
            }
        }
        return dic;
    }
    
    void stopAudioSession()
    {
        [CMobileShield stopAudioSessionControl];
    }
    
    BOOL SKF_CancelTrans()
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_CancelTrans();
        if ( Status != STATUS_SUCCESS )
        {
            return false;
        }
        else
        {
            return true;
        }
        
        NSDictionary *tmpReturn = GetTokenReturnData();
        NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
        if (statues.intValue == STATUS_SUCCESS)
        {
            return true;
        }
        else
        {
            return false;
        }
        return false;
    }
    
    BOOL token_CancelTrans()
    {
        return SKF_CancelTrans();
    }
    
#pragma mark - new Add
    
    NSDictionary * token_new_GetTokenCodeSafety(NSString *tokenSN, int audioPortPos,
                                                NSString *pin, NSString *utctime,
                                                NSString *verify, NSString *ccountNo,
                                                NSString * money, NSString *name, int currency)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        int ccountNumInt[3] = {0, 0, 0};
        int moneyInt[2] = {0, 0};
        CHAR nameSt[23] = {0};
        BYTE PINData[128] = { 0 };
        
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"PIN码不能为空"};
            return dic;
        }
        if(!utctime || utctime.length <= 0 || [utctime isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"utctime不能为空"};
            return dic;
        }
        if(!verify || verify.length <= 0 || [verify isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"verify不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"unlockCode不能为空"};
            return dic;
        }
        else
        {
            NSLog(@"PIN = %@",pin);
            BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
            BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
            BYTE Random[DATA_BLOCK_LEN]  = { 0 };
            SHA1_CONTEXT  Context;
            PReturnDataEx pRetData = NULL;
            if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
                return STATUS_FAILED;
            pRetData = GetReturnDataEx();
            
            memset( Random, 0x00, DATA_BLOCK_LEN );
            memcpy( Random, pRetData->Data, RANDOM_LEN );
            
            memset( PIN, 0x00, DATA_BLOCK_LEN );
            memcpy( PIN, [pin UTF8String], pin.length );
            SHA1_Init_Sunyard( &Context );
            SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
            SHA1_Final_Sunyard( &Context, HashKey );
            SMS4_Init( HashKey );
            SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, PINData, DATA_BLOCK_LEN, NULL );
        }
        if(!ccountNo || ccountNo.length <= 0 || [ccountNo isKindOfClass:[NSNull class]])
        {
            ccountNo = @"";
        }
        else
        {
            if(ccountNo.length<20)
            {
                NSMutableString *ccountNostr=[NSMutableString stringWithFormat:@"%@",ccountNo];
                for(int i=0;i<(20-ccountNo.length);i++)
                {
                    [ccountNostr insertString:@"0" atIndex:0];
                }
                NSArray *ccountStrArray = FormatBankCcountNumToArray(ccountNostr);
                
                ccountNumInt[0] = [[ccountStrArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountStrArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountStrArray objectAtIndex:2] intValue];
            }
            else
            {
                NSArray *ccountArray = FormatBankCcountNumToArray(ccountNo);
                ccountNumInt[0] = [[ccountArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountArray objectAtIndex:2] intValue];
            }
        }
        if(!money || money.length <= 0 || [money isKindOfClass:[NSNull class]])
        {
            money = @"";
        }
        else
        {
            NSRange rang = [money rangeOfString:@"."];
            if(rang.location != NSNotFound)
            {
                money = [money floatToIntWithCentMoney];
            }
            NSMutableString *MoneyN = [NSMutableString stringWithFormat:@"%@",money];
            if(money.length <= 9)
            {
                moneyInt[0] = 0;
                for(int i=0; i<9-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                moneyInt[1] = [MoneyN intValue];
            }
            else
            {
                for(int i=0; i<12-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                DebugAudioLog(@"ApiTypeGetTokenCodeSafety Money = %@",MoneyN);
                moneyInt[0] = [MoneyN substringToIndex:3].intValue;
                moneyInt[1] = [[MoneyN substringFromIndex:(MoneyN.length-9)] intValue];
            }
        }
        if(!name || name.length <= 0 || [name isKindOfClass:[NSNull class]])
        {
            name = @"";
        }
        else
        {
            InterceptionFormatRecordName(nameSt, name, 0);
        }
//        if(SKF_GetTokenCodeSafety((LPSTR)[tokenSN UTF8String], audioPortPos,
//                                  (LPSTR)[pin UTF8String], (LPSTR)stringFromHexString(utctime),
//                                  (LPSTR)stringFromHexString(verify), ccountNumInt,
//                                  moneyInt, nameSt, currency) == SAR_OK)
        
//        NSLog(@"PINData = %s",PINData);
        printf("\nPINData =  ");
        for(int i=0; i<16; i++)
        {
            printf("%02x ",PINData[i]);
        }
        printf("\n\n");
        if(SKF_GetTokenCodeSafety((LPSTR)[tokenSN UTF8String], audioPortPos,
                                  (LPSTR)PINData, (LPSTR)stringFromHexString(utctime),
                                  (LPSTR)stringFromHexString(verify), ccountNumInt,
                                  moneyInt, nameSt, currency) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x3333)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"按键超时" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x6666)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"用户取消操作" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    NSDictionary * token_new_GetTokenCodeSafety_key(NSString *tokenSN, int audioPortPos,
                                                NSString *pin, NSString *utctime,
                                                NSString *verify, NSString *ccountNo,
                                                NSString * money, NSString *name, int currency)
    {
        DebugAudioLog(@"");
        NSDictionary *dic = nil;
        int ccountNumInt[3] = {0, 0, 0};
        int moneyInt[2] = {0, 0};
        CHAR nameSt[23] = {0};
        BYTE PINData[128] = { 0 };
        
        if(!tokenSN || tokenSN.length <= 0 || [tokenSN isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"tokenSN不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"PIN码不能为空"};
            return dic;
        }
        if(!utctime || utctime.length <= 0 || [utctime isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"utctime不能为空"};
            return dic;
        }
        if(!verify || verify.length <= 0 || [verify isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"verify不能为空"};
            return dic;
        }
        if(!pin || pin.length <= 0 || [pin isKindOfClass:[NSNull class]])
        {
            dic = @{reciveKey_ResponseCode: @"-1", reciveKey_ErrorMessage: @"unlockCode不能为空"};
            return dic;
        }
        else
        {
            BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
            BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
            BYTE Random[DATA_BLOCK_LEN]  = { 0 };
            SHA1_CONTEXT  Context;
            PReturnDataEx pRetData = NULL;
            if ( CMD_GenRandom( RANDOM_LEN ) != STATUS_SUCCESS )
                return STATUS_FAILED;
            pRetData = GetReturnDataEx();
            
            memset( Random, 0x00, DATA_BLOCK_LEN );
            memcpy( Random, pRetData->Data, RANDOM_LEN );
            
            memset( PIN, 0x00, DATA_BLOCK_LEN );
            memcpy( PIN, [pin UTF8String], pin.length );
            SHA1_Init_Sunyard( &Context );
            SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
            SHA1_Final_Sunyard( &Context, HashKey );
            SMS4_Init( HashKey );
            SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, PINData, DATA_BLOCK_LEN, NULL );
        }
        if(!ccountNo || ccountNo.length <= 0 || [ccountNo isKindOfClass:[NSNull class]])
        {
            ccountNo = @"";
        }
        else
        {
            if(ccountNo.length<20)
            {
                NSMutableString *ccountNostr=[NSMutableString stringWithFormat:@"%@",ccountNo];
                for(int i=0;i<(20-ccountNo.length);i++)
                {
                    [ccountNostr insertString:@"0" atIndex:0];
                }
                NSArray *ccountStrArray = FormatBankCcountNumToArray(ccountNostr);
                
                ccountNumInt[0] = [[ccountStrArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountStrArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountStrArray objectAtIndex:2] intValue];
            }
            else
            {
                NSArray *ccountArray = FormatBankCcountNumToArray(ccountNo);
                ccountNumInt[0] = [[ccountArray objectAtIndex:0] intValue];
                ccountNumInt[1] = [[ccountArray objectAtIndex:1] intValue];
                ccountNumInt[2] = [[ccountArray objectAtIndex:2] intValue];
            }
        }
        if(!money || money.length <= 0 || [money isKindOfClass:[NSNull class]])
        {
            money = @"";
        }
        else
        {
            NSRange rang = [money rangeOfString:@"."];
            if(rang.location != NSNotFound)
            {
                money = [money floatToIntWithCentMoney];
            }
            NSMutableString *MoneyN = [NSMutableString stringWithFormat:@"%@",money];
            if(money.length <= 9)
            {
                moneyInt[0] = 0;
                for(int i=0; i<9-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                moneyInt[1] = [MoneyN intValue];
            }
            else
            {
                for(int i=0; i<12-money.length;i++)
                {
                    [MoneyN insertString:@"0" atIndex:0];
                }
                DebugAudioLog(@"ApiTypeGetTokenCodeSafety Money = %@",MoneyN);
                moneyInt[0] = [MoneyN substringToIndex:3].intValue;
                moneyInt[1] = [[MoneyN substringFromIndex:(MoneyN.length-9)] intValue];
            }
        }
        if(!name || name.length <= 0 || [name isKindOfClass:[NSNull class]])
        {
            name = @"";
        }
        else
        {
            InterceptionFormatRecordName(nameSt, name, 0);
        }
//        if(SKF_GetTokenCodeSafety_key((LPSTR)[tokenSN UTF8String], audioPortPos,
//                                      (LPSTR)[pin UTF8String], (LPSTR)stringFromHexString(utctime),
//                                      (LPSTR)stringFromHexString(verify), ccountNumInt,
//                                      moneyInt, nameSt, currency) == SAR_OK)
        
        if(SKF_GetTokenCodeSafety_key((LPSTR)[tokenSN UTF8String], audioPortPos,
                                      (LPSTR)PINData, (LPSTR)stringFromHexString(utctime),
                                      (LPSTR)stringFromHexString(verify), ccountNumInt,
                                      moneyInt, nameSt, currency) == SAR_OK)
        {
            NSMutableDictionary *tmpReturn = [[NSMutableDictionary alloc] initWithDictionary:GetTokenReturnData()];
            NSNumber *statues = (NSNumber *)[tmpReturn objectForKey:@"return_status"];
            if (statues.intValue == STATUS_SUCCESS)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x3333)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"按键超时" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
            else if(statues.intValue == 0x6666)
            {
                [tmpReturn removeObjectForKey:@"return_status"];
                if([tmpReturn[reciveKey_ResponseCode] intValue] == 0)
                {
                    [tmpReturn setObject:@"用户取消操作" forKey:reciveKey_ErrorMessage];
                    [tmpReturn setObject:statues forKey:reciveKey_ResponseCode];
                }
                dic = (NSDictionary *)tmpReturn;
            }
        }
        return dic;
    }
    
    NSInteger newRSASignData(NSString *pin, NSData *signData)
    {
        CONTAINER container = g_Container;
        BYTE pbSignature[500] = {0};
        ULONG pulSignLen;
        BYTE hashD[signData.length];
        memcpy(hashD, [signData bytes], signData.length);
        if(SKF_RSASignData(&container, hashD, signData.length, pbSignature, &pulSignLen, (LPSTR)[pin UTF8String], 4) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                BYTE returnData[1024];
                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                printf("newRSASignData tmpReturn2->Data = %d\n", tmpReturn2->Length);
                for(int i=0; i<tmpReturn2->Length; i++)
                {
                    printf("%02x ", returnData[i]);
                }
                printf("\n");
                return 1;
            }
        }
        return -1;
    }
    
    NSData * waitRSASignData(NSInteger length)
    {
        NSData *RsaData = nil;
        
        while (1)
        {
            if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
            {
                break;
            }
            
            SKF_ReadStatus(0);
            ReturnDataEx *RSAData1 = GetReturnDataEx();
            if (RSAData1->Status == 0x0001)
            {
                unsigned char *result = (unsigned char*)calloc(2,sizeof(unsigned char));
                memcpy(result, RSAData1->Data, 2);
                if (result[0] == 0x77 && result[1] == 0x77)
                { //已确认
                    free(result);
                    result = NULL;
                    RsaData = [NSData dataWithBytes:RSAData1->Data length:RSAData1->Length];
                    NSLog(@"RsaData = %@",RsaData);
                    return RsaData;
                    break ;
                }
                else if(result[0] == 0x66 && result[1] == 0x66)
                {//已取消
                    free(result);
                    result = NULL;
                    RsaData =nil;
                    break;
                }
                else if (result[0] == 0x88 && result[1] == 0x88)
                {
                    free(result);
                    result = NULL;
                    RsaData =nil;
                    continue;
                }
                else if(result[0] == 0x99 && result[1] == 0x99)
                {//已超时
                    free(result);
                    result = NULL;
                    RsaData = nil;
                    break;
                }
                free(result);
                result = NULL;
            }
            else
            {
                break;
            }
        }
        return RsaData;
    }
    
    //++++++++获取 PIN 信息++++++++
    NSDictionary * GetPinInfo(int pType)
    {
        NSDictionary *dic = nil;
        int PinRe = open_Application();
        DebugAudioLog(@"PIN = %d",PinRe);
        if(PinRe <= 0)
        {
            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"打开应用失败"};
            return dic;
        }
        ULONG *maxRetryCount = (ULONG *)calloc(2,sizeof(ULONG));
        ULONG *remainRetryCount = (ULONG *)calloc(2,sizeof(ULONG));
        bool *defaultPin = (bool *)calloc(2,sizeof(bool));

        if(SKF_GetPINInfo(&app, pType, maxRetryCount, remainRetryCount, defaultPin) == SAR_OK)
        {
            ReturnDataEx *tmpReturn = GetReturnDataEx();
            if(tmpReturn->Status == STATUS_SUCCESS)
            {
                dic = @{@"statue"           :   [NSNumber numberWithBool:YES],
                        @"errorMsg"         :   @"获取PIN信息成功",
                        @"maxRetryCount"    :   [NSNumber numberWithInt:*maxRetryCount],
                        @"remainRetryCount" :   [NSNumber numberWithInt:*remainRetryCount],
                        @"defaultPin"       :   [NSNumber numberWithBool:*defaultPin]};
                free(maxRetryCount);
                maxRetryCount = NULL;
                free(remainRetryCount);
                remainRetryCount = NULL;
                free(defaultPin);
                defaultPin = NULL;
                return dic;
            }
            else
            {
                dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"获取PIN信息失败"};
                app.wAppID = 0;
            }
        }
        else
        {
            dic = @{@"statue": [NSNumber numberWithBool:NO], @"errorMsg":@"获取PIN信息失败"};
            app.wAppID = 0;
        }
        free(maxRetryCount);
        maxRetryCount = NULL;
        free(remainRetryCount);
        remainRetryCount = NULL;
        free(defaultPin);
        defaultPin = NULL;
        return dic;
    }
    //++++++++++++++++ by zhangjian 20141010 10:00
    
    NSInteger newECCSignData(NSString *pin, NSData *signData, NSInteger p1)
    {
        CONTAINER container = g_Container;
        BYTE pbSignature[500] = {0};
        ULONG pulSignLen;
        BYTE hashD[signData.length];
        memcpy(hashD, [signData bytes], signData.length);
        if(SKF_ECCSignData_new(&container, hashD, signData.length, pbSignature, &pulSignLen, (LPSTR)[pin UTF8String], p1) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                BYTE returnData[1024];
                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                printf("newRSASignData tmpReturn2->Data = %d\n", tmpReturn2->Length);
                for(int i=0; i<tmpReturn2->Length; i++)
                {
                    printf("%02x ", returnData[i]);
                }
                printf("\n");
                return 1;
            }
        }
        return -1;
        
    }
    
    //++++++++++++++++++++++++ signData put in random  by zhangjian 20141011 11:35++++++++++++++
    
    ULONG DEVAPI SKF_RSASignDataByRandom(HCONTAINER hContainer,
                                         BYTE     * pbData,
                                         ULONG      ulDataLen,
                                         BYTE     * pbSignature,
                                         ULONG    * pulSignLen,
                                         LPSTR        szPIN,
                                         UINT       CertFlag,
                                         BYTE     * Random)
    {
        DebugAudioLog(@"");
        
        
        BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
        BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
        BYTE EncData[128]            = { 0 };
        SHA1_CONTEXT  Context;
        
        BYTE         bP1          = 2;
        BYTE         bP2          = 4;
        if(CertFlag == 1)
        {
            bP1          = 3;
            bP2          = 4;
        }
        else
        {
            bP1          = 3;
            bP2          = 2;
        }
        
        BYTE         Blob[2060]    = { 0 };
        PCONTAINER   pContainer   = ( PCONTAINER )hContainer;
        PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
        
        if (pContainer == NULL || pApplication == NULL || pbData == NULL || ulDataLen == 0)
        {
            return SAR_FAIL;
        }
        
        Blob[0] = L_BYTE( pApplication->wAppID );
        Blob[1] = H_BYTE( pApplication->wAppID );
        Blob[2] = L_BYTE( pContainer->wContainerID );
        Blob[3] = H_BYTE( pContainer->wContainerID );
        
        INT i = 0;
        
        g_Callback = CB_GeneralHandleProc;
        
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            memset( PIN, 0x00, DATA_BLOCK_LEN );
        }
        memcpy( PIN, szPIN, strlen( szPIN ) );
        SHA1_Init_Sunyard( &Context );
        SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
        SHA1_Final_Sunyard( &Context, HashKey );
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            SMS4_Init( HashKey );
        }
        SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, EncData, DATA_BLOCK_LEN, NULL );

        g_Callback = NULL;
        
        memcpy( Blob + 4, pbData, ulDataLen );
        memcpy(Blob + 4 + ulDataLen, EncData, DATA_BLOCK_LEN);

        if ( CMD_RSASignData( bP1, bP2, Blob, ulDataLen + 4 + 16) != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        ReturnDataEx *tmpReturn = GetReturnDataEx();
        if (tmpReturn->Status == STATUS_SUCCESS)
        {
            if (pbSignature != NULL)
            {
                memcpy(pbSignature, tmpReturn->Data+6, 128);
                printf("pbSignature:\n");
                for(int i=0; i<128; i++)
                {
                    printf("%02x ", pbSignature[i]);
                }
                printf("\n");
            }
            if (pulSignLen != NULL)
            {
                *pulSignLen = 128;
            }
            return SAR_OK;
            
        }
        return SAR_FAIL;
    }
    
    //++++++++++++++++++++++++
    ULONG DEVAPI SKF_ECCSignDataByRandom(HCONTAINER hContainer,
                                         BYTE     * pbData,
                                         ULONG      ulDataLen,
                                         BYTE     * pbSignature,
                                         ULONG    * pulSignLen,
                                         LPSTR        szPIN,
                                         UINT       CertFlag,
                                         BYTE     * Random)
                                     
    {
        DebugAudioLog(@"");
        
        BYTE PIN[DATA_BLOCK_LEN]     = { 0 };
        BYTE HashKey[DATA_BLOCK_LEN] = { 0 };
        BYTE EncData[128]            = { 0 };
        SHA1_CONTEXT  Context;
        
        BYTE         bP1          = CertFlag;
        
        BYTE         Blob[2060]    = { 0 };
        PCONTAINER   pContainer   = ( PCONTAINER )hContainer;
        PAPPLICATION pApplication = ( PAPPLICATION )&g_Application;
        
        if (pContainer == NULL || pApplication == NULL || pbData == NULL || ulDataLen == 0)
        {
            return SAR_FAIL;
        }
        
        Blob[0] = L_BYTE( pApplication->wAppID );
        Blob[1] = H_BYTE( pApplication->wAppID );
        Blob[2] = L_BYTE( pContainer->wContainerID );
        Blob[3] = H_BYTE( pContainer->wContainerID );
        
        
        INT i = 0;
        
        g_Callback = CB_GeneralHandleProc;
        
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            memset( PIN, 0x00, DATA_BLOCK_LEN );
        }
        memcpy( PIN, szPIN, strlen( szPIN ) );
        SHA1_Init_Sunyard( &Context );
        SHA1_Update_Sunyard( &Context, PIN, DATA_BLOCK_LEN );
        SHA1_Final_Sunyard( &Context, HashKey );
        
        for ( i = 0; i < DATA_BLOCK_LEN; i++ )
        {
            SMS4_Init( HashKey );
        }
        SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, Random, EncData, DATA_BLOCK_LEN, NULL );
        
        g_Callback = NULL;
        
        memcpy( Blob + 4, pbData, ulDataLen );
        memcpy(Blob + 4 + ulDataLen, EncData, DATA_BLOCK_LEN);
        
        if(CMD_ECCSignData(bP1, Blob, ulDataLen+4+16, 0) != STATUS_SUCCESS)
        {
            return SAR_FAIL;
        }
        
        ReturnDataEx *tmpReturn = GetReturnDataEx();
        if (tmpReturn->Status == STATUS_SUCCESS)
        {
            if (pbSignature != NULL)
            {
                memcpy(pbSignature, tmpReturn->Data+6, 128);
                printf("pbSignature:\n");
                for(int i=0; i<128; i++)
                {
                    printf("%02x ", pbSignature[i]);
                }
                printf("\n");
            }
            if (pulSignLen != NULL)
            {
                *pulSignLen = 128;
            }
            return SAR_OK;
            
        }
        return SAR_FAIL;
    }
    //++++++++++++++++++++++++
    
    NSArray * newRSASignDataByRandom(NSString *pin, NSData *signData, NSData *random)
    {
        CONTAINER container = g_Container;
        BYTE pbSignature[500] = {0};
        ULONG pulSignLen;
        BYTE hashD[signData.length];
        memcpy(hashD, [signData bytes], signData.length);
        if(SKF_RSASignDataByRandom(&container, hashD, signData.length, pbSignature, &pulSignLen, (LPSTR)[pin UTF8String], 4, (BYTE *)[random bytes]) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                BYTE returnData[1024];
                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                printf("newRSASignData tmpReturn2->Data = %d\n", tmpReturn2->Length);
                for(int i=0; i<tmpReturn2->Length; i++)
                {
                    printf("%02x ", returnData[i]);
                }
                printf("\n");
                return @[@"1",@"成功"];
            }
            else
            {
                return @[@"-1",@"失败"];
            }
        }
        else
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            char returnData[100] = {'\0'};
            memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
            NSString *errstr = [NSString stringWithUTF8String:returnData];
            NSLog(@"%@", errstr);
            if(errstr == nil)
            {
                errstr = @"操作失败";
            }
            return @[@"-1",errstr];
        }
    }
    
    NSArray * newECCSignDataByRandom(NSString *pin, NSData *signData, NSInteger p1, NSData *random)
    {
        CONTAINER container = g_Container;
        BYTE pbSignature[500] = {0};
        ULONG pulSignLen;
        BYTE hashD[signData.length];
        memcpy(hashD, [signData bytes], signData.length);
        if(SKF_ECCSignDataByRandom(&container, hashD, signData.length, pbSignature, &pulSignLen, (LPSTR)[pin UTF8String], p1, (BYTE *)[random bytes]) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                BYTE returnData[1024];
                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                printf("newRSASignData tmpReturn2->Data = %d\n", tmpReturn2->Length);
                for(int i=0; i<tmpReturn2->Length; i++)
                {
                    printf("%02x ", returnData[i]);
                }
                printf("\n");
                return @[@"1",@"成功"];
            }
            else
            {
                return @[@"-1",@"失败"];
            }
        }
        else
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            char returnData[100] = {'\0'};
            memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
            NSString *errstr = [NSString stringWithUTF8String:returnData];
            NSLog(@"%@", errstr);
            if(errstr == nil)
            {
                errstr = @"操作失败";
            }
            return @[@"-1",errstr];
        }
        
    }
    
    //++++++++ by zhangjian 20151022 15:50
    
    ULONG SKF_GetICCardNum()
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_GetICCardNum();
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        ReturnDataEx *tmpReturn2 = GetReturnDataEx();
        if (tmpReturn2->Status == STATUS_SUCCESS)
        {
            printf("pbSignature:\n");
            for(int i=0; i<tmpReturn2->Length; i++)
            {
                printf("%02x ", tmpReturn2->Data[i]);
            }
            printf("\n");
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    NSString *getICCardNum()
    {
        NSString *num = nil;
        if(SKF_GetICCardNum() == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                CHAR returnData[1024];
                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                printf("newRSASignData tmpReturn2->Data = %d\n", tmpReturn2->Length);
                NSMutableString *str = [[NSMutableString alloc] initWithCapacity:3];
                for(int i=0; i<tmpReturn2->Length; i++)
                {
                    printf("%02x ", returnData[i]);
                    [str appendFormat:@"%02x",returnData[i]];
                }
                printf("\n");
                num = [str substringToIndex:[str rangeOfString:@"d"].location];
                return num;
            }
            else
            {
                return num;
            }
        }
        return num;
    }
    
    ULONG SKF_SufficientMoney(LPSTR money, int length)
    {
        UINT Status = STATUS_FAILED;
        Status = CMD_SufficientMoeny(money,length);
        if ( Status != STATUS_SUCCESS )
        {
            return SAR_FAIL;
        }
        
        ReturnDataEx *tmpReturn2 = GetReturnDataEx();
        if (tmpReturn2->Status == STATUS_SUCCESS)
        {
            printf("pbSignature:\n");
            for(int i=0; i<tmpReturn2->Length; i++)
            {
                printf("%02x ", tmpReturn2->Data[i]);
            }
            printf("\n");
            return SAR_OK;
        }
        else
        {
            return SAR_FAIL;
        }
        return SAR_FAIL;
    }
    
    BOOL SufficientMoney(NSString *money)
    {
        if(money == nil || money.length <= 0 || [money isKindOfClass:[NSNull class]])
        {
            return NO;
        }
        else
        {
            NSRange rang = [money rangeOfString:@"."];
            if(rang.location != NSNotFound)
            {
                money = [money floatToIntWithCentMoney];
            }
        }
        
        if(SKF_SufficientMoney((LPSTR)stringFromHexString(money), money.length/2+money.length%2) == SAR_OK)
        {
            ReturnDataEx *tmpReturn2 = GetReturnDataEx();
            if (tmpReturn2->Status == STATUS_SUCCESS)
            {
                DebugAudioLog(@"tmpReturn2->Type %d",tmpReturn2->Type);
                DebugAudioLog(@"tmpReturn2->Length %d",tmpReturn2->Length);
                DebugAudioLog(@"tmpReturn2->Data %s",tmpReturn2->Data);
                DebugAudioLog(@"tmpReturn2->Data sizeof %zu",strlen(tmpReturn2->Data));
                //                CHAR returnData[1024];
                //                memcpy(returnData, tmpReturn2->Data, tmpReturn2->Length);
                //                printf("newRSASignData tmpReturn2->Data = %d\n", tmpReturn2->Length);
                //                NSMutableString *str = [[NSMutableString alloc] initWithCapacity:3];
                //                for(int i=0; i<tmpReturn2->Length; i++)
                //                {
                //                    printf("%02x ", returnData[i]);
                //                    [str appendFormat:@"%02x",returnData[i]];
                //                }
                //                printf("\n");
                //                num = [str substringToIndex:[str rangeOfString:@"d"].location];
                return YES;
            }
            else
            {
                return NO;
            }
        }
        return NO;
    }

#ifdef __cplusplus
}
#endif



