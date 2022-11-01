//
//  EmptyContainer.h
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmptyContainer : UIView

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *customView;

@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat titileSpace;
@property (nonatomic, assign) CGFloat descipSpace;
@property (nonatomic, assign) CGFloat buttonSpace;
@property (nonatomic, assign) CGFloat buttonRadiusScale;

@property (nonatomic, assign) BOOL fadeInOnDisplay;

- (void)setupConstraints;
- (void)prepareForReuse;

@end

NS_ASSUME_NONNULL_END
