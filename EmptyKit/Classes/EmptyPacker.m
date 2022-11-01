//
//  EmptyPacker.m
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import "EmptyPacker.h"

@implementation EmptyPacker

- (instancetype)init{
    if (self = [super init]) {
        
        _padding = 0;
        _shouldAllowScroll = YES;
        _shouldFadeIn = YES;
        _shouldDisplay = YES;
        _shouldAllowTouch = YES;
        _shouldBeForcedToDisplay = YES;
        _customViewSize = CGSizeZero;
        _buttonEdgeInsets = UIEdgeInsetsZero;
        _buttonRadiusScale = 0;
        _backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (UIFont *)titleFont{
    return _titleFont ?: [UIFont systemFontOfSize:15.f weight:(UIFontWeightMedium)];
}

- (UIFont *)descripFont{
    return _descripFont ?: [UIFont systemFontOfSize:14.f weight:(UIFontWeightRegular)];
}

- (UIFont *)buttonTitleFont{
    return _buttonTitleFont ?: [UIFont systemFontOfSize:15.f weight:(UIFontWeightMedium)];
}

- (UIColor *)titleColor{
    return _titleColor ?: [UIColor darkGrayColor];
}

- (UIColor *)descripColor{
    return _descripColor ?: [UIColor lightGrayColor];
}

- (UIColor *)buttonTitleColor{
    return _buttonTitleColor ?: [UIColor whiteColor];
}

#pragma mark - EmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.lineSpacing = self.titleLineSpacing;
    NSDictionary *attributes = @{NSFontAttributeName: self.titleFont,
                                 NSForegroundColorAttributeName: self.titleColor,
                                 NSParagraphStyleAttributeName: paragraph
    };
    
    return [[NSAttributedString alloc] initWithString:self.title ?: @"" attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView{
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.lineSpacing = self.descripLineSpacing;
    
    NSDictionary *attributes = @{NSFontAttributeName: self.descripFont,
                                 NSForegroundColorAttributeName: self.descripColor,
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:self.descrip ?: @"" attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return self.image;
}

- (UIColor * _Nullable)imageTintColorForEmptyDataSet:(UIScrollView *)scrollView {
    return self.imageTintColor;
}

- (CAAnimation * _Nullable)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView{
    return self.imageAnimation;
}

- (NSAttributedString * _Nullable)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    if ([self.buttonTitle isKindOfClass:NSString.class] && self.buttonTitle.length) {
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentCenter;
        paragraph.lineSpacing = self.buttonTitleLineSpacing;
        NSDictionary *attributes = @{NSFontAttributeName: self.buttonTitleFont,
                                     NSForegroundColorAttributeName: self.buttonTitleColor};
        
        return [[NSAttributedString alloc] initWithString:self.buttonTitle attributes:attributes];
    }
    return nil;
}

- (UIImage * _Nullable)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    return self.buttonTitleImage;
}

- (UIImage * _Nullable)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    return self.buttonTitleBackgroundImage;
}

- (UIColor * _Nullable)buttonBackgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return self.buttonTitleBackgroundColor;
}

- (UIColor * _Nullable)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView{
    return self.backgroundColor;
}

- (UIView * _Nullable)customViewForEmptyDataSet:(UIScrollView *)scrollView{
    return self.customView;
}

- (CGSize)customViewSizeForEmptyDataSet:(UIScrollView *)scrollView {
    return self.customViewSize;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return self.verticalOffset;
}

- (CGFloat)paddingForEmptyDataSet:(UIScrollView *)scrollView{
    return self.padding;
}

- (CGFloat)titleSpaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return self.titleSpace;
}

- (CGFloat)descriptionSpaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return self.descripSpace;
}

- (CGFloat)buttonTitleSpaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return self.buttonSpace;
}

- (UIEdgeInsets)buttonEdgeInsetsForEmptyDataSet:(UIScrollView *)scrollView {
    return self.buttonEdgeInsets;
}

- (CGFloat)buttonRadiusForEmptyDataSet:(UIScrollView *)scrollView {
    return self.buttonRadiusScale;
}

#pragma mark - EmptyDataSetDelegate

- (BOOL)emptyDataSetShouldFadeIn:(UIScrollView *)scrollView {
    return self.shouldFadeIn;
}

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    return self.shouldBeForcedToDisplay;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    return self.shouldDisplay;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView{
    return self.shouldAllowTouch;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return self.shouldAllowScroll;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view{
    !self.viewTapBlock ?: self.viewTapBlock();
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    !self.buttonClickBlock ?: self.buttonClickBlock();
}

#pragma mark - life circle

- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView{
    !self.viewWillAppear ?: self.viewWillAppear();
}

- (void)emptyDataSetWillDisappear:(UIScrollView *)scrollView{
    !self.viewWillDisappear ?: self.viewWillDisappear();
}

- (void)emptyDataSetDidDisappear:(UIScrollView *)scrollView{
    !self.viewDidDisappear ?: self.viewDidDisappear();
}

- (void)emptyDataSetDidAppear:(UIScrollView *)scrollView{
    !self.viewDidAppear ?: self.viewDidAppear();
}

@end
