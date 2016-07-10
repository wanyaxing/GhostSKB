//
//  ChinesePinyinModifer.h
//  GhostSKB
//
//  Created by 丁明信 on 7/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface ChinesePinyinModifer : NSObject

@property(assign) TISInputSourceRef currentBaseInputSource;
- (void)changePinyinStatus;

@end
