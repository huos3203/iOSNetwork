//
//  APIRequest.m
//  BabyStory
//
//  Created by YiMinwen on 13-12-16.
//  Copyright (c) 2013年 Beyondsoft. All rights reserved.
//

#import "APIRequest.h"
#import <RealReachability/RealReachability.h>

@implementation APIRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        GLobalRealReachability.hostForPing = @"www.baidu.com";
        GLobalRealReachability.hostForCheck = @"www.apple.com";
        [GLobalRealReachability startNotifier];
    }
    return self;
}


+(BOOL)isReachable
{
    BOOL isReachable = NO;
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    switch (status)
    {
        case RealStatusNotReachable:
        {
            isReachable = NO;
            break;
        }
            
        case RealStatusViaWiFi:
        {
            isReachable = YES;
            break;
        }
            
        case RealStatusViaWWAN:
        {
            isReachable = YES;
            break;
        }
            
        case RealStatusUnknown:
        {
            isReachable = NO;
            break;
        }
            
        default:
        {
            isReachable = NO;
            break;
        }
    }
    return isReachable;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
