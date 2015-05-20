//
//  Speech.h
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/09.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//
#import <Cocoa/Cocoa.h>

#ifndef VsidoTest3_Speech_h
#define VsidoTest3_Speech_h

extern void speech(const char *__file__, int __line__, NSString *klass, NSString *message);
#define NOTICE(message) speech(__FILE__, __LINE__, @"notice", message)
#define ERROR(message) speech(__FILE__, __LINE__, @"error", message)
#define DATA(message) speech(__FILE__, __LINE__, @"data", message)

#endif
