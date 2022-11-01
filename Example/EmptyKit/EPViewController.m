//
//  EPViewController.m
//  EmptyKit
//
//  Created by cocomanbar on 10/30/2022.
//  Copyright (c) 2022 cocomanbar. All rights reserved.
//

#import "EPViewController.h"
#import "EPDemoViewController.h"
#import "UIView+EPDemo.h"
#import "EmptyPacker+EPDemo.h"
#import "EPDemoLoadingVIew.h"

@interface EPViewController ()

@end

@implementation EPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"测试";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *loadingButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    loadingButton.backgroundColor = UIColor.grayColor;
    [loadingButton setTitle:@"我是按钮请点击测试" forState:(UIControlStateNormal)];
    [loadingButton setTitleColor:UIColor.purpleColor forState:(UIControlStateNormal)];
    loadingButton.frame = CGRectMake(50, 200, 200, 80);
    loadingButton.layer.borderColor = UIColor.purpleColor.CGColor;
    loadingButton.layer.borderWidth = 1;
    [self.view addSubview:loadingButton];
    [loadingButton addTarget:self action:@selector(loadingButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    [loadingButton registerEmptyStyle:(EmptyRunLoading) forPackerBlock:^(EmptyPacker * _Nonnull emptyPacker) {
        EPDemoLoadingVIew *view = [[EPDemoLoadingVIew alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
        view.text = @"网络请求中";
        emptyPacker.customView = view;
        emptyPacker.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        emptyPacker.shouldDisplay = YES;
        emptyPacker.backgroundColor = UIColor.orangeColor;
    }];
    
    [loadingButton reloadEmptyStyle:(EmptyRunLoading)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loadingButton reloadEmptyStyle:(EmptyRunDefault)];
    });
}

- (void)loadingButtonClick {
    
    [self.navigationController pushViewController:EPDemoViewController.new animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
