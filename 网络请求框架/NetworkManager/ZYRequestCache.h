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

/**
 从沙盒里面读取数据
 */
- (NSData *)readDataForKey:(NSString *)key;

/**
 将data存入沙盒路径
 */
- (void)saveData:(NSData *)data ForKey:(NSString *)key;

@end
