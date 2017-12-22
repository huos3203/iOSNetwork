//
//  ZYRequestManager.m
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/21.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ZYRequestManager.h"
#import "ZYRequest.h"
#import "YQDHttpClinetCore.h"

@interface ZYRequestManager()
@property (nonatomic, strong) NSMutableArray *requestQueue;
//存放request的成功回调
@property (nonatomic, strong) NSMutableArray *successQueue;
//存放request的失败回调
@property (nonatomic, strong) NSMutableArray *failureQueue;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@end

static id _instance = nil;

//最大并发数
static const int _maxCurrentNum = 4;

@implementation ZYRequestManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!_instance)
        {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.semaphore = dispatch_semaphore_create(_maxCurrentNum);
    }
    return self;
}


- (void)sendRequest:(ZYRequest *)request successBlock:(SuccessBlock)successBlock failureBlock:(FailedBlock)failedBlock
{
    [self.requestQueue addObject:request];
    [self.successQueue addObject:[successBlock copy]];
    [self.failureQueue addObject:[failedBlock copy]];
    
    [self dealRequestQueue];
}

- (void)dealRequestQueue
{
    ZYRequest *request = self.requestQueue.firstObject;
    SuccessBlock successBlock = self.successQueue.firstObject;
    FailedBlock failedBlock = self.failureQueue.firstObject;
    
    if (request != nil)
    {
        dispatch_async(self.serialQueue, ^{
            
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            
            //利用AFN发送请求
            
            
            [self queueRemoveFirstObj];
        });
    }
}

- (void)queueRemoveFirstObj
{
    if (self.requestQueue.count >= 1)
    {
        [self.requestQueue removeObjectAtIndex:0];
        [self.successQueue removeObjectAtIndex:0];
        [self.failureQueue removeObjectAtIndex:0];
    }
    
    if (self.requestQueue.count != 0)
    {
        [self dealRequestQueue];
    }
}

#pragma mark - getter && setter
- (NSMutableArray *)requestQueue
{
    if (!_requestQueue)
    {
        _requestQueue = [NSMutableArray array];
    }
    return _requestQueue;
}

- (NSMutableArray *)successQueue
{
    if (!_successQueue)
    {
        _successQueue = [NSMutableArray array];
    }
    return _successQueue;
}

- (NSMutableArray *)failureQueue
{
    if (!_failureQueue)
    {
        _failureQueue = [NSMutableArray array];
    }
    return _failureQueue;
}

- (dispatch_queue_t)serialQueue
{
    if (!_serialQueue)
    {
        _serialQueue = dispatch_queue_create("com.xxxx.www", DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}
@end
