//
//  ViewController.m
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/21.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ViewController.h"
#import "ZYRequestManager.h"
#import "ZYRequest.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ZYRequestManager *mgr = [ZYRequestManager sharedInstance];
    for (int i = 0; i < 100; i++)
    {
        ZYRequest *request = [[ZYRequest alloc] init];
        request.urlStr = @"http://qf.56.com/pay/v4/giftList.ios";
        request.params = @{@"type": @0, @"page": @1, @"rows": @150};
        request.requestId = i;
        
        [mgr sendRequest:request successBlock:^(id obj) {
            NSLog(@"++++++++%d", request.requestId);
        } failureBlock:nil];
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 30);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
