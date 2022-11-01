//
//  EPDemoViewController.m
//  EmptyKit_Example
//
//  Created by tanxl on 2022/10/31.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "EPDemoViewController.h"
#import "UIView+EPDemo.h"
#import "EmptyPacker+EPDemo.h"

@interface EPDemoViewController ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation EPDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 60;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:_tableView];
    
    
    
    [self.tableView registerEmptyStyle:(EmptyRunLoading) forPackerValue:[EmptyPacker loading]];
    [self.tableView registerEmptyStyle:(EmptyRunEmpty) forPackerValue:[EmptyPacker empty]];
    [self.tableView registerEmptyStyle:(EmptyRunError) forPackerValue:[EmptyPacker errorBlock:^{
        NSLog(@"====== ~~~~~~~");
    }]];
    
    [self.tableView reloadDataStyle:(EmptyRunLoading)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadDataStyle:(EmptyRunEmpty)];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadDataStyle:(EmptyRunError)];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadDataStyle:(EmptyRunDefault)];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"1"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"1"];
    }
    return cell;
}


@end
