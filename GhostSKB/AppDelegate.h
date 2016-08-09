//
//  AppDelegate.h
//  testApp
//
//  Created by 丁明信 on 4/4/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import "ChinesePinyinModifer.h"
#import "GHSettingWindowControler.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    @private
    NSStatusBarButton *_statusBarButton;
    NSMutableString *_lastAppInputSourceId;
    ChinesePinyinModifer *_cpm;
    @public
    NSStatusItem *statusItem;
    BOOL statusItemSelected;
    NSPopover* popover;
    __weak IBOutlet NSMenu *imenu;
}

@property(strong) GHSettingWindowControler *settingWinCon;
- (void)showSettingWindow;

@end

