//
//  GHDefaultManager.m
//  GhostSKB
//
//  Created by 丁明信 on 4/10/16.
//  Copyright © 2016 丁明信. All rights reserved.
//

#import "GHDefaultManager.h"
#import "GHDefaultInfo.h"
static GHDefaultManager *sharedGHDefaultManager = nil;

@implementation GHDefaultManager

-(id)init
{
    if (self = [super init]) {
        //do something;
    }
    return self;
}

+ (GHDefaultManager *)getInstance
{
    static dispatch_once_t onceToken;
    //保证线程安全
    dispatch_once(&onceToken, ^{
        sharedGHDefaultManager = [[self alloc] init];
    });
    
    //这是不采用GCD的单例初始化方法
//    @synchronized(self)
//    {
//        if (sharedGHDefaultManager == nil)
//        {
//            sharedGHDefaultManager = [[self alloc] init];
//        }
//    }
    return sharedGHDefaultManager;
}

- (NSMutableArray *)getDefaultKeyBoards {

    NSDictionary *keyBoardDefault = [self getDefaultKeyBoardsDict];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [keyBoardDefault enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        GHDefaultInfo *info = [[GHDefaultInfo alloc] initWithAppBundle:[object objectForKey:@"appBundleId"]
                                                                appUrl:[[object objectForKey:@"appUrl"] description]
                                                                input:[object objectForKey:@"defaultInput"]];
        [arr addObject:info];
    }];
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull a, id  _Nonnull b) {
        GHDefaultInfo *aInfo = (GHDefaultInfo *)a;
        GHDefaultInfo *bInfo = (GHDefaultInfo *)b;
        return [aInfo.appBundleId compare:bInfo.appBundleId];
    }];
    return arr;
}

-(NSDictionary *)getDefaultKeyBoardsDict {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"gh_default_keyboards"];
    if (data == NULL) {
        return [[NSDictionary alloc] init];
    }
    NSDictionary *retrievedDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSDictionary *keyBoardDefault = [[NSDictionary alloc] initWithDictionary:retrievedDictionary];
    return keyBoardDefault;
}

-(void)removeAppInputDefault:(NSString *)appBundleId {
    NSDictionary *defaultInputs = [self getDefaultKeyBoardsDict];
    if ([defaultInputs objectForKey:appBundleId] != NULL) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:defaultInputs];
        [dict removeObjectForKey:appBundleId];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSKeyedArchiver archivedDataWithRootObject:(NSDictionary *)dict] forKey:@"gh_default_keyboards"];
        [prefs synchronize];
    }
}

- (void)recordAppLastInputSourceId:(NSString *)bundleId inputId:(NSString *)inputId
{
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    time_t timestamp = (time_t)[[NSDate date] timeIntervalSince1970];
    [nc setInteger:(long)timestamp forKey:[NSString stringWithFormat:@"%@_last_deacitve_time", bundleId]];
    [nc setObject:inputId forKey:[NSString stringWithFormat:@"%@_last_input_id", bundleId]];
    [nc synchronize];
}

- (NSString *)getAppLastInputSourceId:(NSString *)bundleId
{
    NSUserDefaults *nc = [NSUserDefaults standardUserDefaults];
    NSInteger appLastDeactiveTime = [nc integerForKey:[NSString stringWithFormat:@"%@_last_deacitve_time", bundleId]];
    time_t timestamp = (time_t)[[NSDate date] timeIntervalSince1970];
    if (timestamp - appLastDeactiveTime > INPUT_CHANGE_EXPIRE_T) {
        return NULL;
    }
    NSString *lastInputId = [nc stringForKey:[NSString stringWithFormat:@"%@_last_input_id", bundleId]];
    return lastInputId;
}

@end
