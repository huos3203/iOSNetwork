//
//  ZYRequestCache.h
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/25.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYRequestCache : NSObject
+ (instancetype)sharedInstance;

- (NSData *)readDataForKey:(NSString *)key;

- (void)saveData:(NSData *)data ForKey:(NSString *)key;

@end
