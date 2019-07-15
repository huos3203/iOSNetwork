//
//  SuRequestManager.h
//  GBCheckUpLibrary
//
//  Created by admin on 2019/5/9.
//  Copyright © 2019 jinher. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SuRequest;
@class SuperRectOptPics;
@class SuperAddRectTask;
@interface SuRequestManager : NSObject

//图片全部上传完之后，是否回调
@property (nonatomic,assign) BOOL isCallBack;
//需拍照数量
@property (nonatomic,assign) NSUInteger picCount;
//是否是主动完成
@property (nonatomic,assign) BOOL isFinish;

+(id)shared;

+(NSString *)archivePath;
-(NSArray *)retryOptIds;
//paizhao
-(void)startUpload:(SuperRectOptPics *)model;
//自查请求记录
-(void)retryAllRecord;
-(void)retryRecordFor:(NSString *)optId;
//保存
-(void)saveOptId:(NSString *)optId forTask:(SuperAddRectTask *)opt;
-(BOOL)isExistOpt:(NSString *)optId;
//中断操作,清空检查项
-(void)clearOpt:(NSString *)optId;

//完成拍摄
-(void)finishTakePhoto;

@end

NS_ASSUME_NONNULL_END
