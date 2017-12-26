//
//  ZYRequestRealm.m
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/26.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ZYRequestRealm.h"
#import "ZYRequest.h"


@interface ZYRequestRealm()

@end

static id _instance = nil;

@implementation ZYRequestRealm
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
        [self createDataBaseWithName:@"requestReaml"];
    }
    return self;
}


/**
 如果该路径下的realm存在，则直接进行Configuration
 不存在，先创建再Configuration
 此方法也可以进行切换realm数据库的切换，只需要传入不同的databaseName即可
 */
- (void)createDataBaseWithName:(NSString *)databaseName
{
    //设置realm的路径
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [docPath objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:databaseName];
    NSLog(@"数据库目录 = %@",filePath);
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [NSURL URLWithString:filePath];
    config.readOnly = NO;
    
    // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果之前从未设置过架构版本，那么这个版本号设置为 0）
    int currentVersion = 0;
    config.schemaVersion = currentVersion;
    
    config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {
        // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
        }
    };
    
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

#pragma mark -- 增删改查等操作

//添加or更新对象
- (void)addOrUpdateObj:(RLMObject *)obj
{
    
    [self transactionOperation:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObject:obj];
        }];
    }];
    
}
- (void)addorUpdateObjArray:(NSArray<RLMObject *> *)objArr;
{
    [self transactionOperation:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObjects:objArr];
        }];
    }];
}

//删除对象
- (void)deleteObj:(RLMObject *)obj
{
    
    [self transactionOperation:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm deleteObject:obj];
        }];
    }];
}
- (void)deleteObjArray:(NSArray<RLMObject *> *)objArr
{
    [self transactionOperation:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm deleteObjects:objArr];
        }];
    }];
}
//删除RLMResults对象
- (void)deleteResultsObj:(RLMResults *)results
{
    [self transactionOperation:^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSError *error = nil;
        [realm transactionWithBlock:^{
            [realm deleteObjects:results];
        } error:&error];
        
        if (error)
        {
            NSLog(@"realm错误信息： %@", error);
        }
        
    }];
}

- (void)transactionOperation:(void(^)(void))operationBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        operationBlock();
    });
}

- (NSArray<RLMObject *> *)queryAllObjsForClass:(Class)class;
{
    //使用SEL来调用方法，首先做容错处理
    //如果class不是RLMObject的子类，是肯定不符合调用规则的
    if (![class isKindOfClass:[RLMObject class]]) return nil;
    SEL selector = @selector(allObjects);
    RLMResults *results = [class performSelector:selector];
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    for (int i = 0; i < results.count; i++)
    {
        [tmpArr addObject:[results objectAtIndex:i]];
    }
    return tmpArr;
}


@end
