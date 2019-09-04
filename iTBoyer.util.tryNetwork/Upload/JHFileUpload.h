//
//  JHFileUpload.h
//  YGPatrol
//
//  Created by VH on 2017/11/28.
//  Copyright © 2017年 huoshuguang. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JinherUploadCenterApi.h" //图片上传
//定义block
typedef void(^uploadedData)(NSString *path, NSString *url, NSString *error);
typedef void(^uploading)(float progress);

//定义一个代理
@protocol JHFileUploadDelegate <NSObject>
//一个一定要执行的代理, 作用: 让单例代理对象销毁下载对象
- (void)moveFinishedPathWithPath:(NSString *)path;
@end

@interface JHFileUpload : NSObject

@property (strong, nonatomic, readonly) NSString *localPath;//文件沙盒路径
@property (weak, nonatomic) id<JHFileUploadDelegate>delegate;


//创建一个上传
- (instancetype)initWithMehod:(NSInteger)method Path:(NSString *)path fileGid:(NSString *)gid;
@property (assign, nonatomic, readonly) NSInteger method;//1:JinherUploadCenterApi 2:JHUPLoadComponent

-(void)startUpload;
//暂停接口
- (void)didSuspend;
//恢复上传接口
- (void)didResume;
//上传进度接口
- (void)didUploading:(uploading)uploading finish:(uploadedData)finished;

@end
