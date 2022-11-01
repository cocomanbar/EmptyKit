//
//  EmptyPacker.h
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import <Foundation/Foundation.h>
#import "UIScrollView+EmptyKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmptyPacker : NSObject
<EmptyDataSetSource, EmptyDataSetDelegate>

/// 展示按照fadeIn动画，底层库自带 0.25s 默认YES。
@property (nonatomic, assign) BOOL shouldFadeIn;

/// 强制展示的判断逻辑是 ( (shouldDisplay && [listTable count] || shouldBeForcedToDisplay)
@property (nonatomic, assign) BOOL shouldDisplay;
@property (nonatomic, assign) BOOL shouldBeForcedToDisplay;

/// 空白页是否接受用户事件 default YES
@property (nonatomic, assign) BOOL shouldAllowTouch;

/// 空白页是否可以拖动 default YES
@property (nonatomic, assign) BOOL shouldAllowScroll;

/// image动画
@property (nonatomic, strong, nullable) CAAnimation *imageAnimation;

/// 空白页背景颜色
@property (nonatomic, strong, nullable) UIColor *backgroundColor;

/// 空白页左右边距
@property (nonatomic, assign) CGFloat padding;

/// 空白页y偏移
@property (nonatomic, assign) CGFloat verticalOffset;

/// 空白页区域点击回调
@property (nonatomic, copy, nullable) void(^viewTapBlock)(void);

/// 空白页按钮点击回调
@property (nonatomic, copy, nullable) void(^buttonClickBlock)(void);

/// 此次展示的生命周期
@property (nonatomic, copy, nullable) void(^viewWillAppear)(void);
@property (nonatomic, copy, nullable) void(^viewWillDisappear)(void);
@property (nonatomic, copy, nullable) void(^viewDidAppear)(void);
@property (nonatomic, copy, nullable) void(^viewDidDisappear)(void);


#pragma mark - datasource

/// 占位图
@property (nonatomic, strong, nullable) UIImage     *image;
@property (nonatomic, strong, nullable) UIColor     *imageTintColor;

/// 大标题
@property (nonatomic, strong, nullable) NSString    *title;
@property (nonatomic, strong, nullable) UIFont      *titleFont;
@property (nonatomic, strong, nullable) UIColor     *titleColor;
@property (nonatomic, assign) CGFloat                titleLineSpacing;
@property (nonatomic, assign) CGFloat                titleSpace;

/// 副标题
@property (nonatomic, strong, nullable) NSString    *descrip;
@property (nonatomic, strong, nullable) UIFont      *descripFont;
@property (nonatomic, strong, nullable) UIColor     *descripColor;
@property (nonatomic, assign) CGFloat                descripLineSpacing;
@property (nonatomic, assign) CGFloat                descripSpace;

/// 按钮
@property (nonatomic, strong, nullable) NSString    *buttonTitle;
@property (nonatomic, strong, nullable) UIFont      *buttonTitleFont;
@property (nonatomic, strong, nullable) UIColor     *buttonTitleColor;
@property (nonatomic, strong, nullable) UIImage     *buttonTitleImage;
@property (nonatomic, strong, nullable) UIImage     *buttonTitleBackgroundImage;
@property (nonatomic, strong, nullable) UIColor     *buttonTitleBackgroundColor;
@property (nonatomic, assign) CGFloat                buttonTitleLineSpacing;
@property (nonatomic, assign) CGFloat                buttonSpace;
@property (nonatomic, assign) UIEdgeInsets           buttonEdgeInsets;
@property (nonatomic, assign) CGFloat                buttonRadiusScale;


/// 自定义view
@property (nonatomic, strong, nullable) UIView      *customView;

/// 额外传size
@property (nonatomic, assign) CGSize customViewSize;

#pragma mark - 以下是用到UIView上时才生效的属性

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

#pragma mark - 绑定一个自定消息

@property (nonatomic, strong) NSDictionary *info;

@end

NS_ASSUME_NONNULL_END
