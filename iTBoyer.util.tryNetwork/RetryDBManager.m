//
//  ReDBManager.m
//  GBCheckUp
//
//  Created by admin on 2019/5/13.
//  Copyright © 2019 jinher. All rights reserved.
//

#import "RetryDBManager.h"
#import "BCORMHelper.h"
#import  "SuRequest.h"
#import "SuperAddRectTask.h"
@implementation RetryDBManager
{
    BCORMHelper* helper;
}
+(id)shared {
    static RetryDBManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        [shared createTable];
    });
    return shared;
}
///创建表
-(void)createTable
{
    helper = [[BCORMHelper alloc]initWithDatabaseName:@"RetryNetWork.db"
                                               enties: @[[SuRequest class],[SuperRectOptPics class]]];
}

-(NSString *)dbPath
{
    //完整的文件路径
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *archieDoc = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"RetryDoc"];
    if (![filemanager fileExistsAtPath:archieDoc]) {
        NSError *error;
        BOOL ok = [filemanager createDirectoryAtPath:archieDoc withIntermediateDirectories:YES attributes:nil error:&error];
        if(!ok){
            archieDoc = nil;
        }
    }else{
        return archieDoc;
    }
    return archieDoc;
}

#pragma mark - 上传图片管理
//保存图片上传记录
-(BOOL)insertUploadImageRecord:(SuperRectOptPics *)model
{
    SuperRectOptPics *pic = [self isExistInDBOf:model.optId order:model.Order];
    if (pic) {
        if (pic.status.integerValue != 2) {
            //已存在更新
           return [helper update:model];
        }else{
            return NO;
        }
    }else{//不存在保存
        return [helper save:model];
    }
}
-(void)removePic:(NSString *)gid
{
    if (!gid)return;
    [helper deleteByCondition:BCDeleteParameterMake([SuperRectOptPics class],  @"gId = ?", @[gid])];
}
-(SuperRectOptPics *)isExistInDBOf:(NSString *)optId order:(NSInteger)order
{
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [SuperRectOptPics class];
    queryParam.selection = @"optId = ? and Order = ?";
    queryParam.selectionArgs = @[optId,[NSNumber numberWithInteger:order]];
    NSArray* entities = [helper queryEntitiesByCondition:queryParam];
    if (entities.count > 0) {
        return entities[0];
    }else{
        return nil;
    }
}
-(void)updateUploadStatusFor:(SuperRectOptPics *)model
{
    //按照着gId更新
    [helper updateByCondition:BCUpdateParameterMake([SuperRectOptPics class], @"status=?,Picture=?", @[model.status,model.Picture], @"gId=?", @[model.gId])];
}

-(BOOL)clearImgRecord:(NSString *)optId
{
    if (!optId)return NO;
    return [helper deleteByCondition:BCDeleteParameterMake([SuperRectOptPics class],  @"optId = ?", @[optId])];
}

-(NSArray *)allRecordBy:(NSString *)optId
{
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [SuperRectOptPics class];
    queryParam.selection = @"optId = ?";
    queryParam.selectionArgs = @[optId];
    NSArray* entities = [helper queryEntitiesByCondition:queryParam];
    return entities;
}

-(BOOL)isFailOpt:(NSString *)optId
{
    //query many models
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [SuperRectOptPics class];
    queryParam.selection = @"optId = ? and status < ?";
    queryParam.selectionArgs = @[optId,@2];
    NSArray* entities = [helper queryEntitiesByCondition:queryParam];
    return entities.count;
}
-(BOOL)isExistOpt:(NSString *)optId
{
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [SuRequest class];
    queryParam.selection = @"optId = ?";
    queryParam.selectionArgs = @[optId];
    NSArray* entities = [helper queryEntitiesByCondition:queryParam];
    return entities.count;
}
//
-(NSArray *)retryOptIds
{
     NSArray *arr  = [helper queryEntitiesByCondition:BCQueryParameterMake([SuRequest class], nil, nil, nil, nil, nil, -1, -1)];
    NSMutableArray *optIdArr = [NSMutableArray new];
    for (SuRequest *request in arr) {
        [optIdArr addObject:request.optId];
    }
    return [optIdArr copy];
}

-(NSArray *)retryOptsForCanComit
{
    NSArray *arr  = [helper queryEntitiesByCondition:BCQueryParameterMake([SuRequest class], nil, @"canCommit=?", @[@1], nil, nil, -1, -1)];
    NSMutableArray *optIdArr = [NSMutableArray new];
    for (SuRequest *request in arr) {
        [optIdArr addObject:request.optId];
    }
    return [optIdArr copy];
}

- (NSArray *)retryOptsForUpload
{
    NSArray *arr  = [helper queryEntitiesByCondition:BCQueryParameterMake([SuRequest class], nil, @"canCommit=?", @[@0], nil, nil, -1, -1)];
    NSMutableArray *optIdArr = [NSMutableArray new];
    for (SuRequest *request in arr) {
        [optIdArr addObject:request.optId];
    }
    return [optIdArr copy];
}

-(BOOL)insertRequestRecord:(SuRequest *)model
{
    if (![self isFailOpt:model.optId]) {
        model.canCommit = 1;
    }
    return [helper save:model];
}

-(void)updateRequesRecord:(SuRequest *)model
{
    [helper update:model];
}

-(SuperAddRectTask *)tryRequestRecord:(NSString *)optId
{
    SuRequest *request = [self fetchRequestRecord:optId];
    if (request) {
        if (![self isFailOpt:optId]) {
            //更新数据库
            request.canCommit = 1;
            [self updateRequesRecord:request];
            [request.addTask.option.OptionPicsList removeAllObjects];
            NSArray *pics = [self allRecordBy:optId];
            if (pics.count > 0) {
                [request.addTask.option.OptionPicsList addObjectsFromArray:[self allRecordBy:optId]];
            }else{
                [self deleteRequestRecord:optId];
            }
        }
    }else{
        return nil;
    }
    return request.addTask;
}

-(SuRequest *)fetchRequestRecord:(NSString *)optId
{
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [SuRequest class];
    queryParam.selection = @"optId = ?";
    queryParam.selectionArgs = @[optId];
    NSArray* entities = [helper queryEntitiesByCondition:queryParam];
    if (entities.count > 0) {
        return entities[0];
    }
    return nil;
}
-(BOOL)deleteRequestRecord:(NSString *)optId
{
    if (!optId)return NO;
    BOOL ok = [helper deleteByCondition:BCDeleteParameterMake([SuRequest class],  @"optId = ?", @[optId])];
    if (ok) {
        return [self clearImgRecord:optId];
    }
    return NO;
}
@end
