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

//用串行队列来控制任务有序
@property (nonatomic, strong) dispatch_queue_t serialQueue;

//requestQueue队列是否正在轮询
@property (nonatomic, assign) BOOL isRetaining;
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
        self.isRetaining = false;
    }
    return self;
}


- (void)sendRequest:(ZYRequest *)request successBlock:(SuccessBlock)successBlock failureBlock:(FailedBlock)failedBlock
{
    
    [self queueAddRequest:request successBlock:successBlock failureBlock:failedBlock];
    [self dealRequestQueue];
}

- (void)dealRequestQueue
{
    if (self.isRetaining) return;
    self.isRetaining = true;
    
    //在子线程轮询，以免阻塞主线程
    //让请求按队列先后顺序发送
    dispatch_async(self.serialQueue, ^{
        
        while (self.requestQueue.count > 0)
        {
            ZYRequest *request = self.requestQueue.firstObject;
            SuccessBlock successBlock = self.successQueue.firstObject;
            FailedBlock failedBlock = self.failureQueue.firstObject;
            
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            
            //利用AFN发送请求
            [[YQDHttpClinetCore sharedClient] requestWithPath:request.urlStr method:request.method parameters:request.params prepareExecute:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                dispatch_semaphore_signal(self.semaphore);
                
                //在这里可以根据状态码处理相应信息、序列化数据、是否需要缓存等
                successBlock(responseObject);
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                dispatch_semaphore_signal(self.semaphore);
                
                //请求失败之后，首先判断是否需要再次请求
                if (request.retryCount > 0)
                {
                    [request reduceRetryCount];
                    [self queueAddRequest:request successBlock:successBlock failureBlock:failedBlock];
                    [self dealRequestQueue];
                }
                else  //处理错误信息
                {
                    failedBlock(error);
                }
                
                
            }];
            
            [self queueRemoveFirstObj];
        }
        
        if (self.requestQueue.count == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isRetaining = false;
            });
        }
    });
    
}

- (void)queueAddRequest:(ZYRequest *)request successBlock:successBlock failureBlock:failedBlock
{
    dispatch_async(self.serialQueue, ^{
        if (request == nil)
        {
            NSLog(@"ZYRequest 不能为nil");
            return;
        }
        
        [self.requestQueue addObject:request];
        //做容错处理，如果block为空，设置默认block
        id tmpBlock = [successBlock copy];
        if (successBlock == nil)
        {
            tmpBlock = [^(id obj){} copy];
        }
        [self.successQueue addObject:tmpBlock];
        
        
        tmpBlock = [failedBlock copy];
        if (failedBlock == nil)
        {
            tmpBlock = [^(id obj){} copy];
        }
        [self.failureQueue addObject:tmpBlock];
    });
    
}

- (void)queueRemoveFirstObj
{
    dispatch_async(self.serialQueue, ^{
        
        if (self.requestQueue.count >= 1)
        {
            [self.requestQueue removeObjectAtIndex:0];
            [self.successQueue removeObjectAtIndex:0];
            [self.failureQueue removeObjectAtIndex:0];
        }
    });
    
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
