//
//  ZYRequestMacro.h
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/22.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#ifndef ZYRequestMacro_h
#define ZYRequestMacro_h

typedef NS_ENUM(NSInteger, YQDRequestType) {
    YQDRequestTypeGet,
    YQDRequestTypePost,
    YQDRequestTypeDelete,
    YQDRequestTypePut
};

static BOOL kIsConnectingNetwork = true;

#endif /* ZYRequestMacro_h */
