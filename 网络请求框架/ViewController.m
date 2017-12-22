//
//  ViewController.m
//  网络请求框架
//
//  Created by 王志盼 on 2017/12/21.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dispatch_queue_t serialQueue = dispatch_queue_create("com.xxxx.www", DISPATCH_QUEUE_SERIAL);
    for(int i = 0; i<= 1000; i++)
    {
        dispatch_async(serialQueue, ^{
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"----------%@", [NSThread currentThread]);
                [NSThread sleepForTimeInterval:1];
            });
            
            NSLog(@"+++++++++++++++%@", [NSThread currentThread]);
        });
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
