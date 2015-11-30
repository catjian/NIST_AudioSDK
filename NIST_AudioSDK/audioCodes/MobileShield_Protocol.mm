#include "MobileShield_Protocol.h"
#include <string.h>
#include "MobileShield.h"
#include "sha-1.h"
#include "SMS4.h"
#include "Function.h"
#include "MobileShield_Interface.h"

#include "stdio.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    //#ifdef SKF_INTERFACE
    
    BYTE CmdData[MAX_BUF];
    BYTE WAITLEVEL=0;
    BYTE LONGCMD = 0;
    VOID * CMD_ReadData( UINT nInLen, UINT nIndex, UINT * nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        
        tCmd.CLA = 0;
        tCmd.INS = 0;
        tCmd.P1  = nIndex; 
        tCmd.P2  = 0;
        tCmd.LC  = 0;
        tCmd.LE  = nInLen;
        
        SetReadDataLength( tCmd.LE );
        
        memset( CmdData, 0, MAX_BUF );
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        *nLen = CMD_HEAD_LEN + 2;
        
        return CmdData;
    }
    
    
    /********************** …Ë±∏π‹¿Ì÷∏¡Ó**********************/
    INT CMD_SetLabel( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_SET_LABEL;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GetDevInfo( UINT nRetType )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GET_DEVINFO;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x0000;
        tCmd.LE  = nRetType; // 0x0000 ∆⁄Õ˚∑µªÿ»´≤ø…Ë±∏–≈œ¢
        LONGCMD = 2;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_Transmit( BYTE * pCmd, ULONG uCmdLen, BYTE * pData, ULONG uDataLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        //WAITLEVEL=0;
        tCmd.CLA = pCmd[0];
        tCmd.INS = pCmd[1];
        tCmd.P1  = pCmd[2];
        tCmd.P2  = pCmd[3];
        tCmd.LC  = ( WORD )uDataLen;
        tCmd.LE  = ( WORD )0;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_TransmitEx( BYTE * pData, ULONG uDataLen )
    {
        DebugAudioLog(@"");
	
        INT lRet = 0;
        //WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, pData, uDataLen );
        
        lRet = uDataLen + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    /****************************************************************/
    //
    ///********************** ∑√Œ øÿ÷∆÷∏¡Ó**********************/
    INT CMD_DevAuth( UINT nType, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DEVAUTH;
        tCmd.P1  = 0x00;
        tCmd.P2  = nType; // ƒ¨»œALGORITHM_SM1
        tCmd.LC  = nLen;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN);
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ChangeDevAuthKey( BYTE nType, BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet     = 0;
        //BYTE   pbMAC[4] = { 0 };
        BYTE * pResult  = NULL;
        UINT   ulLen    = 0;
        BYTE * pTemp    = NULL;
        UINT   i        = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x84;
        tCmd.INS = CMD_CHANGE_DEVAUTHKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = nType;
        tCmd.LC  = nLen + 4;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        // º∆À„±®Œƒ»œ÷§¬ÎMAC
        pTemp = CmdData + nLen + CMD_HEAD_LEN + 2;
        ulLen = ( tCmd.LC + CMD_HEAD_LEN - 4 ) % 16;
        *pTemp = 0x80;
        if ( ulLen == 0 )
        {
            memset( pTemp + 1, 0x00, 15 );
            ulLen = nLen + CMD_HEAD_LEN + 16;
        }
        else if ( ulLen == 15 )
        {
            ulLen = nLen + CMD_HEAD_LEN + 1;
        }
        else
        {
            memset( pTemp + 1, 0x00, 15 - ulLen );
            ulLen = ( nLen + CMD_HEAD_LEN + 15 ) / 16 * 16;
        }
        //  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
        SMS4_Init( pbHashKey );
        pTemp = CmdData + 2;
        pResult = pbInitData;
        for ( i = 0; i < ulLen / 16; i++ )
        {
            CalculateMAC( pResult, 16, pTemp + i * 16, pResult );
            SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, pResult, pResult, 16, NULL );
        }
        // ÃÌº”MAC
        pTemp = CmdData + lRet - 4;
        memcpy( pTemp, pResult, 4 );
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GetPINInfo( BYTE nType, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GET_PININFO;
        tCmd.P1  = 0x00; 
        tCmd.P2  = nType;  //√‹‘øÀ˜“˝∫≈
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0003;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ChangePIN( BYTE nType, BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet     = 0;
        //BYTE   pbMAC[4] = { 0 };
        BYTE * pResult  = NULL;
        UINT   ulLen    = 0;
        BYTE * pTemp    = NULL;
        UINT   i        = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x84;
        tCmd.INS = CMD_CHANGE_PIN;
        tCmd.P1  = 0x00;
        tCmd.P2  = nType;
        tCmd.LC  = nLen + 4; //  ˝æ›≥§∂»º”4∏ˆ◊÷Ω⁄MAC
        tCmd.LE  = 0x00;
        
        CmdData[0] = 0x00;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        // º∆À„±®Œƒ»œ÷§¬ÎMAC
        pTemp = CmdData + nLen + CMD_HEAD_LEN + 2;
        ulLen = ( tCmd.LC + CMD_HEAD_LEN - 4 ) % 16;
        *pTemp = 0x80;
        if ( ulLen == 0 )
        {
            memset( pTemp + 1, 0x00, 15 );
            ulLen = nLen + CMD_HEAD_LEN + 16;
        }
        else if ( ulLen == 15 )
        {
            ulLen = nLen + CMD_HEAD_LEN + 1;
        }
        else
        {
            memset( pTemp + 1, 0x00, 15 - ulLen );
            ulLen = ( nLen + CMD_HEAD_LEN + 15 ) / 16 * 16;
        }
        //  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
        SMS4_Init( pbHashKey );
        pTemp = CmdData + 2;
        pResult = pbInitData;
        for ( i = 0; i < ulLen / 16; i++ )
        {
            CalculateMAC( pResult, 16, pTemp + i * 16, pResult );
            SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, pResult, pResult, 16, NULL );
        }
        // ÃÌº”MAC
        pTemp = CmdData + lRet - 4;
        memcpy( pTemp, pResult, 4 );
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    //
    INT CMD_VerifyPIN( BYTE nType, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_VERIFY_PIN;
        tCmd.P1  = 0x00;
        tCmd.P2  = nType;
        tCmd.LC  = nLen; // 0x0012
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_LockDev(HANDLE hHandle, BYTE * pIN,UINT nLen)
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        BYTE pCmdBuf[MAX_BUF];
        // UINT lRecLen;
        INT    lRet = 0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xE0;
        tCmd.P1 = 0;
        tCmd.P2 = 0;
        tCmd.LC = nLen;
        tCmd.LE = 0;
        
        memcpy(pCmdBuf,&tCmd,sizeof(tCmd)) ;
        if(tCmd.LC)
            memcpy(pCmdBuf + CMD_HEAD_LEN, pIN, nLen);
        lRet = SendDataToMobileShield( pCmdBuf, CMD_HEAD_LEN+tCmd.LC, NULL, NULL );
        // INT lRet = APDUInterface(hHandle, pCmdBuf, CMD_HEAD_LEN+tCmd.LC, NULL,&lRecLen);
        
        return lRet;
    }
    
    INT  CMD_UnlockDev(HANDLE hHandle)
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        BYTE pCmdBuf[MAX_BUF];
        // UINT lRecLen;
        INT    lRet = 0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xE1;
        tCmd.P1 = 0;
        tCmd.P2 = 0;
        tCmd.LC = 0;
        tCmd.LE = 0;
        
        memcpy(pCmdBuf,&tCmd,sizeof(tCmd)) ;
        lRet = SendDataToMobileShield( pCmdBuf, CMD_HEAD_LEN+tCmd.LC, NULL, NULL );
        return lRet;
        
        
        //INT lRet = APDUInterface(hHandle, pCmdBuf, CMD_HEAD_LEN+tCmd.LC, NULL,&lRecLen);
        
        //return lRet;
    }
    
    
    INT CMD_UnblockPIN( BYTE * pData, UINT nLen, BYTE pbHashKey[16], BYTE pbInitData[16] )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        //BYTE   pbMAC[4] = { 0 };
        BYTE * pResult  = NULL;
        UINT   ulLen    = 0;
        BYTE * pTemp    = NULL;
        UINT   i        = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x84;
        tCmd.INS = CMD_UNBLOCK_PIN;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen + 4;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        // º∆À„±®Œƒ»œ÷§¬ÎMAC
        pTemp = CmdData + nLen + CMD_HEAD_LEN + 2;
        ulLen = ( tCmd.LC + CMD_HEAD_LEN - 4 ) % 16;
        *pTemp = 0x80;
        if ( ulLen == 0 )
        {
            memset( pTemp + 1, 0x00, 15 );
            ulLen = nLen + CMD_HEAD_LEN + 16;
        }
        else if ( ulLen == 15 )
        {
            ulLen = nLen + CMD_HEAD_LEN + 1;
        }
        else
        {
            memset( pTemp + 1, 0x00, 15 - ulLen );
            ulLen = ( nLen + CMD_HEAD_LEN + 15 ) / 16 * 16;
        }
        //  π”√√‹‘ø∂‘8◊÷Ω⁄ÀÊª˙ ˝ π”√SMS4À„∑®Ω¯––º”√‹£¨º”√‹∫Ûµƒ ˝æ›Œ™EncData
        SMS4_Init( pbHashKey );
        pTemp = CmdData + 2;
        pResult = pbInitData;
        for ( i = 0; i < ulLen / 16; i++ )
        {
            CalculateMAC( pResult, 16, pTemp + i * 16, pResult );
            SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, pResult, pResult, 16, NULL );
        }
        // ÃÌº”MAC
        pTemp = CmdData + lRet - 4;
        memcpy( pTemp, pResult, 4 );
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ClearSecureState( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CLEAR_SECURESTATE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen; //0x0002
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    /****************************************************************/
    
    /********************** ”¶”√π‹¿Ì÷∏¡Ó**********************/
    INT CMD_CreateApplication( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CREATE_APPLICATION;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        WAITLEVEL=2;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        LONGCMD = 1;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_EnumApplication( UINT nRetType )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENUM_APPLICATION;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x0000;
        tCmd.LE  = nRetType; //0x0000
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DeleteApplication( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DELETE_APPLICATION;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        WAITLEVEL=2;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        //LONGCMD = 5;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_OpenApplication( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_OPEN_APPLICATION;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_CloseApplication( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CLOSE_APPLICATION;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen; //0x0002
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    /****************************************************************/
    
    /********************** Œƒº˛π‹¿Ì÷∏¡Ó**********************/
    INT  CMD_CreateFile( UINT nAppID, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CREATE_FILE;
        tCmd.P1  = H_BYTE( nAppID );
        tCmd.P2  = L_BYTE( nAppID );
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DeleteFile( UINT nAppID, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DELETE_FILE;
        tCmd.P1  = H_BYTE( nAppID );
        tCmd.P2  = L_BYTE( nAppID );
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_EnumFiles( UINT nAppID, UINT nRetType )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENUM_FILES;
        tCmd.P1  = H_BYTE( nAppID );
        tCmd.P2  = L_BYTE( nAppID );
        tCmd.LC  = 0x0000;
        tCmd.LE  = nRetType; // 0x0000
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GetFileInfo( UINT nAppID, BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GET_FILEINFO;
        tCmd.P1  = H_BYTE( nAppID );
        tCmd.P2  = L_BYTE( nAppID );
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ReadFile( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_READ_FILE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen; // 0x0000 ∂¡»°À˘”– ˝æ›
        LONGCMD = 1;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_WriteFile( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_WRITE_FILE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        LONGCMD = 1;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, nLen );
        
        lRet = nLen + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    /****************************************************************/
    
    /********************** »›∆˜π‹¿Ì÷∏¡Ó**********************/
    INT CMD_CreateContainer( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CREATE_CONTAINER;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen; //0x0002 ∑µªÿ»›∆˜ID ÷µ
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_OpenContainer( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_OPEN_CONTAINER;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen; //0x0002 ∑µªÿ»›∆˜ID ÷µ
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_CloseContainer( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CLOSE_CONTAINER;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_EnumContainer( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENUM_CONTAINER;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DeleteContainer( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DELETE_CONTAINER;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GetContainerInfo( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GET_CONTAINERINFO;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen; //0x000B
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ImportCertificate( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_IMPORT_CERTIFICATE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ExportCertificate( UINT nType, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_EXPORT_CERTIFICATE;
        tCmd.P1  = nType;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    /****************************************************************/
    
    /********************** √‹¬Î∑˛ŒÒ÷∏¡Ó**********************/
    INT CMD_GenRandom( UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GEN_RANDOM; 
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x00;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GenExtRSAKey( BYTE * pData, UINT nLen, UINT nBitsLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GEN_EXTRSAKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;  //0x0002
        tCmd.LE  = nBitsLen;
        LONGCMD = 3;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GenerateRSAKeyPair( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GEN_RSAKEYPAIR;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;  // 0x0006
        tCmd.LE  = nRetLen;
        WAITLEVEL=2;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        LONGCMD = 3;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;	
    }
    
    INT CMD_ImportRSAKeyPair( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_IMPORT_RSAKEYPAIR;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        LONGCMD = 1;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_RSASignData( BYTE p1, BYTE p2, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_RSA_SIGNDATA;
        tCmd.P1  = p1;
        tCmd.P2  = p2;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        LONGCMD = 2;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    //+++++++++++++备用
//    INT CMD_ECCSignData( BYTE p1, BYTE p2, BYTE * pData, UINT nLen )
//    {
//        DebugAudioLog(@"");
//        TPCCmd tCmd;
//        UINT   lRet = 0;
//        WAITLEVEL=1;
//        tCmd.CLA = 0x80;
//        tCmd.INS = CMD_ECC_SIGNDATA;
//        tCmd.P1  = p1;
//        tCmd.P2  = p2;
//        tCmd.LC  = nLen;
//        tCmd.LE  = 0x0000;
//        LONGCMD = 2;
//        CmdData[0] = STRART_FLAG;
//        CmdData[1] = SYNC_FALG;
//        
//        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
//        if ( tCmd.LC )
//            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
//        
//        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
//        
//        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
//        
//        return lRet;
//    }
    //+++++++++++++
    
    INT CMD_RSAExportSessionKey( BYTE * pData, UINT nLen, UINT nKey )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_RSA_EXPORTSESSIONKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x00;
        LONGCMD = 2;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    INT CMD_DestroySessionKey(BYTE *pData,UINT nLen,UINT nRetType)
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT lRet = 0;
        WAITLEVEL = 0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DESTORY_SESSIONKEY;
        tCmd.P1 = 0x00;
        tCmd.P2 = 0x00;
        tCmd.LC = nLen;
        tCmd.LE = 0x0000;//nRetType
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        memcpy(CmdData+2,&tCmd,CMD_HEAD_LEN);
        if(tCmd.LC)
        {
            memcpy(CmdData+CMD_HEAD_LEN,pData,tCmd.LC);
        }
        
        lRet = SendDataToMobileShield(CmdData,lRet,NULL, NULL);
        
        return lRet;
        
        
    }
    INT CMD_GenECCKeyPair( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GEN_ECCKEYPAIR;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        LONGCMD = 1;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ImportECCKeyPair( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_IMPORT_ECCKEYPAIR;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        LONGCMD = 2;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ECCSignData( UINT nP1, BYTE * pData, UINT nLen, UINT nRetType )
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ECC_SIGNDATA;
        tCmd.P1  = nP1;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetType; // 0x0000 ∆⁄Õ˚…Ë±∏∑µªÿÀ˘”–«©√˚Ω·π˚ ˝æ›
        LONGCMD = 1;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ECCVerify( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ECC_VERIFY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        LONGCMD = 3;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ECCExportSessionKey( BYTE * pData, UINT nLen, UINT nRetType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ECC_EXPORTSESSIONKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetType;  // 0x0000
        LONGCMD = 3;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ExtRSAKeyOperation( BYTE P1, BYTE P2, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_RSA_OPERATION;
        tCmd.P1  = P1;
        tCmd.P2  = P2;
        tCmd.LC  = nLen;
        tCmd.LE  = 0;
        LONGCMD = 3;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, nLen);
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet; 
    }
    
    INT CMD_ExtECCEncrypt( BYTE * pData, UINT nLen, UINT nRetType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_EXTECC_ENCRYPT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        printf("%d",nLen);
        tCmd.LE  = nRetType; //0x0000
        LONGCMD = 3;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ExtECCDecrypt( BYTE * pData, UINT nLen, UINT nRetType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=2;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_EXTECC_DECRYPT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetType; // 0x0000
        LONGCMD = 1;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ExtECCSign( BYTE * pData, UINT nLen, UINT nRetType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_EXTECC_SIGN;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetType;
        LONGCMD = 1;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GenerateAgreementDataWithECC( BYTE * pData, UINT nLen, UINT nType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GENERATE_AGREEMENTDATAWITHECC;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GenerateAgreementDataAndKeyWithECC( BYTE * pData, UINT nLen, UINT nType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GENERATE_AGREEMENTDATAANDKEYWITHECC;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GenerateKeyWithECC( BYTE * pData, UINT nLen, UINT nType )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GENERATE_KEYWITHECC;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nType;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ExportPublicKey( UINT nType, BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_EXPORT_PUBKEY;
        tCmd.P1  = nType;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;  // ∆⁄Õ˚ªÒ»°µƒπ´‘ø≥§∂»°£»Áπ˚Œ™0£¨±Ì æªÒ»° µº ≥§∂»µƒπ´‘ø ˝æ›
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ImportSessionKey( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=1;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_IMPORT_SESSIONKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;  // 0x0002
        // WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        LONGCMD = 2;
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_SetSymmKey( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_IMPORT_SYMMKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_EncryptInit( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENCRYPT_INIT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_Encrypt( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENCRYPT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_EncryptUpdate( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENCRYPT_UPDATE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_EncryptFinal( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_ENCRYPT_FINAL;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DecryptInit( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DECRYPT_INIT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_Decrypt( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DECRYPT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;	
    }
    
    INT CMD_DecryptUpdate( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DECRYPT_UPDATE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DecryptFinal( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DECRYPT_FINAL;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DigestInit( BYTE P2, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DIGEST_INIT;
        tCmd.P1  = 0x00;
        tCmd.P2  = P2;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;	
    }
    
    INT CMD_Digest( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DIGEST;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 1024;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        
        for(int i=0; i<lRet; i++)
        {
            printf("%02x ",CmdData[i]);
        }
        printf("\n\n");
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;	
    }
    
    INT CMD_DigestUpdate( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DIGEST_UPDATE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DigestFinal( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DIGEST_FINAL;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_MacInit( BYTE * pINData, UINT nInLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_MAC_INIT;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nInLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pINData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }	
    
    INT CMD_Mac( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_MAC;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_MacUpdate( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_MAC_UPDATE;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_MacFinal( BYTE * pData, UINT nLen, UINT nRetLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_MAC_FINAL;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = nRetLen;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_DestorySessionKey( BYTE * pData, UINT nLen, UINT nRetType )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_DESTORY_SESSIONKEY;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x000006;
        tCmd.LE  = 0x000000; // nRetType
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_BlockApplication( UINT nType, BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_APPLICATION_BLOCK;
        tCmd.P1  = nType;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_UnblockApplication( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_APPLICATION_UNBLOCK;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_BlockCard()
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CARD_BLOCK;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x0000;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_InternalAuthentication( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        UINT   lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_INTERNAL_AUTHENTICATION;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = nLen;
        tCmd.LE  = 0x0000;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    /****************************************************************/
    
    INT CMD_CardUnBlock()
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CARD_UNBLOCK;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = 0;
        tCmd.LE  = 0;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_CardInit()
    {
        DebugAudioLog(@"");
	
        TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_CARD_INIT;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = 0;
        tCmd.LE  = 0;
        WAITLEVEL=0;
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    
#if AUTHENTICATION_TEST
#define CMD_TYPE1	2 * 4			//√¸¡ÓÕ∑
#define CMD_TYPE2	2 * 5			//√¸¡ÓÕ∑ + LE
#define BLOCK_LEN   16
    
    UINT8 SMS4_ENC( UINT8 * pKey, UINT8 * pIn, UINT8 * pOut, UINT16 nDatalen )
    {
        DebugAudioLog(@"");
	
        if ( nDatalen % 16 )  //±ÿ–Î «16µƒ±∂ ˝
            return -1;
        
        SMS4_Init( pKey );   // π”√hash÷µ◊˜Œ™√‹‘ø
        SMS4_Run( SMS4_ENCRYPT, SMS4_ECB, pIn, pOut, nDatalen, NULL );
        
        return 0;
    }
    
    inline INT GetHexValue( BYTE * inBuf, INT nBufLen )
    {
        DebugAudioLog(@"");
	
        INT N = 0;
        INT M = 0;
        
        for ( INT i = 0; i < nBufLen; i++ )
        {
            M = inBuf[i];
            
            if ( M >= '0' && M <= '9' )
                M = M - 0x30;
            else if ( M >= 'a' && M <= 'f' )
                M = M - 'a' + 10;
            else if ( M >= 'A' && M <= 'F' )
                M = M - 'A' + 10;
            else
                M = 0;
            
            N = N  * 16 + M;
        }
        
        return N;
    }
    
    void StrToHex( BYTE * inBuf, INT nBufLen, BYTE * outBuf )
    {
        DebugAudioLog(@"");
	
        for ( INT i = 0; i < nBufLen / 2; i++ )
            outBuf[i] = GetHexValue( inBuf + i * 2, 2 );
    }
    
    
    INT GetMac( BYTE * strKey, BYTE * inBuf, ULONG * nBufLen )
    {
        DebugAudioLog(@"");
	
        BYTE          pin[32]  = { 0 };
        BYTE          Data[5]  = { 0x80, 0xE9, 0x00, 0x00, 0x10 };
        BYTE        * pMac     = NULL;
        ULONG         nNewLen  = 0;
        UINT          nMacLen  = 0;
        PReturnDataEx pRetData = NULL;
        
        inBuf[4] += 4;
        
        nNewLen = *nBufLen;
        pMac = ( BYTE * )calloc( nNewLen + BLOCK_LEN, sizeof( BYTE ) );
        memset( pMac, 0, nNewLen + BLOCK_LEN );
        memcpy( pMac, inBuf, nNewLen );
        pMac[nNewLen] = 0x80;
        nMacLen = ( nNewLen + BLOCK_LEN - 1 ) / BLOCK_LEN * BLOCK_LEN;
        // »°16◊÷Ω⁄ÀÊª˙ ˝
        CMD_TransmitEx( Data, 5 );
        pRetData = GetReturnDataEx();
        memcpy( pin, pRetData->Data, BLOCK_LEN );
        // º∆À„MAC
        for ( INT i = 0; i < ( INT )( nMacLen / BLOCK_LEN ); i++ )
        {
            for( INT j = 0; j < BLOCK_LEN; j++ )
                pin[j] = pin[j] ^ pMac[i*BLOCK_LEN+j];
            
            SMS4_ENC( strKey, pin, pin, BLOCK_LEN );
        }
        //∏¥÷∆MACµΩ ˝æ›∫Û√Ê
        memcpy( inBuf + nNewLen, pin, 4 );
        *nBufLen += 4;
        
        free( pMac );
        pMac = NULL;
        
        return 0;
    }
    
    INT GetMacEx( BYTE * initData, BYTE * strKey, BYTE * inBuf, ULONG * nBufLen )
    {
        DebugAudioLog(@"");
	BYTE   pin[32] = { 0 };
        BYTE * pMac    = NULL;
        UINT   nLen    = *nBufLen;
        UINT   nMacLen = 0;
        
        pMac = ( BYTE * )calloc( nLen + BLOCK_LEN, sizeof( BYTE ) );
        
        memcpy( pMac, inBuf, nLen );
        pMac[nLen] = 0x80;
        nMacLen = ( nLen + BLOCK_LEN - 1 ) / BLOCK_LEN * BLOCK_LEN;
        
        memcpy( pin, initData, BLOCK_LEN );
        // º∆À„MAC
        for ( INT i = 0; i < ( INT )( nMacLen / BLOCK_LEN ); i++ )
        {
            for( INT j = 0; j < BLOCK_LEN; j++ )
                pin[j] = pin[j] ^ pMac[i*BLOCK_LEN+j];
            
            SMS4_ENC( strKey, pin, pin, BLOCK_LEN );
        }
        //∏¥÷∆MACµΩ ˝æ›∫Û√Ê
        memcpy( inBuf + nLen, pin, 4 );
        *nBufLen += 4;
        
        free( pMac );
        pMac = NULL;
        
        return *nBufLen;
    }
    
    
    INT TransmitData(
                     BYTE * CmdStr,
                     ULONG  nCmdLen,
                     BYTE * KeyMac,
                     BYTE * KeyEnc,
                     BYTE * outBuf )
    {
        DebugAudioLog(@"");
	//»°√¸¡ÓÕ∑
        BYTE * pTemp = NULL;
        BYTE   CLA   = GetHexValue( CmdStr, 2 );
        BYTE   INS   = GetHexValue( CmdStr + 2, 2 );
        BYTE   P1    = GetHexValue( CmdStr + 4, 2 );
        BYTE   P2    = GetHexValue( CmdStr + 6, 2 );
        BYTE   LC    = 0;
        BYTE   LE    = 0;
        ULONG  nLen  = 0;
        INT    i     = 0;
        // ŒﬁLC∫ÕLE
        if ( nCmdLen == CMD_TYPE1 )
        {
            outBuf[0] = CLA;
            outBuf[1] = INS;
            outBuf[2] = P1;
            outBuf[3] = P2;
            
            nLen = 4;
        }
        // ŒﬁLC”–LE
        else if ( nCmdLen == CMD_TYPE2 )
        {
            LE = ( BYTE )GetHexValue( CmdStr + 8, 2 );
            
            outBuf[0] = CLA;
            outBuf[1] = INS;
            outBuf[2] = P1;
            outBuf[3] = P2;
            outBuf[4] = LE;
            
            nLen = 5;
        }
        else
        {
            //»°LC≥§∂»£¨“‘«¯∑÷«Èøˆ3, 4
            LC = ( BYTE )GetHexValue( CmdStr + 8, 2 );
            //		debug_log( AUDIO_MODULE, "\n%04x\n", LC );
            
            outBuf[0] = CLA;
            outBuf[1] = INS;
            outBuf[2] = P1;
            outBuf[3] = P2;
            outBuf[4] = LC;
            
            pTemp = outBuf + 5;
            memcpy( pTemp, CmdStr + 10, LC );
            
            if ( CLA & 0x01 )
            {
                SMS4_ENC( KeyEnc, pTemp, pTemp, LC );
            }
            //√¸¡ÓÕ∑ + LC + DATA
            if ( LC == ( BYTE )( nCmdLen - CMD_TYPE2 ) )
            {
                nLen = LC + 5;
            }
            //√¸¡ÓÕ∑ + LC + DATA + LE
            else
            {
                LE = GetHexValue( CmdStr + nCmdLen - 2, 2 );
                outBuf[ LC + 5 ] = LE;
                
                nLen = LC + 6;
            }
        }
        //–Ë“™º”MAC
        if ( CLA & 0x04 )
        {
            GetMac( KeyMac, outBuf, &nLen );
        }
        
        return nLen;
    }
    
    INT TransmitDataEx(
                       BYTE * CmdStr,
                       ULONG  nCmdLen,
                       BYTE * KeyMac,
                       BYTE * KeyEnc,
                       BYTE * outBuf )
    {
        DebugAudioLog(@"");
	CHAR  LC[3] = { 0 };
        CHAR  LE[3] = { 0 };
        WORD  nLC   = 0;
        //	WORD  nDataLen = 0;
        UINT  nLE = 0;;
        BYTE  cLE = 0;
        ULONG nOutLen = 0;
        ULONG nRet = 0;
        BYTE  cCmBuf[1024] = {0, };
        BYTE  cOutBuf[1024] = {0, };
        BYTE  DataBuf[1024] = {0, };
        //	BYTE  cKeyMac[16];
        //	BYTE  cKeyEnc[16];
        
        if(CmdStr == NULL)
            return -1;
        //»°√¸¡ÓÕ∑
        BYTE CLA = GetHexValue(CmdStr, 2);
        BYTE INS = GetHexValue(CmdStr + 2, 2);
        BYTE  P1 = GetHexValue(CmdStr + 4, 2);
        BYTE  P2 = GetHexValue(CmdStr + 6, 2);
        
        if(nCmdLen == 2 * 4)
        {
            StrToHex(CmdStr, nCmdLen, cCmBuf);
            nOutLen = nCmdLen / 2;
        }
        else if(nCmdLen == 2 * 5)
        {
            nLE = GetHexValue(CmdStr + 8, 2);
            StrToHex(CmdStr, nCmdLen, cCmBuf);
            nOutLen = nCmdLen / 2;
        }
        else
        {
            //»°LC≥§∂»£¨“‘«¯∑÷«Èøˆ3, 4
            nLC = GetHexValue(CmdStr + 8, 2);
            
            memcpy(DataBuf, CmdStr + 10, nLC);
            if(CLA & 0x01)
            {
                SMS4_ENC(KeyEnc, DataBuf, DataBuf, nLC);
            }
            
            if(nLC == (nCmdLen - 2 * 5))	//√¸¡ÓÕ∑ + LC + DATA
            {
                StrToHex(CmdStr, 2 * 5, cCmBuf);
                memcpy(cCmBuf + 5, DataBuf, nLC);
                nOutLen = 5 + nLC;
            }
            else									//√¸¡ÓÕ∑ + LC + DATA + LE
            {
                cLE = GetHexValue(CmdStr + nCmdLen - 2, 2);
                nLE = cLE;
                StrToHex(CmdStr, 10, cCmBuf);
                memcpy(cCmBuf + 5, DataBuf, nLC);
                memcpy(cCmBuf + 5 + nLC, &cLE, 1);
                nOutLen = 5 + nLC + 1;
            }
        }
        
        //–Ë“™º”MAC
        if(CLA & 0x04)
        {
            GetMac( KeyMac, cCmBuf, &nOutLen );
        }
        
        return nOutLen;
    }
    
#endif
    
#ifdef MOBILE_SHIELD_TOKEN
    INT CMD_ReadTokenNum()
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_READTOKEN;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = 0;
        tCmd.LE  = 0;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_SetCalcEq( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_SETCALCEQ;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = nLen;
        tCmd.LE  = 0;
        
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ReadEquipmentNum()
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_READEQ;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = 0;
        tCmd.LE  = 0;
        
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GeneratePermitCode( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GERPERMIT;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = nLen;
        tCmd.LE  = 0;
        
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
#endif
    
    //#ifdef MOBILE_SHIELD_SHOW
    INT CMD_TransmitContent( BYTE * pData, UINT nLen )
    {
        DebugAudioLog(@"");
	TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_SHOWCONTENT;
        tCmd.P1  = 0;
        tCmd.P2  = 0;
        tCmd.LC  = nLen;
        tCmd.LE  = 0;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        if ( tCmd.LC )
            memcpy( CmdData + CMD_HEAD_LEN + 2, pData, tCmd.LC );
        
        lRet = tCmd.LC + CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ReadStatus(int p1)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_READSTATUS;
        tCmd.P1  = p1;
        tCmd.P2  = 0;
        tCmd.LC  = 0;
        tCmd.LE  = 0;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    //#endif
    INT CMD_HandShakeS( )
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xF5;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x00;
        tCmd.LE  = 10;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        memcpy( CmdData + 2, &tCmd, CMD_HEAD_LEN );
        
        lRet = CMD_HEAD_LEN + 2;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
        
    }
    
    
    //#endif
    
#pragma mark - 6100 token Interface
    
    int initpos(BYTE *str, int buf_len, int begin)
    {
        for (int i = 0; i < buf_len; i++)
            str[begin + i] = '\0';
            return begin + buf_len;
    }
    
    int set_UTF8_String(BYTE *str, LPSTR val, int buf_len, int begin)
    {
        //如果val是nil或空就全部置位‘0’
        if (val == nil || strlen(val) < 1)
        {
            return initpos(str, buf_len, begin);
        }
        for (int i = 0; i < buf_len; i++)
        {
            if (i < strlen(val))
            {
                str[begin + i] = val[i];
            }
            else
            {
                //对于超出给定字符长度的地方补0
                str[begin + i] = '\0';
            }
        }
        return begin + buf_len;
    }
    
    int set_UTF8_PWD_String(BYTE *str, LPSTR val, int buf_len, int begin)
    {
        //如果val是nil或空就全部置位‘0’
        printf("\n set_UTF8_String PINData =  ");
        for(int i=0; i<16; i++)
        {
            printf("%02x ",val[i]);
        }
        printf("\n\n");
        for (int i = 0; i < buf_len; i++)
        {
            printf("%02x ",val[i]);
            str[begin + i] = val[i];
        }
        printf("\n\n");
        return begin + buf_len;
    }
    
    int set_int8(BYTE *str, int val, int begin)
    {
        str[begin + 0] = (Byte) (val & 0x000000ff);
        return begin + 1;
    }
    
    int set_int16(BYTE *str, int val, int begin)
    {
        str[begin + 1] = (Byte) (val & 0x000000ff);
        str[begin + 0] = (Byte) ((val >> 8) & 0x0000ff);
        return begin + 2;
    }
    
    int set_int32(BYTE *str, int val, int begin)
    {
        str[begin + 3] = (Byte) (val & 0x000000ff);
        str[begin + 2] = (Byte) ((val >> 8) & 0x0000ff);
        str[begin + 1] = (Byte) ((val >> 16) & 0x00ff);
        str[begin + 0] = (Byte) (val >> 24);
        return begin + 4;
    }
    
    int add_Uint8(BYTE * str, LPSTR val, int length, int begin)
    {
        for(int i=0; i<length; i++)
        {
            str[begin+i] = val[i];
        }
        return length+begin;
    }
    
    INT CMD_QueueToken(LPSTR tokenSN)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeQueryToken;
        tCmd.P2  = 0x00;
        tCmd.LC  = 12;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_UpdatePin(LPSTR tokenSN, LPSTR oldPin, LPSTR newPin)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeUpdatePin;
        tCmd.P2  = 0x00;
        tCmd.LC  = 12+9+9;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_UTF8_String(CmdData, oldPin, 9, lRet);
        lRet = set_UTF8_String(CmdData, newPin, 9, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ActiveTokenPlug(LPSTR tokenSN, LPSTR ActiveCode)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeActiveTokenPlug;
        tCmd.P2  = 0x00;
        tCmd.LC  = 12+4+4;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_UTF8_String(CmdData, ActiveCode, 8, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_UnlockRandomNo(LPSTR tokenSN)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeUnlockRandomNo;
        tCmd.P2  = 0x00;
        tCmd.LC  = 12;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_UnlockPin(LPSTR tokenSN, LPSTR unlockCode)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeUnlockPin;
        tCmd.P2  = 0x00;
        tCmd.LC  = 12+4;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_UTF8_String(CmdData, unlockCode, 4, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GetTokenCodeSafety(LPSTR tokenSN, int audioPortPos,
                                LPSTR pin, LPSTR utctime,
                                LPSTR verify, int *ccountNo,
                                int * money, LPSTR name, int currency)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeGetTokenCodeSafety;
        tCmd.P2  = 0x00;
        tCmd.LC  = 84;
        tCmd.LE  = 0x00;
        
        CmdData[0] = 0x00;
        CmdData[1] = 0x02;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        LPSTR currency_c = (LPSTR)calloc(1, sizeof(LPSTR));
        if(currency != 0)
        {
            itoa(currency_c, currency, 1);
        }
        
        printf("\n CMD_GetTokenCodeSafety PINData =  ");
        for(int i=0; i<16; i++)
        {
            printf("%02x ",pin[i]);
        }
        printf("\n\n");
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_int8(CmdData, audioPortPos, lRet);
        lRet = set_UTF8_PWD_String(CmdData, pin, 16, lRet);
        lRet = add_Uint8(CmdData, utctime, 4, lRet);
        lRet = add_Uint8(CmdData, utctime, 4, lRet);
        lRet = add_Uint8(CmdData, verify, 4, lRet);
        lRet = set_int8(CmdData, 40, lRet);
        lRet = set_int16(CmdData, ccountNo[0], lRet);
        lRet = set_int32(CmdData, ccountNo[1], lRet);
        lRet = set_int32(CmdData, ccountNo[2], lRet);
        lRet = set_int16(CmdData, money[0], lRet);
        lRet = set_int32(CmdData, money[1], lRet);
        lRet = set_UTF8_String(CmdData,  currency_c, 1, lRet);
        lRet = set_UTF8_String(CmdData, name, 23, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_QueryTokenEX()
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeQueryTokenEX;
        tCmd.P2  = 0x00;
        tCmd.LC  = 2;
        tCmd.LE  = 0x00;
        
        CmdData[0] = 0x00;
        CmdData[1] = 0x02;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_QueryVersionHW()
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeQueryVersionHW;
        tCmd.P2  = 0x00;
        tCmd.LC  = 2;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_CancelTrans()
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeCancelTrans;
        tCmd.P2  = 0x00;
        tCmd.LC  = 2;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ShowWallet (LPSTR tokenSN, int audioPortPos,
                        LPSTR pin, LPSTR utctime,
                        LPSTR verify, int *ccountNo,
                        int * money, LPSTR name, int currency)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeShowWallet;
        tCmd.P2  = 0x00;
        tCmd.LC  = 84;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        LPSTR currency_c = (LPSTR)calloc(1, sizeof(LPSTR));
        if(currency != 0)
        {
            itoa(currency_c, currency, 1);
        }
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_int8(CmdData, audioPortPos, lRet);
        lRet = set_UTF8_PWD_String(CmdData, pin, 16, lRet);
        lRet = set_UTF8_String(CmdData, utctime, 4, lRet);
        lRet = set_UTF8_String(CmdData, utctime, 4, lRet);
        lRet = set_UTF8_String(CmdData, verify, 4, lRet);
        lRet = set_int8(CmdData, 40, lRet);
        lRet = set_int16(CmdData, ccountNo[0], lRet);
        lRet = set_int32(CmdData, ccountNo[1], lRet);
        lRet = set_int32(CmdData, ccountNo[2], lRet);
        lRet = set_int16(CmdData, money[0], lRet);
        lRet = set_int32(CmdData, money[1], lRet);
        lRet = set_UTF8_String(CmdData,  currency_c, 1, lRet);
        lRet = set_UTF8_String(CmdData, name, 23, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_GetTokenCodeSafety_key(LPSTR tokenSN, int audioPortPos,
                                   LPSTR pin, LPSTR utctime,
                                   LPSTR verify, int *ccountNo,
                                   int * money, LPSTR name, int currency)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeGetTokenCodeSafety_key;
        tCmd.P2  = 0x00;
        tCmd.LC  = 84;
        tCmd.LE  = 0x00;
        
        CmdData[0] = (is_iPhone6||is_iPhone6p)?STRART_FLAG:0x00;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        LPSTR currency_c = (LPSTR)calloc(1, sizeof(LPSTR));
        if(currency != 0)
        {
            itoa(currency_c, currency, 1);
        }
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_int8(CmdData, audioPortPos, lRet);
        lRet = set_UTF8_PWD_String(CmdData, pin, 16, lRet);
        lRet = set_UTF8_String(CmdData, utctime, 4, lRet);
        lRet = set_UTF8_String(CmdData, utctime, 4, lRet);
        lRet = set_UTF8_String(CmdData, verify, 4, lRet);
        lRet = set_int8(CmdData, 40, lRet);
        lRet = set_int16(CmdData, ccountNo[0], lRet);
        lRet = set_int32(CmdData, ccountNo[1], lRet);
        lRet = set_int32(CmdData, ccountNo[2], lRet);
        lRet = set_int16(CmdData, money[0], lRet);
        lRet = set_int32(CmdData, money[1], lRet);
        lRet = set_UTF8_String(CmdData,  currency_c, 1, lRet);
        lRet = set_UTF8_String(CmdData, name, 23, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    INT CMD_ScanCode(LPSTR tokenSN, int audioPortPos,
                     LPSTR pin, LPSTR utctime,
                     LPSTR verify, int *ccountNo,
                     int * money, LPSTR name, int currency)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = 0xcc;
        tCmd.P1  = ApiTypeScanCode;
        tCmd.P2  = 0x00;
        tCmd.LC  = 84;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        LPSTR currency_c = (LPSTR)calloc(1, sizeof(LPSTR));
        if(currency != 0)
        {
            itoa(currency_c, currency, 1);
        }
        
        lRet = set_UTF8_String(CmdData, tokenSN, 12, lRet);
        lRet = set_int8(CmdData, audioPortPos, lRet);
        lRet = set_UTF8_PWD_String(CmdData, pin, 16, lRet);
        lRet = set_UTF8_String(CmdData, utctime, 4, lRet);
        lRet = set_UTF8_String(CmdData, utctime, 4, lRet);
        lRet = set_UTF8_String(CmdData, verify, 4, lRet);
        lRet = set_int8(CmdData, 40, lRet);
        lRet = set_int16(CmdData, ccountNo[0], lRet);
        lRet = set_int32(CmdData, ccountNo[1], lRet);
        lRet = set_int32(CmdData, ccountNo[2], lRet);
        lRet = set_int16(CmdData, money[0], lRet);
        lRet = set_int32(CmdData, money[1], lRet);
        lRet = set_UTF8_String(CmdData,  currency_c, 1, lRet);
        lRet = set_UTF8_String(CmdData, name, 23, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    //+++++++++++
    
    //++++++++ by zhangjian 20151022 15:50
    INT CMD_GetICCardNum()
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_GETICCARDNUM;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x00;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        UINT8 prod = 0;
        UINT8 verd = 0;
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        memcpy( CmdData + lRet, &prod, 1 );
        lRet += 1;
        memcpy( CmdData + lRet, &verd, 1 );
        lRet += 1;
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
    int set_Money_String(BYTE *str, LPSTR val, int buf_len, int val_len, int begin)
    {
        int j = 0;
        for (int i = 0; i < buf_len - val_len; i++)
        {
            //对于超出给定字符长度的地方补0
            str[begin + i] = '\0';
            j += i;
        }
        for(int i=0; i < val_len; i++)
        {
            str[begin + j + i] = val[i];
        }
        return begin + buf_len;
    }
    
    INT CMD_SufficientMoeny(LPSTR money,int lenght)
    {
        DebugAudioLog(@"");
        TPCCmd tCmd;
        INT    lRet = 0;
        WAITLEVEL=0;
        tCmd.CLA = 0x80;
        tCmd.INS = CMD_Sufficient;
        tCmd.P1  = 0x00;
        tCmd.P2  = 0x00;
        tCmd.LC  = 0x06;
        tCmd.LE  = 0x00;
        
        CmdData[0] = STRART_FLAG;
        CmdData[1] = SYNC_FALG;
        
        lRet = 2;
        memcpy( CmdData + lRet, &tCmd, CMD_HEAD_LEN );
        lRet += CMD_HEAD_LEN;
        
        
        lRet = set_Money_String(CmdData, money, 6, lenght, lRet);
        
        lRet = SendDataToMobileShield( CmdData, lRet, NULL, NULL );
        
        return lRet;
    }
    
#ifdef __cplusplus
}
#endif

