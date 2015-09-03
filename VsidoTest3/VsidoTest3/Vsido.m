//
//  Vsido.m
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/05.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>
#import "Vsido.h"
#import <ctype.h>
#import "Speech.h"

@implementation ServoAngleSetReq

-(id)initWithSid:(uint8_t)sid angle:(int16_t)angle
{
    NSAssert1(1 <= sid && sid <= 255, @"SID out of range (%d)", sid);
    NSAssert1(-1440 <= angle && angle <= 1440, @"ANGLE out of range (%d)", angle);
    
    self = [super init];
    if (self) {
        _sid = sid;
        _angle = angle;
    }
    return self;
}

@end

@implementation ComplianceSetReq

-(id)initWithSid:(uint8_t)sid cp1:(uint8_t)cp1 cp2:(uint8_t)cp2
{
    NSAssert1(1 <= sid && sid <= 255, @"SID out of range (%d)", sid);
    NSAssert1(1 <= cp1 && cp1 <= 250, @"CP1 out of range (%d)", cp1);
    NSAssert1(1 <= cp2 && cp2 <= 250, @"CP2 out of range (%d)", cp2);
    
    self = [super init];
    if (self) {
        _sid = sid;
        _cp1 = cp1;
        _cp2 = cp2;
    }
    return self;
}

@end

@implementation ServoAngleMinMaxSetReq
@end

@implementation FeedbackSetReq

-(id)initWithSid:(uint8_t)sid
{
    NSAssert1(1 <= sid && sid <= 255, @"SID out of range (%d)", sid);
    
    self = [super init];
    if (self) {
        _sid = sid;
    }
    return self;
}

@end

@implementation FeedbackGetReq

-(id)initWithDad:(uint8_t)dad dln:(int8_t)dln
{
    NSAssert1(1 <= dad && dad <= 128, @"DAD out of range (%d)", dad);
    NSAssert1(1 <= dln && dln <= 54, @"DLN out of range (%d)", dln);
    
    self = [super init];
    if (self) {
        _dad = dad;
        _dln = dln;
    }
    return self;
}

@end

@implementation ServoInfoGetReq

-(id)initWithSid:(uint8_t)sid dad:(uint8_t)dad dln:(uint8_t)dln
{
    NSAssert1(1 <= sid && sid <= 255, @"SID out of range (%d)", sid);
    //NSAssert1(1 <= dad && dad <= 128, @"DAD out of range (%d)", dad);
    NSAssert1(0 <= dad && dad <= 127, @"DAD out of range (%d)", dad);
    NSAssert1(1 <= dln && dln <= 54, @"DLN out of range (%d)", dln);
    
    self = [super init];
    if (self) {
        _sid = sid;
        _dad = dad;
        _dln = dln;
    }
    return self;
}

@end

@implementation VIDSetReq

-(id)initWithVid:(uint8_t)vid vdt_uint8:(uint8_t)vdt
{
    NSAssert1(0 <= vid && vid <= 23, @"VID out of range (%d)", vid);

    self = [super init];
    if (self) {
        _vid = vid;
        _vdt = vdt;
    }
    return self;
}

@end

@implementation VIDGetReq

-(id)initWithVid:(uint8_t)vid
{
    NSAssert1(0 <= vid && vid <= 23, @"VID out of range (%d)", vid);
    
    self = [super init];
    if (self) {
        _vid = vid;
    }
    return self;
}

@end

@implementation IOSetReq
@end

@implementation PWMSetReq
@end

@implementation IKSetReq

-(id)initWithIkf:(uint8_t)ikf kid:(uint8_t)kid kdt:(NSArray *)kdt
{
    NSAssert1(0 <= ikf && ikf <= 254, @"IKF out of range (%d)", ikf);
    NSAssert1(0 <= kid && kid <= 5, @"KID out of range (%d)", kid);
    for (int i = 0; i < kdt.count; i++) {
        uint8_t n = [kdt[i] intValue];
        NSAssert2(0 <= n && n <= 200, @"KDT[%d] out of range (%d)", i, n);
    }
    
    self = [super init];
    if (self) {
        _ikf = ikf;
        _kid = kid;
        _kdt = kdt;
    }
    return self;
}

@end

@implementation WalkSetReq

-(id)initWithWad:(uint8_t)wad wln:(uint8_t)wln wdt:(NSArray *)wdt
{
    NSAssert1(0 <= wad && wad <= 128, @"WAD out of range (%d)", wad);
    NSAssert1(2 == wln, @"WLN must be 2 (%d)", wln);
    for (int i = 0; i < wdt.count; i++) {
        uint8_t n = [wdt[i] intValue];
        NSAssert2(0 <= n && n <= 200, @"WDT[%d] out of range (%d)", i, n);
    }
    
    self = [super init];
    if (self) {
        _wad = wad;
        _wln = wln;
        _wdt = wdt;
    }
    return self;
}

@end

typedef NS_ENUM(int, ReceiveDataStatus) {
    EXPECTING_ST = 0,
    EXPECTING_OP,
    EXPECTING_LN,
    EXPECTING_BODY,
    EXPECTING_SUM,
};

@implementation Vsido
{
    IOBluetoothDevice *_bluetoothDevice;
    IOBluetoothRFCOMMChannel *_RFCOMMChannel;
    ReceiveDataStatus _receiveDataStatus;
    Byte _dataSum;
    Byte _receivedOp;
    Byte _dataLength;
    NSMutableArray *_receivedData;
}

-(BOOL)openSerialPortProfile
{
    NOTICE(@"please select bluetooth device to communicate with your robot.");
    
    IOBluetoothDeviceSelectorController	*deviceSelector;
    IOBluetoothSDPUUID					*sppServiceUUID;
    NSArray								*deviceArray;
    
    // The device selector will provide UI to the end user to find a remote device
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
    
    if ( deviceSelector == nil )
    {
        ERROR(@"unable to allocate IOBluetoothDeviceSelectorController.");
        return FALSE;
    }
    
    // Create an IOBluetoothSDPUUID object for the chat service UUID
    sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
    
    // Tell the device selector what service we are interested in.
    // It will only allow the user to select devices that have that service.
    [deviceSelector addAllowedUUID:sppServiceUUID];
    
    // Run the device selector modal.  This won't return until the user has selected a device and the device has
    // been validated to contain the specified service or the user has hit the cancel button.
    if ( [deviceSelector runModal] != kIOBluetoothUISuccess )
    {
        ERROR(@"User has cancelled the device selection.");
        return FALSE;
    }
    
    // Get the list of devices the user has selected.
    // By default, only one device is allowed to be selected.
    deviceArray = [deviceSelector getResults];
    
    if ( ( deviceArray == nil ) || ( [deviceArray count] == 0 ) )
    {
        ERROR(@"no selected device.  ***This should never happen.***");
        return FALSE;
    }
    
    // The device we want is the first in the array (even if the user somehow selected more than
    // one device in this example we care only about the first one):
    IOBluetoothDevice *device = [deviceArray objectAtIndex:0];
    
    // Finds the service record that describes the service (UUID) we are looking for:
    IOBluetoothSDPServiceRecord	*sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
    
    if ( sppServiceRecord == nil )
    {
        ERROR(@"no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***");
        return FALSE;
    }
    
    // To connect we need a device to connect and an RFCOMM channel ID to open on the device:
    UInt8	rfcommChannelID;
    if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess )
    {
        ERROR(@"no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***");
        return FALSE;
    }
    
    // Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
    IOBluetoothRFCOMMChannel *channel;
    if ( ( [device openRFCOMMChannelAsync:&channel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && ( _RFCOMMChannel != nil ) )
    {
        // Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
        // those details). If the device connection is left open close it and return an error:
        ERROR(@"open sequence failed.***");
        
        //[self closeDeviceConnectionOnDevice:device];
        
        return FALSE;
    }
    _RFCOMMChannel = channel;
    
    // So far a lot of stuff went well, so we can assume that the device is a good one and that rfcomm channel open process is going
    // well. So we keep track of the device and we (MUST) retain the RFCOMM channel:
    _bluetoothDevice = device;
    //[mBluetoothDevice  retain];
    //[mRFCOMMChannel retain];

    NOTICE(@"trying to connect.");

    return TRUE;
}

#pragma mark IOBluetoothRFCOMMChannelDelegate methods

// Called by the RFCOMM channel on us when new data is received from the channel:
-(void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
    NOTICE(@"rfcommChannelData");
    //NSLog(@"%s: なんか来た。length = %zu", __PRETTY_FUNCTION__, dataLength);
    Byte *data = (Byte *)dataPointer;
    for (int i = 0; i < dataLength; i++) {
        Byte a = data[i];
        //NSString *s = isprint(a) ? [NSString stringWithFormat:@"'%c'", a] : @"";
        //NSLog(@"%3d: 0x%02x (%3d) %@", i, a, a, s);
        
        if (_receiveDataStatus == EXPECTING_ST) {
            if (a == ST) {
                _receivedData = [NSMutableArray array];
                _dataSum = a;
                _receiveDataStatus = EXPECTING_OP;
            } else {
                NSLog(@"STじゃない。変なデータだ。");
            }
        } else if (_receiveDataStatus == EXPECTING_OP) {
            _receivedOp = a;
            _dataSum ^= a;
            _receiveDataStatus = EXPECTING_LN;
        } else if (_receiveDataStatus == EXPECTING_LN) {
            _dataLength = a - 4;
            _dataSum ^= a;
            if (0 < _dataLength) {
                _receiveDataStatus = EXPECTING_BODY;
            } else {
                _receiveDataStatus = EXPECTING_SUM;
            }
        } else if (_receiveDataStatus == EXPECTING_BODY) {
            [_receivedData addObject:@(a)];
            _dataSum ^= a;
            if (--_dataLength == 0) {
                _receiveDataStatus = EXPECTING_SUM;
            }
        } else if (_receiveDataStatus == EXPECTING_SUM) {
            if (a != _dataSum) {
                ERROR(([NSString stringWithFormat:@"expected check sum is %d, but %d actually. continue", _dataSum, a]));
            }
            NSMutableArray *sa = [NSMutableArray array];
            [sa addObject:[NSString stringWithFormat:@"受信したOpは '%c', データ数は%d", _receivedOp, (int)_receivedData.count]];
            for (int index = 0; index < _receivedData.count; index++) {
                Byte a = [_receivedData[index] integerValue];
                NSString *s = isprint(a) ? [NSString stringWithFormat:@"'%c'", a] : @"";
                //[self log:[NSString stringWithFormat:@"%3d: 0x%02x (%3d) %@", index, a, a, s]];
                [sa addObject:[NSString stringWithFormat:@"%3d: 0x%02x (%3d) %@", index, a, a, s]];
            }
            if (0 < sa.count) {
                DATA([sa componentsJoinedByString:@"\n"]);
            }
            
            [self.delegate vsidoDataReceived:_receivedOp data:_receivedData];
            
            _receiveDataStatus = EXPECTING_ST;
        } else {
            ERROR(([NSString stringWithFormat:@"weired status %d. can't continue", _receiveDataStatus]));
            abort();
        }
    }
}

// Called by the RFCOMM channel on us once the baseband and rfcomm connection is completed:
- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    NOTICE(@"rfcommChannelOpenComplete");
    [rfcommChannel setSerialParameters:115200 dataBits:8 parity:kBluetoothRFCOMMParityTypeNoParity stopBits:1];
    // If it failed to open the channel call our close routine and from there the code will
    // perform all the necessary cleanup:
    if ( error != kIOReturnSuccess )
    {
        ERROR(([NSString stringWithFormat:@"failed to open the RFCOMM channel with error %08x.", (unsigned int)error]));
        //[self rfcommChannelClosed:rfcommChannel];
        return;
    }
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NOTICE(@"rfcommChannelClosed");
}

- (void)rfcommChannelControlSignalsChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NOTICE(@"rfcommChannelControlSignalsChanged");
}

- (void)rfcommChannelFlowControlChanged:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NOTICE(@"rfcommChannelFlowControlChanged");
}

- (void)rfcommChannelWriteComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel refcon:(void*)refcon status:(IOReturn)error
{
    NOTICE(@"rfcommChannelWriteComplete");
}

- (void)rfcommChannelQueueSpaceAvailable:(IOBluetoothRFCOMMChannel*)rfcommChannel
{
    NOTICE(@"rfcommChannelQueueSpaceAvailable");
}

#pragma mark Vsido コマンド

static const Byte ST = 0xff;

static Byte sum(Byte buff[], size_t len)
{
    Byte sum = 0;
    for (int i = 0; i < len; i++) {
        sum ^= buff[i];
    }
    return sum;
}

static Byte byte1(int n)
{
    return (n << 1) & 0xff;
}

static Byte byte2(int n)
{
    return ((n << 1) >> 8) << 1;
}

-(void)sendViaBluetooth:(Byte*)data length:(size_t)length
{
    if (_RFCOMMChannel == nil) {
        ERROR(@"device not ready.");
        return;
    }

    BluetoothRFCOMMMTU mtu = _RFCOMMChannel.getMTU;
    NOTICE(([NSString stringWithFormat:@"sending %zu bytes. device MTU is %u.", length, mtu]));
    while (0 < length) {
        NSUInteger n = MIN(mtu, length);
        IOReturn result = [_RFCOMMChannel writeAsync:data length:n refcon:nil];
        NSLog(@"n = %lu result = %x (kIOReturnSuccess = %d)", n, result, kIOReturnSuccess);
        if (result != kIOReturnSuccess) {
            ERROR(@"send data failed.");
        }
        data += n;
        length -= n;
    }
}

-(void)send:(char)op data:(NSArray*)data
{
    Byte vsidocmd[1 /* ST */ + 1 /* OP */ + 1 /* LN */ + data.count + 1 /* SUM */];
    vsidocmd[0] = ST;
    vsidocmd[1] = op;
    vsidocmd[2] = sizeof(vsidocmd); // LN
    int index = 3;
    for (int i = 0; i < data.count; i++) {
        vsidocmd[index++] = [data[i] integerValue];
    }
    vsidocmd[index] = sum(vsidocmd, sizeof(vsidocmd) - 1);
    [self sendViaBluetooth:vsidocmd length:sizeof(vsidocmd)];
}

-(void)send:(char)op
{
    [self send:op data:@[]];
}

#pragma mark 目標角度設定
-(void)vsido_o:(int)cyc servoAngles:(NSArray*)servoAngleSetReq
{
    NSMutableArray *data = [NSMutableArray array];
    NSAssert1(1 <= cyc && cyc <= 100, @"CYC out of range (%d)", cyc);
    [data addObject:@(cyc)];
    for (int i = 0; i < servoAngleSetReq.count; i++) {
        ServoAngleSetReq *s = servoAngleSetReq[i];
        [data addObject:@(s.sid)];
        [data addObject:@(byte1(s.angle))];
        [data addObject:@(byte2(s.angle))];
    }
    [self send:'o' data:data];
}

#pragma mark コンプライアンス設定
-(void)vsido_c:(NSArray*)complianceSetReq
{
    NSLog(@"%s: not implemented yet", __PRETTY_FUNCTION__);
    abort();
}

#pragma mark 最大・最小角設定
-(void)vsido_m:(NSArray *)servoAngleMinMaxSetReq
{
    NSLog(@"%s: not implemented yet", __PRETTY_FUNCTION__);
    abort();
}

#pragma mark フィードバックID設定
// MARK:良くわかっていない
-(void)vsido_f:(NSArray *)feedbackSetReq
{
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < feedbackSetReq.count; i++) {
        FeedbackSetReq *req = feedbackSetReq[i];
        [data addObject:@(req.sid)];
    }
    [self send:'f' data:data];
}

#pragma mark フィードバック要求
// MARK:良くわかっていない
-(void)vsido_r:(FeedbackGetReq*)feedbackGetReq
{
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:@(feedbackGetReq.dad)];
    [data addObject:@(feedbackGetReq.dln)];
    [self send:'r' data:data];
}

#pragma mark サーボ情報要求
// MARK:良くわかっていない
-(void)vsido_d:(NSArray *)servoInfoGetReq
{
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < servoInfoGetReq.count; i++) {
        ServoInfoGetReq *req = servoInfoGetReq[i];
        [data addObject:@(req.sid)];
        [data addObject:@(req.dad)];
        [data addObject:@(req.dln)];
    }
    [self send:'d' data:data];
}

#pragma mark 各種変数(VID)設定
-(void)vsido_s:(NSArray*)vidSetReq
{
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < vidSetReq.count; i++) {
        VIDSetReq *req = vidSetReq[i];
        [data addObject:@(req.vid)];
        [data addObject:@(req.vdt)];
    }
    [self send:'s' data:data];
}

#pragma mark 各種変数(VID)要求
-(void)vsido_g:(NSArray *)vidGetReq
{
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < vidGetReq.count; i++) {
        VIDSetReq *req = vidGetReq[i];
        [data addObject:@(req.vid)];
    }
    [self send:'g' data:data];
}

#pragma mark フラッシュ書込要求
-(void)vsido_w
{
    NSLog(@"%s: not implemented yet", __PRETTY_FUNCTION__);
    abort();
}

#pragma mark IO設定
-(void)vsido_i:(NSArray *)ioSetReq
{
    NSLog(@"%s: not implemented yet", __PRETTY_FUNCTION__);
    abort();
}

#pragma mark PWM設定
-(void)vsido_p:(NSArray *)pwmSetReq
{
    NSLog(@"%s: not implemented yet", __PRETTY_FUNCTION__);
    abort();
}

#pragma mark 接続確認要求
-(void)vsido_j
{
    [self send:'j'];
}

#pragma mark IK設定
-(void)vsido_k:(NSArray *)ikSetReq
{
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < ikSetReq.count; i++) {
        IKSetReq *req = ikSetReq[i];
        [data addObject:@(req.ikf)];
        [data addObject:@(req.kid)];
        for (int j = 0; j < req.kdt.count; j++) {
            [data addObject:req.kdt[j]];
        }
    }
    [self send:'k' data:data];
}

#pragma mark 移動情報指定
-(void)vsido_t:(NSArray *)walkSetReq
{
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < walkSetReq.count; i++) {
        WalkSetReq *req = walkSetReq[i];
        [data addObject:@(req.wad)];
        [data addObject:@(req.wln)];
        [data addObject:req.wdt[0]];
        [data addObject:req.wdt[1]];
    }
    [self send:'t' data:data];
}

#pragma mark 加速度センサ値要求
// MARK:RCでは実装されていない
-(void)vsido_a
{
    [self send:'a'];
}

#pragma mark 電源電圧値
// MARK:RCでは動作しない
-(void)vsido_v
{
    [self send:'v'];
}

#pragma mark サーボ情報構造体へ変換

static void convert(int16_t *p)
{
    int16_t n = *p;
    uint16_t a = ((n & 0x0ff00) >> 1) & 0x0ff00;
    uint16_t b = n & 0x00ff;
    *p = (a | b) >> 1;
}

#define CONVERT(m) do { \
    NSAssert(sizeof(m) == 2, @"member must 16 bits"); \
    convert(&(m)); \
} while(false)

-(void)convertToServoInfo:(NSArray *)data servoInfoOut:(ServoInfo *)result
{
    Byte rawData[data.count];
    for (int i = 0; i < data.count; i++) {
        rawData[i] = (Byte)[data[i] unsignedIntegerValue];
    }
    // TODO: 16bit値については、以下を行う。
    // 手順1)数値を2進数に変換する
    // 手順2)上位バイトを右へ1bitシフト
    // 手順3)全体を右1bitシフト
    *result = *((ServoInfo*)rawData);
    CONVERT(result->rom_model_num);
    CONVERT(result->rom_cw_agl_lmt);
    CONVERT(result->rom_ccw_agl_lmt);
    CONVERT(result->ram_goal_pos);
    CONVERT(result->ram_goal_tim);
    CONVERT(result->ram_pres_pos);
    CONVERT(result->ram_pres_time);
    CONVERT(result->ram_pres_spd);
    CONVERT(result->ram_pres_curr);
    CONVERT(result->ram_pres_temp);
    CONVERT(result->ram_pres_volt);
    CONVERT(result->agl_ofset);
    CONVERT(result->read_time);
    CONVERT(result->_ram_goal_pos);
    CONVERT(result->__ram_goal_pos);
    CONVERT(result->_ram_pres_pos);
}

@end
