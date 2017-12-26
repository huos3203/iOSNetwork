//
//  ZYRequestRealm.h
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/26.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface ZYRequestRealm : NSObject
+ (instancetype)shareInstance;

//添加or更新对象
- (void)addOrUpdateObj:(RLMObject *)obj;
- (void)addorUpdateObjArray:(NSArray<RLMObject *> *)objArr;

//删除对象
- (void)deleteObj:(RLMObject *)obj;
- (void)deleteObjArray:(NSArray<RLMObject *> *)objArr;
//删除RLMResults对象
- (void)deleteResultsObj:(RLMResults *)results;

//查询所有数据
- (NSArray<RLMObject *> *)queryAllObjsForClass:(Class)class;

@end
