//
//  ReDBManager.h
//  GBCheckUp
//
//  Created by admin on 2019/5/13.
//  Copyright © 2019 jinher. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SuRequest;
@class SuperRectOptPics;
@class SuperAddRectTask;
@interface RetryDBManager : NSObject
+(id)shared;

///sqlite操作
-(NSString *)dbPath;
//保存图片上传记录
-(BOOL)insertUploadImageRecord:(SuperRectOptPics *)model;
///更新图片上传状态
-(void)updateUploadStatusFor:(SuperRectOptPics *)model;
-(void)removePic:(NSString *)gid;
///所有图片上传完成后,情况该检查的所有图片记录
-(BOOL)clearImgRecord:(NSString *)optId;
///查询检查项待上传的图片记录
-(NSArray *)allRecordBy:(NSString *)optId;
-(BOOL)isFailOpt:(NSString *)optId;

//请求记录的管理
-(NSArray *)retryOptIds;
-(NSArray *)retryOptsForCanComit;
-(NSArray *)retryOptsForUpload;
-(BOOL)isExistOpt:(NSString *)optId;
-(BOOL)insertRequestRecord:(SuRequest *)model;
-(SuperAddRectTask *)tryRequestRecord:(NSString *)optId;
-(BOOL)deleteRequestRecord:(NSString *)optId;

@end

NS_ASSUME_NONNULL_END
