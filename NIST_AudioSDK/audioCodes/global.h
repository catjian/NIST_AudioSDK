/*
	GLOBAL.H - RSAEURO types and constants

	Copyright (c) J.S.A.Kapp 1994 - 1995.

	RSAEURO - RSA Library compatible with RSAREF(tm) 2.0.

	All functions prototypes are the Same as for RSAREF(tm).
	To aid compatiblity the source and the files follow the
	same naming comventions that RSAREF(tm) uses.  This should aid
	direct importing to your applications.

	This library is legal everywhere outside the US.  And should
	NOT be imported to the US and used there.

	All Trademarks Acknowledged.

	Global types and contants file.

	Revision 1.00 - JSAK 23/6/95, Final Release Version
*/

#ifndef _GLOBAL_H_
#define _GLOBAL_H_

/* PROTOTYPES should be set to one if and only if the compiler supports
		 function argument prototyping.
	 The following makes PROTOTYPES default to 1 if it has not already been
		 defined as 0 with C compiler flags. */

#ifndef PROTOTYPES
#define PROTOTYPES 1
#endif

#ifndef TRUE
#define TRUE            1
#endif
#ifndef FALSE
#define FALSE           0
#endif
#ifndef NULL
#define NULL            0
#endif
#ifndef VOID
typedef void            VOID;
#endif
#ifndef INT8
typedef char            INT8;
#endif
#ifndef UINT8
typedef unsigned char   UINT8;
#endif
#ifndef INT16
typedef short           INT16;
#endif
#ifndef UINT16
typedef unsigned short  UINT16;
#endif
#ifndef INT32
typedef int             INT32;
#endif
#ifndef UINT32
typedef unsigned int    UINT32;
#endif
#ifndef LONG
typedef long            LONG;
#endif
#ifndef ULONG
typedef unsigned long   ULONG;
#endif
#ifndef WIN32
#ifndef BOOL
//typedef UINT8           BOOL;
#endif
#endif
#ifndef CHAR
typedef INT8            CHAR;
#endif
#ifndef BYTE
typedef UINT8           BYTE;
#endif
#ifndef SHORT
typedef INT16           SHORT;
#endif
#ifndef USHORT
typedef UINT16          USHORT;
#endif
#ifndef INT
typedef INT32           INT;
#endif
#ifndef UINT
typedef UINT32          UINT;
#endif
#ifndef WORD
typedef UINT16          WORD;
#endif
#ifndef DWORD
typedef ULONG           DWORD;
#endif
#ifndef FLAGS
typedef UINT32          FLAGS;
#endif
#ifndef LPSTR
typedef CHAR *          LPSTR;
#endif
#ifndef HANDLE
typedef void *          HANDLE;
#endif

/* POINTER defines a generic pointer type */
typedef unsigned char *POINTER;

/* UINT2 defines a two byte word */
typedef unsigned short int UINT2;

/* UINT4 defines a four byte word */
typedef unsigned long int UINT4;

/* BYTE defines a unsigned character */
//typedef unsigned char BYTE;

/* internal signed value */
typedef signed long int signeddigit;

#ifndef NULL_PTR
#define NULL_PTR ((POINTER)0)
#endif

#ifndef UNUSED_ARG
#define UNUSED_ARG(x) x = *(&x);
#endif

/* PROTO_LIST is defined depending on how PROTOTYPES is defined above.
	 If using PROTOTYPES, then PROTO_LIST returns the list, otherwise it
	 returns an empty list. */

#if PROTOTYPES
#define PROTO_LIST(list) list
#else
#define PROTO_LIST(list) ()
#endif

#endif /* _GLOBAL_H_ */


#define STRART_FLAG 0x01
#define SYNC_FALG   0x02

#define DebugAudioLog(s,...) {}
//#define DebugAudioLog(s,...) NSLog(@"DebugAudioLog \n文件：%@ \n 方法名：%@:(第%d) >> \n%@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent],[NSString stringWithUTF8String:__FUNCTION__],__LINE__,[NSString stringWithFormat:(s),##__VA_ARGS__])
