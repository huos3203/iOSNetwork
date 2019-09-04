//
//  SingletonUpload.m
//  YGPatrol
//
//  Created by VH on 2017/11/28.
//  Copyright © 2017年 huoshuguang. All rights reserved.
//

#import "SingletonUpload.h"


#define UploadMaxNum 5
#define UploadMethod 2  //1:JinherUploadCenterApi 2:JHUPLoadComponent

@interface SingletonUpload ()
//创建一个字典,用来保存当前的下载,使单例持有它,从而不会被销毁
@property (strong, nonatomic) NSMutableDictionary *allUploaderDic;
@property (strong, nonatomic) NSMutableDictionary *waitUploaderDic;
@end

@implementation SingletonUpload
- (NSMutableDictionary *)allUploaderDic {
    if (!_allUploaderDic) {
        self.allUploaderDic = [NSMutableDictionary dictionary];
    }
    return _allUploaderDic;
}

-(NSMutableDictionary *)waitUploaderDic
{
    if (!_waitUploaderDic) {
        self.waitUploaderDic = [NSMutableDictionary dictionary];
    }
    return _waitUploaderDic;
}
//创建单例
+ (instancetype)shared {
    static SingletonUpload *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[SingletonUpload alloc] init];
    });
    return singleton;
}
//添加一个上传
//下载进度接口
//- (void)didUploading:(uploading)uploading finish:(uploadedData)finished{
//    self.uploading = uploading; //block赋值
//    self.uploadedData = finished;
//}
- (JHFileUpload *)addUploaderWithPath:(NSString *)local fileGid:(NSString *)gid{
    
    JHFileUpload *uploadloader = self.waitUploaderDic[local];
    if (!uploadloader) {
        uploadloader = [[JHFileUpload alloc] initWithMehod:UploadMethod Path:local fileGid:gid];
        uploadloader.delegate = self;
        [self.waitUploaderDic setValue:uploadloader forKey:local];
    }
    [self startMaxNumUpload];
    return uploadloader;
}

-(void)startMaxNumUpload
{
    while (self.allUploaderDic.count < UploadMaxNum && self.waitUploaderDic.count > 0) {
        //开启等待队列
        NSString *waitUrl = self.waitUploaderDic.allKeys.firstObject;
        JHFileUpload *uploadloader =self.waitUploaderDic.allValues.firstObject;
        [uploadloader startUpload];
        [self.allUploaderDic setObject:uploadloader forKey:waitUrl];
        [self.waitUploaderDic removeObjectForKey:waitUrl];
    }
}


//根据url找到下载
- (JHFileUpload *)findUploaderWithPath:(NSString *)local{
    return self.allUploaderDic[local];
}
//返回所有下载
- (NSArray *)allUploader {
    return [self.allUploaderDic allValues];
}

#pragma mark-----代理执行----
-(void)moveFinishedPathWithPath:(NSString *)path
{
    //完成一个后，开启下一个上传
    [self.allUploaderDic removeObjectForKey:path];
    [self startMaxNumUpload];
}

@end
