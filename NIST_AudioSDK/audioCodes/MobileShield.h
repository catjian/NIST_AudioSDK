

#include "global.h"

#include "MobileShield_Interface.h"



#define STATUS_TIMEOUT              -1
#define STATUS_FAILED              0x0000        
#define STATUS_SUCCESS             0x0001


#define MAX_SEND_TIME              3
#define MAX_READ_DATA_LENGTH       50



typedef INT STATUS;

typedef struct _tagReturnData
{
	INT    Status;
	SHORT  Type;
	VOID * Data;
}
Return_Data;

typedef struct _tagReturnDataEx
{
	INT   Status;
	INT   Type;
	INT   Length;
	CHAR  Data[2048/*MAX_OUTPUT*/];
}
ReturnDataEx, *PReturnDataEx;

@interface CMobileShield : NSObject

@property (nonatomic) NSInteger waitApiType;

+(CMobileShield *)shareMobileShield;
    
STATUS SendDataToMobileShield( VOID * data, INT len, VOID* obj, VOID * cbf );
    
USHORT GetReadDataLength();

VOID   SetReadDataLength( USHORT len );

ReturnDataEx * GetReturnDataEx();

NSDictionary *GetTokenReturnData();

-(BOOL)audioRoute_IsPlugedIn;

+(ApiType)get6100ApitType;

+(void)stopAudioSessionControl;


STATUS YH_SendDataToMobileShield( VOID * data, INT len, VOID* obj, VOID * cbf );

+(void)newSetBufferSize:(unsigned long) sizelength;

@end



@interface NSString (CategoryForString_moblie)

-(NSString *)intToFloatWithCentMoney;

-(NSString *)floatToIntWithCentMoney;

-(NSString *)FormatMoney;

+ (NSString*)getDeviceVersion;

@end

