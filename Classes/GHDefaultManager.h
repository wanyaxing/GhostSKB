//
//  GHDefaultManager.h
//  GhostSKB
//
//  Created by 丁明信 on 4/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INPUT_CHANGE_EXPIRE_T 20

@interface GHDefaultManager : NSObject

+ (GHDefaultManager *)getInstance;
- (NSMutableArray *)getDefaultKeyBoards;
- (NSDictionary *)getDefaultKeyBoardsDict;
- (void)removeAppInputDefault:(NSString *)appBundleId;
- (void)recordAppLastInputSourceId:(NSString *)bundleId inputId:(NSString *)inputId;
- (NSString *)getAppLastInputSourceId:(NSString *)bundleId;
@end
