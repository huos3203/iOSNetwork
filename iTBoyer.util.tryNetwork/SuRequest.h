//
//  SuRequest.h
//  GBCheckUpLibrary
//
//  Created by admin on 2019/5/9.
//  Copyright © 2019 jinher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperRectOptPics.h"
#import "BCDB.h"
NS_ASSUME_NONNULL_BEGIN
@class SuperAddRectTask;
@interface SuRequest : NSObject <BCORMEntityProtocol>
-(instancetype)initWithOptId:(NSString *)optId task:(SuperAddRectTask *)task;
//id
@property (strong, nonatomic) NSString *optId;
//0:不能提交 1:已完成拍照 上传完成执行提交,否则,暂存记录
@property (assign, nonatomic) NSInteger canCommit;
/**请求参数对*/
@property (nonatomic, strong) NSDictionary *params;
/**
 realm不支持NSDictionary，所以params直接转化为字符串存储
 只在请求需要存入数据库中，此参数才有相应的作用
 ZYRequestReliabilityStoreToDB这种类型下
 */
@property (nonatomic, copy) NSString *paramStr;

@property (strong, nonatomic) SuperAddRectTask *addTask;

@end

NS_ASSUME_NONNULL_END
