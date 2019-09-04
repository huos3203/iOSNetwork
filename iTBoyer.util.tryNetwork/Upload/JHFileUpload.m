//
//  JHFileUpload.m
//  YGPatrol
//
//  Created by VH on 2017/11/28.
//  Copyright © 2017年 huoshuguang. All rights reserved.
//

#import "JHFileUpload.h"
//#import "HttpIpFileService.h"
//#import "JHUPLoadComponent.h"

@interface JHFileUpload ()<JinherUploadCenterProtocol>
@property (copy, nonatomic) uploadedData uploadedData;//下载完成后路径
@property (copy, nonatomic) uploading uploading;//下载中数据
@property (strong, nonatomic) JinherUploadCenterApi *uploadCenterApi;//上传器
@property(nonatomic, strong)JHUPLoadComponent *uploadRequest; //上传器二
@end


@implementation JHFileUpload

- (instancetype)initWithMehod:(NSInteger)method Path:(NSString *)path fileGid:(NSString *)gid {
    self = [super init];
    if (self) {
        _localPath = path; //赋值,readonly ,使用下划线
        _method = method;
        NSString *fileName = [path lastPathComponent];
        if (_method == 1) {
            self.uploadCenterApi =
            [[JinherUploadCenterApi alloc] initWithUploadFileWithFilePath:_localPath
                                                               fileServer:@"api_host_upload"
                                                            andUploadName:fileName
                                                                  andGuid:gid
                                                             withDelegate:self];
        }
        if (_method == 2) {
            _uploadRequest = [[JHUPLoadComponent alloc] init];
            [_uploadRequest setEachPiece:100];
        }
        
    }
    return self;
}



-(void)startUpload{
    if (_method == 1) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 处理耗时操作的代码块...
            [self.uploadCenterApi setFunc:UPLOAD_start];
//        });
    }
    if (_method == 2) {
        [self secondMethod];
    }
   
}

-(void)didSuspend{
    [self.uploadCenterApi setFunc:UPLOAD_pause];
}

- (void)didUploading:(uploading)uploading finish:(uploadedData)finished
{
    self.uploading = uploading;
    self.uploadedData = finished;
}

#pragma mark 上传文件方法二
-(void)secondMethod
{
    NSString *fileName = [_localPath lastPathComponent];
    [_uploadRequest uploadFileWithPath:_localPath fileName:fileName type:JHUPLOADTYPE_OTHER feedBack:^(JHUPLOADSTATUS status, CGFloat progress, NSString *serverFilePath) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (self.uploading) {
                self.uploading(progress);
            }
            
            if ( status == JHUPLOADSTATUS_FINISH)
            {
                if (self.uploadedData) {
                    self.uploadedData(_localPath,serverFilePath,nil);
                }
                [_delegate moveFinishedPathWithPath:_localPath];
            }
            //失败重新上传
            if (status == JHUPLOADSTATUS_ERROR) {
                [_delegate moveFinishedPathWithPath:_localPath];
                self.uploadedData(_localPath,serverFilePath,@"上传失败");
            }
        }];
    }];
        //        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
}

#pragma mark - 上传到文件服务器
-(NSString *)urlFromIpFile {
    NSString *fileServer = [NSString stringWithString:[[HttpIpFileService shareInstance]
                                            getIpFile:@"api_host_upload"]];
    NSString *urlString = [NSString stringWithFormat:@"%@/Jinher.JAP.BaseApp.FileServer.UI/FileManage/GetFile", fileServer];
    return urlString;
}

#pragma mark JinherUploadCenterProtocol method 上传回调方法
- (void)jinherUploadTaskGuid:(NSString *)guid andTaskEn:(JinherUploadTask *)task
{
    
    NSLog(@"%@--下载信息：%@",task.name,task.message);
    if (self.uploading) {
        float pregress = (float)task.updatedSize/task.fileSize;
        if (isnan(pregress)) {
            pregress = 0.0;
        }
        self.uploading(pregress);
    }

    if (task.state == UPSTATE_finish) {
        if (![task.downloadUrl hasPrefix:@"https"])
        {
            task.downloadUrl = [task.downloadUrl stringByReplacingOccurrencesOfString:@"(null)"
                                                                           withString:[self urlFromIpFile]];
        }
        if (self.uploadedData) {
            self.uploadedData(task.filePath,task.downloadUrl,nil);
        }
        [_delegate moveFinishedPathWithPath:task.filePath];
    }
    if (task.state == UPSTATE_error) {
        [_delegate moveFinishedPathWithPath:task.filePath];
        
        self.uploadedData(task.filePath,task.downloadUrl,[task.message stringByAppendingString:@"--方法一"]);
    }
}

@end
