//
//  SingletonUpload.h
//  YGPatrol
//
//  Created by VH on 2017/11/28.
//  Copyright © 2017年 huoshuguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHFileUpload.h"

@interface SingletonUpload : NSObject<JHFileUploadDelegate>
//创建单例
+ (instancetype)shared;
-(void)startMaxNumUpload;
//添加一个上传对象
- (JHFileUpload *)addUploaderWithPath:(NSString *)local fileGid:(NSString *)gid;
//根据path找到一个上传对象
- (JHFileUpload *)findUploaderWithPath:(NSString *)local;

//返回所有上传对象
- (NSArray *)allUploader;
@end
