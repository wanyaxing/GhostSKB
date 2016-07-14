//
//  ChinesePinyinModifer.h
//  GhostSKB
//
//  Created by 丁明信 on 7/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>
#import "Constant.h"

@interface ChinesePinyinModifer : NSObject {
    @private
    time_t _shift_down_t;
}

@property(assign) TISInputSourceRef currentBaseInputSource;

- (void)changePinyinStatus;
- (void)startListenShiftKey;

@end
