//
//  SuperRectOptPics.h
//  iTBoyer.util.tryNetwork
//
//  Created by admin on 2019/9/4.
//  Copyright © 2019 王志盼. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface SuperRectOptPics : JSONModel
@property (strong, nonatomic) NSString *optId;
@property (strong, nonatomic) NSString *gId;
@property (strong, nonatomic) NSString *Picture;
@property (strong, nonatomic) NSNumber *status;
@property (assign, nonatomic) NSInteger Order;
@end

NS_ASSUME_NONNULL_END
