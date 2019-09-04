//
//  SuRequest.m
//  GBCheckUpLibrary
//
//  Created by admin on 2019/5/9.
//  Copyright © 2019 jinher. All rights reserved.
//

#import "SuRequest.h"
#import "SuperAddRectTask.h"
#import "SingletonUpload.h"

@implementation SuRequest

-(instancetype)initWithOptId:(NSString *)optId task:(SuperAddRectTask *)task
{
    if (self = [super init]) {
        self.optId = optId;
        self.params = [task toDicData];
        self.paramStr = [self DicToStr:self.params];
        self.addTask = task;
    }
    return self;
}
//- (id)copyWithZone:(NSZone *)zone
//{
//    SuRequest *request = [[[self class] allocWithZone:zone] init];
//    request.canCommit = self.canCommit;
//    request.optId = self.optId;
//    request.params = self.params;
//    request.paramStr = self.paramStr;
//    
//    return request;
//}
-(NSDictionary *)params
{
    if (!_params) {
        if (_paramStr == nil) return nil;
        NSData *jsonData = [_paramStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        _params = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:NSJSONReadingMutableContainers
                                                    error:&err];
        if(err)
        {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
    }
    return _params;
}


-(NSString *)DicToStr:(NSDictionary *)dic
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - ORM
+ (NSString *)tableName
{
    return @"SuRequest";
}
+(NSArray*)tableIndexArray
{
    return @[@"optId"];
}
+(NSDictionary *)tableEntityMapping
{
    return @{ @"optId":BCSqliteTypeMakeTextPrimaryKey(@"optId", NO),
              @"canCommit":BCSqliteTypeMakeIntDefault(@"canCommit", NO, 0),
              @"paramStr":BCSqliteTypeMakeText(@"paramStr", NO),
            };
}

-(SuperAddRectTask *)addTask
{
    if (!_addTask) {
        if (self.params) {
            _addTask = [[SuperAddRectTask alloc] initWithDictionary:self.params error:nil];
        }
    }
    return _addTask;
}
@end
