//
//  ZYRequestCache.m
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/25.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ZYRequestCache.h"
#import "YQDStorageUtils.h"

@interface ZYRequestCache()

@end

static id _instance = nil;

@implementation ZYRequestCache
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil)
        {
            _instance = [[self alloc] init];
        }
    });
    
    return _instance;
}

- (NSData *)readDataForKey:(NSString *)key
{
    return [YQDStorageUtils readDataFromFileByUrl:key];
}

- (void)saveData:(NSData *)data ForKey:(NSString *)key
{
    [YQDStorageUtils saveUrl:key withData:data];
}

@end
