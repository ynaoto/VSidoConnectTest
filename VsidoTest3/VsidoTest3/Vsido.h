//
//  Vsido.h
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/05.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>

@interface ServoAngleSetReq : NSObject

@property (readonly) uint8_t sid;
@property (readonly) int16_t angle;

-(id)initWithSid:(uint8_t)sid angle:(int16_t)angle;

@end

@interface ComplianceSetReq : NSObject

@property (readonly) uint8_t sid;
@property (readonly) uint8_t cp1; // 時計回りのコンプライアンススロープ値
@property (readonly) uint8_t cp2; // 反時計回りのコンプライアンススロープ値

-(id)initWithSid:(uint8_t)sid cp1:(uint8_t)cp1 cp2:(uint8_t)cp2;

@end

@interface ServoAngleMinMaxSetReq : NSObject

@property (readonly) uint8_t sid;
@property (readonly) int16_t min;
@property (readonly) int16_t max;

-(id)initWithSid:(uint8_t)sid min:(int16_t)min max:(int16_t)max;

@end

@interface FeedbackSetReq : NSObject

@property (readonly) uint8_t sid;

-(id)initWithSid:(uint8_t)sid;

@end

@interface FeedbackGetReq : NSObject

@property (readonly) uint8_t dad;
@property (readonly) uint8_t dln;

-(id)initWithDad:(uint8_t)dad dln:(int8_t)dln;

@end

@interface ServoInfoGetReq : NSObject

@property (readonly) uint8_t sid;
@property (readonly) uint8_t dad;
@property (readonly) uint8_t dln;

-(id)initWithSid:(uint8_t)sid dad:(uint8_t)dad dln:(uint8_t)dln;

@end

@interface VIDSetReq : NSObject

@property (readonly) uint8_t vid;
@property (readonly) uint8_t vdt;

-(id)initWithVid:(uint8_t)vid vdt_uint8:(uint8_t)vdt;

@end

@interface IOSetReq : NSObject

@property (readonly) uint8_t iid;
@property (readonly) uint8_t val;

-(id)initWithIid:(uint8_t)iid val:(uint8_t)val;

@end

@interface PWMSetReq : NSObject

@property (readonly) uint8_t iid;
@property (readonly) uint16_t pul;

-(id)initWithIid:(uint8_t)iid pul:(uint16_t)pul;

@end

@interface IKSetReq : NSObject

@property (readonly) uint8_t ikf;
@property (readonly) uint8_t kid; // ???
@property (readonly) NSArray *kdt;

-(id)initWithIkf:(uint8_t)ikf kid:(uint8_t)kid kdt:(NSArray*)kdt;

@end

@interface WalkSetReq : NSObject

@property (readonly) uint8_t wad;
@property (readonly) uint8_t wln;
@property (readonly) NSArray *wdt;

-(id)initWithWad:(uint8_t)wad wln:(uint8_t)wln wdt:(NSArray*)wdt;

@end

typedef struct __attribute__((packed)) {
    uint8_t    VID_RS485_Baudrate;
    uint8_t    VID_TTL_Baudrate;
    uint8_t    VID_RS232_Baudrate; // dup???
    uint8_t    VID_IO_PA_IO_Mode;
    uint8_t    VID_IO_PA_Analog_Mode;
    uint8_t    VID_IO_PA_PWM;
    uint16_t   VID_IO_PA_PWM_CYCLE;
    uint8_t    VID_Through_Port;
    uint8_t    VID_Servo_Type_RS485;
    uint8_t    VID_Servo_Type_TTL;
    uint8_t    VID_IMU_Type;
    uint8_t    VID_Barancer_Flag;
    //uint8_t    VID_RS232_Baudrate; // dup???
    uint8_t    VID_Theta_Th;
    uint8_t    VID_Cycletime;
    uint8_t    VID_Min_Cmp;
    uint8_t    VID_Flag_Ack;
    uint8_t    VID_Volt_Th;
    uint8_t    VID_Initialize_Torque;
    uint8_t    VID_Initialize_Angle;
    uint8_t    VID_Inspection_Flag;
    uint8_t    VID_Inspection_Type;
} RCVid;

typedef struct __attribute__((packed)) {
    int16_t    rom_model_num;
    uint8_t    rom_servo_ID;
    int16_t    rom_cw_agl_lmt;
    int16_t    rom_ccw_agl_lmt;
    uint8_t    rom_damper;
    uint8_t    rom_cw_cmp_margin;
    uint8_t    rom_ccw_cmp_margin;
    uint8_t    rom_cw_cmp_slope;
    uint8_t    rom_ccw_cmp_slope;
    uint8_t    rom_punch;
    int16_t    ram_goal_pos;
    int16_t    ram_goal_tim;
    uint8_t    ram_max_torque;
    uint8_t    ram_torque_mode;
    int16_t    ram_pres_pos;
    int16_t    ram_pres_time;
    int16_t    ram_pres_spd;
    int16_t    ram_pres_curr;
    int16_t    ram_pres_temp;
    int16_t    ram_pres_volt;
    uint8_t    flags;
    int16_t    agl_ofset;
    uint8_t    parents_ID;
    uint8_t    connected;
    int16_t    read_time;
    int16_t    _ram_goal_pos;
    int16_t    __ram_goal_pos;
    int16_t    _ram_pres_pos;
    int8_t     _send_speed;
    uint8_t    _send_cmd_time;
    uint8_t    flg_min_max;
    uint8_t    flg_goal_pos;
    uint8_t    flg_parent_inv;
    uint8_t    flg_cmp_slope;
    uint8_t    flg_check_angle;
    int8_t     port_type;
    int8_t     servo_type;
} ServoInfo;

@protocol VsidoDelegate

-(void)vsidoDataReceived:(Byte)op data:(NSArray*)data;

@end

@interface Vsido : NSObject

@property id<VsidoDelegate> delegate;

-(BOOL)openSerialPortProfile;

-(void)vsido_o:(int)cyc servoAngles:(NSArray*)servoAngleSetReq; // 目標角度設定
-(void)vsido_c:(NSArray*)complianceSetReq; // コンプライアンス設定
-(void)vsido_m:(NSArray*)servoAngleMinMaxSetReq; // 最大・最小角設定
-(void)vsido_f:(NSArray*)feedbackSetReq; // フィードバックID設定
-(void)vsido_r:(FeedbackGetReq*)feedbackGetReq; // フィードバック要求
-(void)vsido_d:(NSArray*)servoInfoGetReq; // サーボ情報要求
-(void)vsido_s:(NSArray*)vidSetReq; // 各種変数(VID)設定
-(void)vsido_g:(NSArray*)vids; // 各種変数(VID)要求
-(void)vsido_w; // フラッシュ書込要求
-(void)vsido_i:(NSArray*)ioSetReq; // IO設定
-(void)vsido_p:(NSArray*)pwmSetReq; // PWM設定
-(void)vsido_j; // 接続確認要求
-(void)vsido_k:(NSArray*)ikSetReq; // IK設定
-(void)vsido_t:(NSArray*)walkSetReq; // 移動情報指定
-(void)vsido_a; // 加速度センサ値要求
-(void)vsido_v; // 電源電圧値

-(void)convertToServoInfo:(NSArray*)data servoInfoOut:(ServoInfo*)result;

@end
