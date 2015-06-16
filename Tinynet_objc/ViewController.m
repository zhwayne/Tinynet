//
//  ViewController.m
//  Tinynet_objc
//
//  Created by wayne on 15/5/26.
//  Copyright (c) 2015年 wayne. All rights reserved.
//

#import "ViewController.h"
#import "Tinynet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [Tinynet get:@"http://a.hiphotos.baidu.com/image/pic/item/4034970a304e251fd55da4f9a586c9177f3e530c.jpg" completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"ok");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
