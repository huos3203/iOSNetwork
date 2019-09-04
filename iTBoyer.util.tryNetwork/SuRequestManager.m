//
//  SuRequestManager.m
//  GBCheckUpLibrary
//
//  Created by admin on 2019/5/9.
//  Copyright © 2019 jinher. All rights reserved.
//

#import "SuRequestManager.h"
#import "SuperAddRectTask.h"
#import "SuRequest.h"
#import "RetryDBManager.h"
#import "SingletonUpload.h"
//#import "SuperReqRectifServer.h"
//#import "JHRoutingComponent.h"
#import "APIRequest.h"

@interface SuRequestManager ()

//回调的图片路径数组
@property (nonatomic,strong) NSMutableArray<NSString *> * imagePicUrlStrArray;

//最后一个上传的图片所属业务ID
@property (nonatomic,strong) NSString * optId;

@property (strong, nonatomic) NSMutableArray *commitingArr;

@end


@implementation SuRequestManager

#pragma mark  ----  懒加载

-(NSMutableArray<NSString *> *)imagePicUrlStrArray{
    
    if (!_imagePicUrlStrArray) {
        
        _imagePicUrlStrArray = [[NSMutableArray alloc] init];
    }
    return _imagePicUrlStrArray;
}

-(NSMutableArray *)commitingArr
{
    if (!_commitingArr) {
        _commitingArr = [NSMutableArray new];
    }
    return _commitingArr;
}

+(id)shared {
    static SuRequestManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

#pragma mark - API
-(void)clearOpt:(NSString *)optId
{
    [[RetryDBManager shared] clearImgRecord:optId];
}
-(NSArray *)retryOptIds
{
    return [[RetryDBManager shared] retryOptIds];
}

-(void)retryRecordFor:(NSString *)optId
{
    if (![APIRequest isReachable]) return;
    if (!optId) return;
    if ([self isExistOpt:optId]) {
        NSArray *pics = [[RetryDBManager shared] allRecordBy:optId];
        for (SuperRectOptPics *pic in pics) {
            if (pic.status.integerValue == 2) continue;
            [self startUploaderOf:pic];
        }
    }
}

-(void)retryAllRecord
{
    if (![APIRequest isReachable]) return;
    //直接提交可以上传的
    [self lanuchCanCommit];
    //上传未完成的
    [self lanunchUploader];
}

-(void)lanuchCanCommit
{
    NSArray *opts = [[RetryDBManager shared] retryOptsForCanComit];
    for (NSString *optId in opts) {
        [self tryCommit:optId];
    }
}

-(void)lanunchUploader
{
    NSArray *opts = [[RetryDBManager shared] retryOptsForUpload];
    for (NSString *optId in opts) {
        BOOL isFail = [[RetryDBManager shared] isFailOpt:optId];
        if (!isFail) {
            [self tryCommit:optId];
            continue;
        }
        NSArray *pics = [[RetryDBManager shared] allRecordBy:optId];
        for (SuperRectOptPics *pic in pics) {
            if (pic.status.integerValue == 2) continue;
            [self startUploaderOf:pic];
        }
    }
}


-(void)startUpload:(SuperRectOptPics *)model
{
    
    if (model.optId) {
        
        self.optId = model.optId;
    }
    
    //存数据库
    BOOL success = [[RetryDBManager shared] insertUploadImageRecord:model];
    if (![APIRequest isReachable]) return;
    if (success) {
        //开启上传
        [self startUploaderOf:model];
    }else{
        [self tryCommit:model.optId];
    }
}

-(void)tryCommit:(NSString *)optId{
    //提交
    if (!optId) return;
    BOOL isFail = [[RetryDBManager shared] isFailOpt:optId];
    if (isFail) return;
    //数据库中查询/返回对象
    SuperAddRectTask *task = [[RetryDBManager shared] tryRequestRecord:optId];
    if (task) {
        BOOL isCommiting = false;
        for (NSString *commitid in _commitingArr) {
            if ([commitid isEqualToString:optId]) {
                isCommiting = true;
                break;
            }
        }
        if (isCommiting) return;
        [self.commitingArr addObject:optId];
        /**
        [[SuperReqRectifServer shared] reqAddRectTask:task handler:^(BOOL result) {
            [self.commitingArr removeObject:optId];
            if (result) {
                BOOL ok = [[RetryDBManager shared] deleteRequestRecord:optId];
                if (ok) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reshShadeViewNotification" object:nil];
                }
            }
        }];
         **/
    }
}

-(void)saveOptId:(NSString *)optId forTask:(SuperAddRectTask *)opt
{
    
    if (optId) {
        
        self.optId = optId;
    }
    
    NSArray *pics = [[RetryDBManager shared] allRecordBy:self.optId];
    NSLog(@"个数：%ld",pics.count);
    
    SuRequest *req = [[SuRequest alloc] initWithOptId:optId task:opt];
    BOOL ok = [[RetryDBManager shared] insertRequestRecord:req];
    if(ok) [self tryCommit:optId];
}

-(BOOL)isExistOpt:(NSString *)optId
{
    if (!optId)return NO;
    return [[RetryDBManager shared] isExistOpt:optId];
}

+(NSString *)archivePath
{
    return [[RetryDBManager shared] dbPath];
}

#pragma mark - 上传器

-(void)startUploaderOf:(SuperRectOptPics *)opt
{
    
    if (![APIRequest isReachable]) return;
    if ([opt.Picture hasPrefix:@"http"]) return;  //已完成,是以http开头,直接返回
    if (![[NSFileManager defaultManager] fileExistsAtPath:opt.Picture]) {
        [[RetryDBManager shared] removePic:opt.gId];
        return;
    }
    
    if (opt.optId) {
        
        self.optId = opt.optId;
    }
    
    NSArray *pics = [[RetryDBManager shared] allRecordBy:self.optId];
    NSLog(@"个数：%ld",pics.count);
    
    JHFileUpload *uploader = [[SingletonUpload shared] addUploaderWithPath:opt.Picture fileGid:opt.gId];
    [uploader didUploading:^(float progress) {
        NSLog(@"%f 进度---",progress);
        opt.status = [NSNumber numberWithInteger:1];
    } finish:^(NSString *path, NSString *url, NSString *error) {
        //上传路径
        if (!error) {
            opt.Picture = url;
            opt.status = [NSNumber numberWithInteger:2];
            [[RetryDBManager shared] updateUploadStatusFor:opt];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            [self tryCommit:opt.optId];
            
            if (self.isCallBack) {
             
                [self.imagePicUrlStrArray addObject:url];
            }
        }else{
            
            opt.status = [NSNumber numberWithInteger:0];
            [[RetryDBManager shared] updateUploadStatusFor:opt];
            
            if (self.isCallBack) {
                
                [self.imagePicUrlStrArray addObject:@""];
            }
        }
        
        if (self.imagePicUrlStrArray.count > 0 && self.picCount == self.imagePicUrlStrArray.count) {
            
            //发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RECTIFICATIONUPLOADIMAGE" object:[NSArray arrayWithArray:self.imagePicUrlStrArray]];
            [self.imagePicUrlStrArray removeAllObjects];
        }
        else if (self.isFinish){
            
            //主动完成
            ///查询检查项待上传的图片记录
            NSArray *pics = [[RetryDBManager shared] allRecordBy:self.optId];
            if (pics.count == self.imagePicUrlStrArray.count) {
                
                //发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RECTIFICATIONUPLOADIMAGE" object:[NSArray arrayWithArray:self.imagePicUrlStrArray]];
                [self.imagePicUrlStrArray removeAllObjects];
                self.isFinish = NO;
            }
        }
    }];
}

-(void)finishTakePhoto{
    
    //主动完成
    self.isFinish = YES;
    ///查询检查项待上传的图片记录
    NSArray *pics = [[RetryDBManager shared] allRecordBy:self.optId];
    if (pics.count == self.imagePicUrlStrArray.count) {
        
        //发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RECTIFICATIONUPLOADIMAGE" object:[NSArray arrayWithArray:self.imagePicUrlStrArray]];
        [self.imagePicUrlStrArray removeAllObjects];
        self.isFinish = NO;
    }
}


@end
