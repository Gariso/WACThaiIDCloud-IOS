

#import <Foundation/Foundation.h>

#import "BleComm.h"

@protocol MPayBleLibDelegate <NSObject>

@required
- (void)onMPayBleResponse_Error:(int)iErrorCode Message:(NSString*)sMessage;
- (void)onMPayBleResponse_UpdateState:(int)iStateCode Message:(NSString*)sMessage;
@optional

- (void)onMPayBleResponse_GetDevice:(BOOL)bSucceed peripheral:(CBPeripheral *)peripheral;
- (void)onMPayBleResponse_IsConnected:(BOOL)bSucceed;
- (void)onMPayBleResponse_GetVersionString:(BOOL)bSucceed sMessage:(NSString*)sMessage;
- (void)onMPayBleResponse_GiveUpAction:(BOOL)bSucceed;
- (void)onMPayBleResponse_GetBattery:(BOOL)bSucceed battery:(int)iBattery;
- (void)onMPayBleResponse_SetSleepTimer:(BOOL)bSucceed;
- (void)onMPayBleResponse_GetTerminalSn:(BOOL)bSucceed sMessage:(NSString*)sMessage;
- (void)onMPayBleResponse_SetTerminalSn:(BOOL)bSucceed;

//#pragma mark - China ID 2nd Delegate
//- (void)onMPayBleResponse_Id2LoadParam:(BOOL)bSucceed;
//- (void)onMPayBleResponse_DirectCmd:(BOOL)bSucceed Data:(NSString*)sData;

#pragma mark - ICC Delegate
- (void)onMPayBleResponse_IccSelect:(BOOL)bSucceed;
- (void)onMPayBleResponse_IccStatus:(BOOL)bSucceed isInserted:(BOOL)isInserted;
- (void)onMPayBleResponse_IccPowerOn:(BOOL)bSucceed Atr:(NSString*)sAtr;
- (void)onMPayBleResponse_IccAccess:(BOOL)bSucceed Rapdu:(NSString*)sRapdu;
- (void)onMPayBleResponse_IccPowerOff:(BOOL)bSucceed;

#pragma mark - MAG Delegate
- (void)onMPayBleResponse_MagCardRead:(BOOL)bSucceed
                           Track1Data:(NSString*)sTrack1Data
                           Track2Data:(NSString*)sTrack2Data
                           Track3Data:(NSString*)sTrack3Data;

#pragma mark - PICC Delegate
- (void)onMPayBleResponse_PiccActivation:(BOOL)bSucceed SerialNumber:(NSString*)sSerialNumber;
- (void)onMPayBleResponse_PiccRate:(BOOL)bSucceed Ats:(NSString*)sAts;
- (void)onMPayBleResponse_PiccAccess:(BOOL)bSucceed Rapdu:(NSString*)sRapdu;
- (void)onMPayBleResponse_IccGetCardholder:(BOOL)bSucceed CardNumber:(NSString*)sCardNumber CardHolderName:(NSString*)sCardHolderName Date:(NSString*)sDate;
- (void)onMPayBleResponse_PiccDeactivation:(BOOL)bSucceed;

- (void)onMPayBleResponse_MifareAuth:(BOOL)bSucceed;
- (void)onMPayBleResponse_MifareReadBlock:(BOOL)bSucceed sData:(NSString*)sData;
- (void)onMPayBleResponse_MifareWriteBlock:(BOOL)bSucceed;
- (void)onMPayBleResponse_MifareIncrement:(BOOL)bSucceed;
- (void)onMPayBleResponse_MifareDecrement:(BOOL)bSucceed;


#pragma mark - MEM Delegate
/**
 * Function Name: onSMP_MEM_SelectCardType
 * Description  : Response Select memory card type status.
 * Parameter    : bStatus    -  true: success
 *                             false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_SelectCardType:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_PowerOn
 * Description  : Response memory card power-on status,and get atr.
 * Parameter    : bStatus    -  true: success
 *                             false: onMPayBleResponse_Error
 *                   sATR    - Get memory card's ATR values.(SLE4442/SLE4428 have ATR)
 */
- (void)onSMP_MEM_PowerOn:(BOOL)bSucceed atr:(NSString*)sAtr;

/**
 * Function Name: onSMP_MEM_GetCardType
 * Description  : Response get memory card type status.
 * Parameter    : bStatus    -  true: success
 *                             false: onMPayBleResponse_Error
 *                iCardType& sCardTypeName -
 *                               0x02: SLE4442    0x13: AT24C32
 *                               0x04: SLE4428    0x14: AT24C64
 *                               0x0A: AT24C01    0x1B: AT88SC102
 *                               0x0B: AT24C02    0x1C: AT88SC1604
 *                               0x0C: AT24C04    0x1D: AT88SC153
 *                               0x0D: AT24C08    0x1E: AT88SC1608
 *                               0x0E: AT24C16
 */
- (void)onSMP_MEM_GetCardType:(BOOL)bSucceed cardType:(int)iCardType;

/**
 * Function Name: onSMP_MEM_ReadData
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 *                sData    - Memory card data.
 */
- (void)onSMP_MEM_ReadData:(BOOL)bSucceed data:(NSString*)sData;

/**
 * Function Name: onSMP_MEM_WriteData
 * Description  : Response write memory card data status.
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_WriteData:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_PowerOff
 * Description  : Response power off memory card status.
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_PowerOff:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_SLE4428_SLE4442_GetErrorCounter
 * Description  : Response memory card error counter status,and get error counter.
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 *                iErrorCounter - Memory card error counter
 */
- (void)onSMP_MEM_SLE4428_SLE4442_GetErrorCounter:(BOOL)bSucceed errCount:(int)iErrorCounter;

/**
 * Function Name: onSMP_MEM_SLE4428_SLE4442_VerifyPSC
 * Description  : Response verify memory card password status. (for SLE4442/SLE4428)
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_SLE4428_SLE4442_VerifyPSC:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_SLE4428_SLE4442_GetPSC
 * Description  : Response get memory card password status,and get Password (for SLE4442/SLE4428)
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 *                sPSC     - Password.(SLE4442: 3 byte)(SLE4428: 2 byte)
 */
- (void)onSMP_MEM_SLE4428_SLE4442_GetPSC:(BOOL)bSucceed psc:(NSString*)sPsc;

/**
 * Function Name: onSMP_MEM_SLE4428_SLE4442_ModifyPSC
 * Description  : Response modify memory card password status.
 * Parameter    : bStatus    - true: success
 *                            false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_SLE4428_SLE4442_ModifyPSC:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_SLE4428_ReadDataWithPB
 * Description  : Response read memory card data with protect bit status,and get data with protect bit.
 * Parameter    : bStatus    - true: success
 *                            false: onMPayBleResponse_Error
 *                sData      - Memory card data with protect bit.
 */
- (void)onSMP_MEM_SLE4428_ReadDataWithProtectBit:(BOOL)bSucceed data:(NSString*)sData;

/**
 * Function Name: onSMP_MEM_SLE4428_WriteDataWithPB
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_SLE4428_WriteDataWithProtectBit:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_SLE4442_ReadProtectionData
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 *                sData    - Memory card Protection data
 */
- (void)onSMP_MEM_SLE4442_ReadProtectionData:(BOOL)bSucceed data:(NSString*)sData;

/**
 * Function Name: onSMP_MEM_SLE4442_WriteProtectionData
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_SLE4442_WriteProtectionData:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_AT88SC153_AT88SC1608_InitializeAuth
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_AT88SC153_AT88SC1608_InitializeAuth:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_AT88SC153_AT88SC1608_VerifyAuth
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_AT88SC153_AT88SC1608_VerifyAuth:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_AT88SC153_AT88SC1608_VerifyPassword
 * Description  : Response status
 * Parameter    : bStatus  - true: success
 *                          false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_AT88SC153_AT88SC1608_VerifyPassword:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_AT88SC102_AT88SC1604_CompareSecurityCode
 * Description  : Response status
 * Parameter    : bStatus  - true : success
 *                           false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_AT88SC102_AT88SC1604_CompareSecurityCode:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_AT88SC102_AT88SC1604_SwitchSecurityLevel
 * Description  : Response memory card switch security level
 * Parameter    : bStatus  - true : success
 *                           false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_AT88SC102_AT88SC1604_SwitchSecurityLevel:(BOOL)bSucceed;

/**
 * Function Name: onSMP_MEM_AT88SC102_AT88SC1604_BlownFuse
 * Description  : Response memory card blown fuse status
 * Parameter    : bStatus  - true : success
 *                           false: onMPayBleResponse_Error
 */
- (void)onSMP_MEM_AT88SC102_AT88SC1604_BlownFuse:(BOOL)bSucceed;

@end




@interface MPayBleLib : NSObject <BleCommDelegate>
{}

@property (nonatomic, retain) id<MPayBleLibDelegate> delegate;

@property (nonatomic, strong) CBPeripheral *savePeripheral; //save the last connection peripheral


#pragma mark SrLib

//- (BOOL)mPayBle_Id2LoadParam:(int)index data:(NSString*)sData;
//
//- (BOOL)mPayBle_DirectCmd:(NSString*)sData;

// Propose: get SDK version string
//
// Parameters:
//
// Return:
//      sdk version string
//
- (NSString*)mPayBle_GetSdkVersion;

// Propose: searching ble device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayBleResponse_GetDevice
//
- (BOOL)mPayBle_SearchDevice;

// Propose: stop search ble device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//
- (BOOL)mPayBle_StopSearching;

// Propose: connected the device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayBleResponse_isConnected
//
- (BOOL)mPayBle_ConnectDevice:(CBPeripheral*) peripheral;

// Propose: retrieve ble device
//
// Parameters:
//              uuid: Device's uuid
//
// Return:
//      true "Success", false "Error"
// Note:
//
- (BOOL)mPayBle_RetrieveDevice:(NSString*) uuid;

// Propose: disconnect ble device
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//
- (BOOL)mPayBle_DisconnectDevice;

// Propose: release ble devic
//
// Parameters:
//
// Return:
//      
// Note:
//
- (void)mPayBle_Release;

// Propose: get reader version string
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayAudioResponse_GetVersionString
//
- (BOOL)mPayBle_GetReaderVersion;

// Propose: give up transaction
//
// Parameters:
//
// Return:
//      true "Success", false "Error"
// Note:
//      delegate: onMPayAudioResponse_GiveUpAction
//
- (BOOL)mPayBle_GiveUpAction;

// Detect battery energy
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response(1byte): battery energy, 0~3(full) 5(charging).
//
- (BOOL)mPayBle_GetBattery;

// Set Sleep Mode Timmer
//
// input
//      Timer(1byte): into Sleep Timmer, 0~30s.
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_SetSleepTimer:(int)Timer;

// Get Terminal Serial Number
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_GetTerminalSn;

// Set Terminal Serial Number
//
// input
//      sSn(16byte): serial number.
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_SetTerminalSn:(NSString*)sSn;



#pragma mark - MEM CALL
/**
 * Function Name: SMP_MEM_SelectCardType
 * Description  : Select memory card type.
 * Parameter    : iCardType - Set memory cards type.(int 0x iCardType)
 *                               0x02: SLE4442    0x13: AT24C32
 *                               0x04: SLE4428    0x14: AT24C64
 *                               0x0A: AT24C01    0x1B: AT88SC102
 *                               0x0B: AT24C02    0x1C: AT88SC1604
 *                               0x0C: AT24C04    0x1D: AT88SC153
 *                               0x0D: AT24C08    0x1E: AT88SC1608
 *                               0x0E: AT24C16
 *
 * Return        : success  - onSMP_MEM_SelectCardType(boolean bStatus)
 *                    fail        - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SelectCardType:(int)cardType;

/**
 * Function Name: SMP_MEM_PowerOn
 * Description  : Memory card power on and reset.
 * Parameter    :
 * Return       : success  - onSMP_MEM_PowerOn(boolean bStatus, String sATR)
 *                    fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_PowerOn;

/**
 * Function Name: SMP_MEM_GetCardType
 * Description  : Get memory card type.
 * Parameter    :
 * Return       : success  - onSMP_MEM_GetCardType(boolean bStatus, int iCardType, String sCardTypeName)
 *                    fail - onMPayBleResponse_Error
 *
 */
- (BOOL)SMP_MEM_GetCardType;

/**
 * Function Name: SMP_MEM_ReadData
 * Description  : Read memory card data.
 * Parameter    : sAddress - Set read memory card start address.(0000~FFFF)
 *                              (AT88SC153/1608, AdrH=Zone index)
 *                              (AT88SC153:0x0-0x3, AT88SC1608:0x0-0x8)
 *                 iLength - Read data length.(0001~0400)
 *
 * Return       : success  - onSMP_MEM_ReadData(boolean bStatus, String sData)
 *                    fail - onMPayBleResponse_Error
 *
 */
- (BOOL)SMP_MEM_ReadData:(NSString*)sAddress len:(int)iLength;

/**
 * Function Name: SMP_MEM_WriteData
 * Description  : Write memory card data.
 * Parameter    : sAddress - Set write memory card's start address.(0000~FFFF)
 *                 iLength - Write data length.(0001~0100)
 *                   sData - Write data.(1~256 byte)
 *
 * Return       : success  - onSMP_MEM_WriteData(boolean bStatus)
 *                    fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_WriteData:(NSString*)sAddress len:(int)iLength data:(NSString*)sData;

/**
 * Function Name: SMP_MEM_PowerOff
 * Description  : Power off memory card.
 * Parameter    :
 * Return       : success - onSMP_MEM_PowerOff(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_PowerOff;

/**
 * Function Name: SMP_MEM_SLE4428_SLE4442_GetErrorCounter
 * Description  : Get memory card error counter. (for SLE4442/SLE4428)
 * Parameter    :
 * Return       : success - onSMP_MEM_SLE4428_SLE4442_GetErrorCounter(boolean bStatus, int iErrorCounter)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4428_SLE4442_GetErrorCounter;

/**
 * Function Name: SMP_MEM_SLE4428_SLE4442_VerifyPSC
 * Description  : Verify memory card password. (for SLE4442/SLE4428)
 * Parameter    : sPSC    - Password. (SLE4442: 3 byte)(SLE4428: 2 byte)
 *
 * Return       : success - onSMP_MEM_SLE4428_SLE4442_VerifyPSC(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4428_SLE4442_VerifyPSC:(NSString*)sPsc;

/**
 * Function Name: SMP_MEM_SLE4428_SLE4442_GetPSC
 * Description  : Get memory card password. (for SLE4442/SLE4428)
 * Parameter    : iLength - PSC length.(SLE4442: 0003)(SLE4428: 0002)
 *
 * Return       : success - onSMP_MEM_SLE4428_SLE4442_GetPSC(boolean bStatus, String sPSC)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4428_SLE4442_GetPSC:(int)iLength;

/**
 * Function Name: SMP_MEM_SLE4428_SLE4442_ModifyPSC
 * Description  : Modify memory card password. (for SLE4442/SLE4428)
 * Parameter    : sPSC    - Password. (SLE4442: 3 byte)(SLE4428: 2 byte)
 *
 * Return       : success - onSMP_MEM_SLE4428_SLE4442_ModifyPSC(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4428_SLE4442_ModifyPSC:(NSString*)sPsc;

/**
 * Function Name: SMP_MEM_SLE4428_ReadDataWithPB
 * Description  : Read memory card data with protect bit. (for SLE4428)
 * Parameter    : sAddress - Set read memory card start address.(0000~FFFF)
 *                 iLength - Read data length.(0001~0200)
 *
 * Return       : success - onSMP_MEM_SLE4428_ReadDataWithPB(boolean bStatus, String sData)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4428_ReadDataWithPB:(NSString*)sAddress len:(int)iLength;

/**
 * Function Name: SMP_MEM_SLE4428_WriteDataWithPB
 * Description  : Write memory card data with protect bit. (for SLE4428)
 * Parameter    : sAddress - Set write memory card's start address.(0000~FFFF)
 *                 iLength - Write data length.(0001~0100)
 *                   sData - Write data.(1~256 byte)
 *
 * Return       : success - onSMP_MEM_SLE4428_WriteDataWithPB(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4428_WriteDataWithPB:(NSString*)sAddress len:(int)iLength data:(NSString*)sData;

/**
 * Function Name: SMP_MEM_SLE4442_ReadProtectionData
 * Description  : Read memory card Protection data. (for SLE4442)
 * Parameter    :
 * Return       : success - onSMP_MEM_SLE4442_ReadProtectionData(boolean bStatus, String sData)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4442_ReadProtectionData;

/**
 * Function Name: SMP_MEM_SLE4442_WriteProtectionData
 * Description  : Write memory card protection data. (for SLE4442)
 * Parameter    : sAddress - Set Write memory card start address.(0000~001F)(AdrL:0x0-0x1F)
 *                 iLength - Write data length.(0001~0020)(LLn: 0x1-0x20)
 *                   sData - Write data.(the same as main memory)
 *
 * Return       : success - onSMP_MEM_SLE4442_WriteProtectionData(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_SLE4442_WriteProtectionData:(NSString*)sAddress len:(int)iLength data:(NSString*)sData;

/**
 * Function Name: SMP_MEM_AT88SC153_AT88SC1608_InitializeAuth
 * Description  : Memory card initialize authentication . (for AT88SC153/AT88SC1608)
 * Parameter    : sRandomNo - Random number (8 byte)
 *
 * Return       : success - onSMP_MEM_AT88SC153_AT88SC1608_InitializeAuth(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_AT88SC153_AT88SC1608_InitializeAuth:(NSString*)sRandomNo;

/**
 * Function Name: SMP_MEM_AT88SC153_AT88SC1608_VerifyAuth. (for AT88SC153/AT88SC1608)
 * Description  : Memory card verify authentication
 * Parameter    : sEncryptedData - Encrypted Data (8 byte)
 *
 * Return       : success - onSMP_MEM_AT88SC153_AT88SC1608_VerifyAuth(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_AT88SC153_AT88SC1608_VerifyAuth:(NSString*)sEncryptedData;

/**
 * Function Name: SMP_MEM_AT88SC153_AT88SC1608_VerifyPassword
 * Description  : Memory card verify password. (for AT88SC153/AT88SC1608)
 * Parameter    : sPsc - Password. (3 byte)
 *
 * Return       : success - onSMP_MEM_AT88SC153_AT88SC1608_VerifyPassword(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_AT88SC153_AT88SC1608_VerifyPassword:(NSString*)sPsc;

/**
 * Function Name: SMP_MEM_AT88SC102_AT88SC1604_CompareSecurityCode
 * Description  : Memory card compare security code.(for AT88SC102/AT88SC1604)
 * Parameter    : sAddress - Set security code start address.
 *                   sData - security code.(2~6 byte)
 *
 * Return       : success - onSMP_MEM_AT88SC102_AT88SC1604_CompareSecurityCode(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_AT88SC102_AT88SC1604_CompareSecurityCode:(NSString*)sAddress data:(NSString*)sData;

/**
 * Function Name: SMP_MEM_AT88SC102_AT88SC1604_SwitchSecurityLevel
 * Description  : Memory card switch security level. (for AT88SC102/AT88SC1604)
 * Parameter    : iLevel - 0x1 Level One ,0x2 Level Two
 *
 * Return       : success - onSMP_MEM_AT88SC102_AT88SC1604_SwitchSecurityLevel(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_AT88SC102_AT88SC1604_SwitchSecurityLevel:(int)iLevel;

/**
 * Function Name: SMP_MEM_AT88SC102_AT88SC1604_BlownFuse
 * Description  : Memory card blown fuse. (for AT88SC102/AT88SC1604)
 * Parameter    : sAddress - Set fuse start address.()
 *                 iLength - data length.(0001~0002)
 *                   sData - data(1~2 byte)
 *
 * Return       : success - onSMP_MEM_AT88SC102_AT88SC1604_BlownFuse(boolean bStatus)
 *                   fail - onMPayBleResponse_Error
 */
- (BOOL)SMP_MEM_AT88SC102_AT88SC1604_BlownFuse:(NSString*)sAddress len:(int)iLength data:(NSString*)sData;


#pragma mark - MSR CALL
// Ready to read magnetic Card
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Card Unique Serial Number
//
- (BOOL)mPayBle_MagSwipe;


#pragma mark - ICC CALL
// Select ICC slot
//
// input
//      slot: 0:ICC 1:SAM
// output
//      status: "Success" OR "Fail"
//      response:
- (BOOL)mPayBle_IccSelect:(int)slot;

// Detect ICC Inserte or Not
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response:
- (BOOL)mPayBle_IccDetect;

// Smart Card Power On
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: answer to reset
//
- (BOOL)mPayBle_IccPowerOn;

// Smart Card Power Off
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_IccPowerOff;

// Access Smart Card
//
// input
//      sData: C-APDU
// output
//      status: "Success" OR "Fail"
//      response: R-APDU
//
- (BOOL)mPayBle_IccAccess:(NSString*)sAPDU; // sData = A0 B1 C2 D3 ... (MAX:300 Byte)


#pragma mark - PICC CALL

// Initialization RF Equipment
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Card Unique Serial Number
//
- (BOOL)mPayBle_RfActivateCard;

// Deinitialization RF Equipment
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_RfDeactivateCard;

// Rate RF Card
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Answer to Select
//
- (BOOL)mPayBle_RfRateCard;

// Access RF Card
//
// input
//      sData: C-APDU
// output
//      status: "Success" OR "Fail"
//      response: R-APDU
//
- (BOOL)mPayBle_RfAccessCard:(NSString*)sData; // sData = A0 B1 C2 D3 ... (MAX:300 Byte)

// Get Cardholder Information
//
// input
//      none
// output
//      status: "Success" OR "Fail"
//      response: Cardholder Information, include card name/number/exp.
//
- (BOOL)mPayBle_IccGetCardHolder;


#pragma mark - MIFARE CALL
// Authentication RF Card
//
// input:
//      sKeyType: 'A': key A OR 'B': key B
//      sBlock(1byte):  Mifare Card Block Number
//      sKey(6byte):    Mifare Key
// output:
//      Fail OR Success
//
- (BOOL)mPayBle_RfMifareAuthCard:(NSString*)sKeyType block:(int)iBlock key:(NSString*)sKey;


// Read RF Card
//
// input
//      sBlock(1byte): Mifare Card Block Number
// output
//      status: "Success" OR "Fail"
//      response(16byte): Block data
//
- (BOOL)mPayBle_RfMifareReadBlock:(int)iBlock; // sData = 00 ~ 3F

// Write RF Card
//
// input
//      sBlock(1byte): Mifare Card Block Number
//      sData(16byte): Mifare Card Write data
// output
//      status: "Success" OR "Fail"
//
- (BOOL)mPayBle_RfMifareWriteBlock:(int)iBlock sData:(NSString*)sData; // sData = 00 ~ 3F + 16 Byte Data

// Increment Value To RF Card
//
// input
//      sBlock(1byte): Mifare Card Block Number
//  output
//      status: "Success" OR "Fail"
//      response: Value in Card
//
- (BOOL)mPayBle_RfMifareIncrement:(int)iBlock value:(int)iValue; // sData = 4 Byte Data

// Decrement Value To RF Card
//
//  input
//      sBlock(1byte):
//      sData(4byte):
//  output
//      status: "Success" OR "Fail"
- (BOOL)mPayBle_RfMifareDecrement:(int)iBlock value:(int)iValue; // sData = 4 Byte Data


@end
