//
//  AppDelegate.m
//  testApp
//
//  Created by 丁明信 on 4/4/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import "AppDelegate.h"
#import "PopoverViewController.h"
#import "GHDefaultManager.h"
#import "Constant.h"

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>
@interface AppDelegate ()


@end

@implementation AppDelegate
#pragma mark - App Life Cycle

BOOL checkAccessibility()
{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    checkAccessibility();
    _cpm = [[ChinesePinyinModifer alloc] init];

    [_cpm startListenShiftKey];

    
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc addObserver:self selector:@selector(handleAppActivateNoti:) name:NSWorkspaceDidActivateApplicationNotification object:NULL];
    [nc addObserver:self selector:@selector(handleAppDeactiveNoti:) name:NSWorkspaceDidDeactivateApplicationNotification object:NULL];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGHAppSelectedNoti:) name:@"GH_APP_SELECTED" object:NULL];
    [GHDefaultManager getInstance];
    
    [self initStatusItem];
    [self initPopover];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)awakeFromNib {
    [imenu setDelegate:self];
}

- (void)initPopover {
    popover = [[NSPopover alloc] init];
    popover.behavior = NSPopoverBehaviorTransient;
    popover.contentViewController = [[PopoverViewController alloc] init];
}

- (void)initStatusItem {
    statusItemSelected = false;
    NSString *imageName = @"ghost_dark_small";
    NSString *alternateImageName = @"ghost_color_19";
    NSImage *normalImage = [NSImage imageNamed:imageName];
    [normalImage setTemplate:YES];
    NSImage *alternateImage = [NSImage imageNamed:alternateImageName];
    [alternateImage setTemplate:YES];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
    statusItem.image = normalImage;
    statusItem.alternateImage = alternateImage;
    
    [statusItem.button setAction:@selector(onStatusItemSelected:)];
}

- (void) onStatusItemSelected:(id) sender {
    statusItemSelected = !statusItemSelected;
    [self showPopover:sender];
}

- (void)showPopover:(id)sender {
    NSStatusBarButton* button = statusItem.button;
    _statusBarButton = button;
    if (popover.isShown) {
        [popover performClose:button];
    }
    else {
        //get forcus
        [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
        //show popover
        [popover showRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMaxY];
    }
}

- (NSMutableString *)getCurrentInputSourceId
{
    TISInputSourceRef inputSource = TISCopyCurrentKeyboardInputSource();
    NSMutableString *inputId = (__bridge NSMutableString *)(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID));
    return inputId;
}

- (void)changeInputSource:(NSString *)inputId
{
    NSMutableString *thisID;
    TISInputSourceRef inputSource = NULL;
    
    CFArrayRef availableInputs = TISCreateInputSourceList(NULL, false);
    NSUInteger count = CFArrayGetCount(availableInputs);

    for (int i = 0; i < count; i++) {
        inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(availableInputs, i);
        CFStringRef type = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceCategory);
        if (!CFStringCompare(type, kTISCategoryKeyboardInputSource, 0)) {
            thisID = (__bridge NSMutableString *)(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID));
            if ([thisID isEqualToString:inputId]) {
                OSStatus err = TISSelectInputSource(inputSource);
                if (err) {
                    printf("Error %i\n", (int)err);
                }
                else {
//                    [self changeStatusItemImage:[inputId isEqualToString:CHINESE_PINYIN_INPUT_SOURCE_ID]];
                    _cpm.currentBaseInputSource = inputSource;
                }
                break;
            }
            
        }
    }
}

- (void) handleAppDeactiveNoti:(NSNotification *)noti {
    NSRunningApplication *runningApp = (NSRunningApplication *)[noti.userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString *identifier = runningApp.bundleIdentifier;
    [[GHDefaultManager getInstance] recordAppLastInputSourceId:identifier inputId:_lastAppInputSourceId];
}

- (void) handleAppActivateNoti:(NSNotification *)noti {
    
    _lastAppInputSourceId = [self getCurrentInputSourceId];
    NSRunningApplication *runningApp = (NSRunningApplication *)[noti.userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString *bundleIdentifier = runningApp.bundleIdentifier;
    
    NSString *lastUsedInputId = [[GHDefaultManager getInstance] getAppLastInputSourceId:bundleIdentifier];
    NSString *targetInputId = NULL;
    if (lastUsedInputId != NULL) {
        targetInputId = lastUsedInputId;
    }
    else {
        NSDictionary *defaultInput = [[GHDefaultManager getInstance] getDefaultKeyBoardsDict];
        NSDictionary *info = [defaultInput objectForKey:bundleIdentifier];
        targetInputId = [[info objectForKey:@"defaultInput"] description];
    }

    if (targetInputId != NULL) {
        [self changeInputSource:targetInputId];
    }
}

- (void) changeStatusItemImage:(BOOL)isLight {
    if (isLight) {
        statusItem.image = [NSImage imageNamed:@"ghost_white_small"];
    }
    else {
        statusItem.image =[NSImage imageNamed:@"ghost_dark_small"];
    }
}
- (void) handleGHAppSelectedNoti:(NSNotification *)noti {
    //get forcus
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    //show popover
    [popover showRelativeToRect:_statusBarButton.bounds ofView:_statusBarButton preferredEdge:NSRectEdgeMaxY];
}



@end
