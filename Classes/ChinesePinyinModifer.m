//
//  ChinesePinyinModifer.m
//  GhostSKB
//
//  Created by 丁明信 on 7/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import "ChinesePinyinModifer.h"



@implementation ChinesePinyinModifer
@synthesize currentBaseInputSource;

-(id)init
{
    if (self = [super init]) {
        //do something;
    }
    return self;
}

- (void)startListenShiftKey
{
//    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent * event) {
//        NSUInteger flag = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
//        BOOL shiftIsDown = !!(flag & NSShiftKeyMask);
//        if (shiftIsDown) {
//            _shift_down_t = (time_t)[[NSDate date] timeIntervalSince1970];
//        }
//        else {
//            time_t now = (time_t)[[NSDate date] timeIntervalSince1970];
//            if(now - _shift_down_t < 1) {
//                [self changePinyinStatus];
//            }
//        }
//    }];
}

- (NSString *)getCurrentBaseInputSourceId
{
    if (self.currentBaseInputSource) {
        NSString *currentInputId = (__bridge NSString *)(TISGetInputSourceProperty(self.currentBaseInputSource, kTISPropertyInputSourceID));
        return currentInputId;
    }
    else {
        return NULL;
    }
}

- (void)selectAsciiCapableInputSource
{
    NSMutableString *thisID;
    TISInputSourceRef inputSource = NULL;
    TISInputSourceRef asciiInputSource = NULL;
    CFArrayRef availableInputs = TISCreateInputSourceList(NULL, false);
    NSUInteger count = CFArrayGetCount(availableInputs);
    for (int i=0; i<count; i++) {
        inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(availableInputs, i);
        CFStringRef type = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceCategory);
        if (!CFStringCompare(type, kTISCategoryKeyboardInputSource, 0)) {
            thisID = (__bridge NSMutableString *)(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID));
            NSString *asciiEnable =(__bridge NSString *)(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsASCIICapable));
            
            if ([asciiEnable boolValue] && ![thisID isEqualToString:CHINESE_PINYIN_INPUT_SOURCE_ID]) {
                asciiInputSource = inputSource;
            }
        }
        
    }
    if (asciiInputSource == NULL) {
        return;
    }
    else {
        TISSelectInputSource(asciiInputSource);
    }
}

- (void)changePinyinStatus {
    
    TISInputSourceRef currentSelectInputSource = TISCopyCurrentKeyboardInputSource();
    NSString *currentInputId = (__bridge NSString *)(TISGetInputSourceProperty(currentSelectInputSource, kTISPropertyInputSourceID));
    
    if (![[self getCurrentBaseInputSourceId] isEqualToString:CHINESE_PINYIN_INPUT_SOURCE_ID]) {
        return;
    }
    
    if ([currentInputId isEqualToString:CHINESE_PINYIN_INPUT_SOURCE_ID]) {
        [self selectAsciiCapableInputSource];
    }
    else {
        TISSelectInputSource(self.currentBaseInputSource);
    }

    
}
@end
