//
//  ZYRequest.h
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/21.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYRequestMacro.h"

typedef NS_ENUM(NSInteger, ZYRequestReliability){

    //如果没有发送成功，就放入调度队列再次发送
    ZYRequestReliabilityRetry,
    
    //必须要成功的请求，如果不成功就存入DB，然后在网络好的情况下继续发送，类似微信朋友圈
    ZYRequestReliabilityStoreToDB,
    
    //普通请求，成不成功不影响业务，不需要重新发送
    //类似统计、后台拉取本地已有的配置之类的请求
    ZYRequestReliabilityNormal
};


@interface ZYRequest : NSObject<NSCoding>

//存入数据库的唯一标示
@property (nonatomic, strong) NSNumber *requestId;

/**请求参数对*/
@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, copy) NSString *urlStr;


/**
 默认重发
 */
@property (nonatomic, assign) ZYRequestReliability reliability;


/**
 默认get请求
 */
@property (nonatomic, assign) YQDRequestType method;

//没发送成功触发重发的次数
@property (nonatomic, assign, readonly) int retryCount;

//如果cacheKey为nil，就不会缓存响应的数据
@property (nonatomic, copy) NSString *cacheKey;


- (void)reduceRetryCount;
@end
