//
//  Speech.m
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/09.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//
#import "Speech.h"

void speech(const char *__file__, int __line__, NSString *klass, NSString *message)
{
    NSArray *voices = [NSSpeechSynthesizer availableVoices];
    NSMutableArray *candidateVoices = [NSMutableArray array];
    for (NSString *vo in voices) {
        NSDictionary *voAttr = [NSSpeechSynthesizer attributesForVoice:vo];
        NSString *voiceLanguage = voAttr[NSVoiceLocaleIdentifier];
        NSString *voiceGender = voAttr[NSVoiceGender];
        if ([klass isEqualToString:@"data"]) {
            if ([@"ja_JP" isEqualToString:voiceLanguage] && [voiceGender isEqualToString:NSVoiceGenderFemale]) {
                [candidateVoices addObject:vo];
            }
        } else {
            if ([@"en_US" isEqualToString:voiceLanguage] && [voiceGender isEqualToString:NSVoiceGenderFemale]) {
                [candidateVoices addObject:vo];
            }
        }
    }
    NSString *voice = candidateVoices[arc4random() % candidateVoices.count];
    NSSpeechSynthesizer *ss = [[NSSpeechSynthesizer alloc] initWithVoice:voice];

    NSLog(@"%s(%d): [%@] %@ (%@)", __file__, __line__, klass, message, voice);

    int __block nw = 0;
    [message enumerateSubstringsInRange:NSMakeRange(0, message.length)
                                options:NSStringEnumerationByWords
                             usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 //NSLog(@"Substring: '%@'", substring);
                                 nw++;
                             }];
    if (7 < nw) {
        ss.rate = MIN(220*nw/7.0, 250);
    } else {
        ss.rate = 220;
    }
    NSLog(@"nw = %d ss.rate = %g", nw, ss.rate);
    [ss startSpeakingString:[NSString stringWithFormat:@"%@: %@", klass, message]];
}
