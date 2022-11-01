//
//  EmptyPacker+EPDemo.m
//  EmptyKit_Example
//
//  Created by tanxl on 2022/10/31.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "EmptyPacker+EPDemo.h"
#import "EPDemoLoadingVIew.h"


/**
 *  demo
 */
@implementation EmptyPacker (EPDemo)

/**
 *  loading
 */

+ (EmptyPacker *)loading {
    return [self loadingText:@"正在加载中.."];
}

+ (EmptyPacker *)loadingText:(NSString *)text {
    EmptyPacker *packer = [EmptyPacker new];
    EPDemoLoadingVIew *view = [[EPDemoLoadingVIew alloc] initWithFrame:CGRectZero];
    view.text = text;
    packer.customView = view;
    packer.customViewSize = CGSizeMake(200, 80);
    packer.shouldDisplay = YES;
    return packer;
}

/**
 *  数据空
 */
+ (EmptyPacker *)empty {
    EmptyPacker *packer = [EmptyPacker new];
    packer.title = @"啊，数据空了吗";
    packer.titleFont = [UIFont boldSystemFontOfSize:22];
    packer.descripSpace = 18;
    packer.descrip = @"这是几句话的副标题描述详细的原因，这是几句话的副标题描述详细的原因，这是几句话的副标题描述详细的原因";
    packer.image = [UIImage imageNamed:@"image_empty"];
    return packer;
}


/**
 *  网络错误
 */
+ (EmptyPacker *)errorBlock:(void(^)(void))emptyViewTapBlock{
    EmptyPacker *packer = [EmptyPacker new];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    anim.values = @[@0.8, @1, @1.2, @0.9, @1.1, @1];
    anim.duration = 0.6;
    packer.imageAnimation = anim;
    
    packer.image = [UIImage imageNamed:@"image_empty"];
    packer.titleSpace = 12;
    packer.title = @"啊，网络错误了吗";
    packer.titleFont = [UIFont boldSystemFontOfSize:22];
    packer.descrip = @"这是几句话的副标题描述详细的原因，这是几句话的副标题描述详细的原因，这是几句话的副标题描述详细的原因";
    packer.descripSpace = 18;
    
    packer.buttonTitle = @"点击刷新啦";
    packer.buttonSpace = 12;
    packer.buttonTitleFont = [UIFont boldSystemFontOfSize:19];
    packer.buttonTitleBackgroundColor = UIColor.orangeColor;
    packer.buttonEdgeInsets = UIEdgeInsetsMake(10, 16, 10, 16);
    packer.buttonRadiusScale = 0.5;
    packer.buttonClickBlock = emptyViewTapBlock;
    return packer;
}

@end
