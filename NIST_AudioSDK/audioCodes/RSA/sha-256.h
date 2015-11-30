/***************************************************************************************
* File name    :	SHA-256.h
* Function     :	The header of SHA-256.c
* Author       : 	Howard
* Date         :	2010/09/03
* Version      :    v1.0
* Description  :    
* ModifyRecord :
*****************************************************************************************/
 
#ifndef _SHA2_H
#define _SHA2_H

#include "global.h"
 
typedef struct
{
    UINT32 total[2];     /*!< number of bytes processed  */
    UINT32 state[8];     /*!< intermediate digest state  */
    UINT8 buffer[64];   /*!< data block being processed */

    UINT8 ipad[64];     /*!< HMAC: inner padding        */
    UINT8 opad[64];     /*!< HMAC: outer padding        */
    UINT8 is224;                  /*!< 0 => SHA-256, else SHA-224 */
}
SHA256_CONTEXT;
 
void SHA256_Init( SHA256_CONTEXT *ctx, UINT8 is224 );
 
void SHA256_Update( SHA256_CONTEXT *ctx, UINT8 *input, INT32 ilen );
 
void SHA256_Final( SHA256_CONTEXT *ctx, UINT8 output[32] );
 

#endif /* sha2.h */
