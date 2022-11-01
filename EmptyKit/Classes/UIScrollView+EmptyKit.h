//
//  UIScrollView+EmptyKit.h
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EmptyDataSetSource;
@protocol EmptyDataSetDelegate;

@interface UIScrollView (EmptyKit)

@property (nonatomic, weak) id <EmptyDataSetSource> emptyDataSetSource;
@property (nonatomic, weak) id <EmptyDataSetDelegate> emptyDataSetDelegate;

@property (nonatomic, readonly, getter = isEmptyDataSetVisible) BOOL emptyDataSetVisible;

- (void)reloadEmptyDataSet;

@end


@protocol EmptyDataSetSource <NSObject>
@optional

/// 图片
- (UIImage * _Nullable )imageForEmptyDataSet:(UIScrollView *)scrollView;

/// 图片动画
- (CAAnimation * _Nullable) imageAnimationForEmptyDataSet:(UIScrollView *) scrollView;

/// 标题文本
- ( NSAttributedString * _Nullable )titleForEmptyDataSet:(UIScrollView *)scrollView;

/// 小标题文本
- (NSAttributedString * _Nullable )descriptionForEmptyDataSet:(UIScrollView *)scrollView;

/// 按钮文本
- (NSAttributedString * _Nullable)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/// 按钮图片
- (UIImage * _Nullable)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/// 按钮背景图片
- (UIImage * _Nullable)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state;

/// 按钮背景颜色
- (UIColor * _Nullable)buttonBackgroundColorForEmptyDataSet:(UIScrollView *)scrollView;

/// 空白页背景颜色
- (UIColor * _Nullable)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView;

/// 自定义视图
- (UIView * _Nullable)customViewForEmptyDataSet:(UIScrollView *)scrollView;

/// 垂直方向偏移
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView;

/// 左右间距
- (CGFloat)paddingForEmptyDataSet:(UIScrollView *)scrollView;

/// 标题与上面的间距
- (CGFloat)titleSpaceHeightForEmptyDataSet:(UIScrollView *)scrollView;

/// 小标题与上面的间距
- (CGFloat)descriptionSpaceHeightForEmptyDataSet:(UIScrollView *)scrollView;

/// 按钮与上面的间距
- (CGFloat)buttonTitleSpaceHeightForEmptyDataSet:(UIScrollView *)scrollView;

/// 按钮的内间距
- (UIEdgeInsets)buttonEdgeInsetsForEmptyDataSet:(UIScrollView *)scrollView;

/// 按钮的圆角
- (CGFloat)buttonRadiusForEmptyDataSet:(UIScrollView *)scrollView;

@end


@protocol EmptyDataSetDelegate <NSObject>
@optional

/// 展示时允许带个小动画
- (BOOL)emptyDataSetShouldFadeIn:(UIScrollView *)scrollView;

/// 默认添加上来就允许展示
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView;

/// 将会被强制展示
- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView;

/// 空白页允许被点击
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView;

/// 空白页允许上下滑动
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView;

/// 空白页点击回调
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view;

/// 按钮点击回调
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button;

/// 声明周期回调
- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView;
- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView;
- (void)emptyDataSetWillDisappear:(UIScrollView *)scrollView;
- (void)emptyDataSetDidDisappear:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
