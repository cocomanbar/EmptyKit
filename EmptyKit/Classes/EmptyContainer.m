//
//  EmptyContainer.m
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import "EmptyContainer.h"
#import "UIView+EmptyConstraintBasedLayoutExtensions.h"

@implementation EmptyContainer

- (instancetype)init
{
    self =  [super init];
    if (self) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)didMoveToSuperview
{
    self.frame = self.superview.bounds;
    
    __weak typeof(self)weakSelf = self;
    void(^fadeInBlock)(void) = ^{weakSelf.contentView.alpha = 1.0;};
    
    if (self.fadeInOnDisplay) {
        [UIView animateWithDuration:0.25
                         animations:fadeInBlock
                         completion:NULL];
    }
    else {
        fadeInBlock();
    }
}


#pragma mark - Getters

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [UIView new];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = YES;
        _contentView.alpha = 0;
    }
    return _contentView;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = NO;
        _imageView.accessibilityIdentifier = @"empty set background image";
        
        [_contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel.font = [UIFont systemFontOfSize:27.0];
        _titleLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.accessibilityIdentifier = @"empty set title";
        
        [_contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [UILabel new];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.backgroundColor = [UIColor clearColor];
        
        _detailLabel.font = [UIFont systemFontOfSize:17.0];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.numberOfLines = 0;
        _detailLabel.accessibilityIdentifier = @"empty set detail label";
        
        [_contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIButton *)button
{
    if (!_button)
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        _button.backgroundColor = [UIColor clearColor];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _button.accessibilityIdentifier = @"empty set button";
        
        [_button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:_button];
    }
    return _button;
}

- (BOOL)canShowImage
{
    return (_imageView.image && _imageView.superview);
}

- (BOOL)canShowTitle
{
    return (_titleLabel.attributedText.string.length > 0 && _titleLabel.superview);
}

- (BOOL)canShowDetail
{
    return (_detailLabel.attributedText.string.length > 0 && _detailLabel.superview);
}

- (BOOL)canShowButton
{
    if ([_button attributedTitleForState:UIControlStateNormal].string.length > 0 || [_button imageForState:UIControlStateNormal]) {
        return (_button.superview != nil);
    }
    return NO;
}


#pragma mark - Setters

- (void)setCustomView:(UIView *)view
{
    if (!view) {
        return;
    }
    
    if (_customView) {
        [_customView removeFromSuperview];
        _customView = nil;
    }
    
    _customView = view;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_customView];
}


#pragma mark - Action Methods

- (void)didTapButton:(id)sender
{
    SEL selector = NSSelectorFromString(@"empty_didTapDataButton:");
    
    if ([self.superview respondsToSelector:selector]) {
        [self.superview performSelector:selector withObject:sender afterDelay:0.0f];
    }
}

- (void)removeAllConstraints
{
    [self removeConstraints:self.constraints];
    [_contentView removeConstraints:_contentView.constraints];
}

- (void)prepareForReuse
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _button = nil;
    _imageView = nil;
    _titleLabel = nil;
    _customView = nil;
    _detailLabel = nil;
    
    [self removeAllConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.buttonRadiusScale > 0) {
        self.button.layer.cornerRadius = self.button.frame.size.height * self.buttonRadiusScale;
        self.button.layer.masksToBounds = YES;
    }
}

#pragma mark - Auto-Layout Configuration

- (void)setupConstraints
{
    // First, configure the content view constaints
    // The content view must alway be centered to its superview
    NSLayoutConstraint *centerXConstraint = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterX];
    NSLayoutConstraint *centerYConstraint = [self equallyRelatedConstraintWithView:self.contentView attribute:NSLayoutAttributeCenterY];
    
    [self addConstraint:centerXConstraint];
    [self addConstraint:centerYConstraint];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": self.contentView}]];
    
    // When a custom offset is available, we adjust the vertical constraints' constants
    if (self.verticalOffset != 0 && self.constraints.count > 0) {
        centerYConstraint.constant = self.verticalOffset;
    }
    
    // If applicable, set the custom view's constraints
    if (_customView) {
        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bomConstraint = [NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        [self.contentView addConstraints:@[centerXConstraint, centerYConstraint, topConstraint, bomConstraint]];
        
        CGSize viewSize = _customView.frame.size;
        NSAssert(!CGSizeEqualToSize(viewSize, CGSizeZero), @"Custom size equalTo zero.");
        
        NSLayoutConstraint *wConstraint = [NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:viewSize.width];
        NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:_customView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:viewSize.height];
        [self.contentView addConstraints:@[wConstraint, hConstraint]];
    }
    else {
        CGFloat padding = self.padding;
        padding = MAX(0, padding);
        
        UIView *topView;
        UIView *currentView;
        CGFloat constant = 0.0;
        UIView *fatherView = self.contentView;
        NSLayoutAttribute attribute = NSLayoutAttributeTop;
        
        // Assign the image view's horizontal constraints
        if (_imageView.superview) {
            currentView = _imageView;
            attribute = NSLayoutAttributeBottom;
            if (!topView) {
                attribute = NSLayoutAttributeTop;
                topView = self.contentView;
            }
            
            NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fatherView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:attribute multiplier:1.0 constant:0.0];
            [self.contentView addConstraints:@[centerXConstraint, topConstraint]];
            topView = currentView;
        }
        // or removes from its superview
        else{
            [_imageView removeFromSuperview];
            _imageView = nil;
        }
        
        // Assign the title label's horizontal constraints
        if ([self canShowTitle]) {
            currentView = _titleLabel;
            attribute = NSLayoutAttributeBottom;
            constant = self.titileSpace;
            if (!topView) {
                topView = self.contentView;
                attribute = NSLayoutAttributeTop;
            }
            
            NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fatherView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
            NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:fatherView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:padding];
            NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:fatherView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:padding];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:attribute multiplier:1.0 constant:constant];
            [self.contentView addConstraints:@[centerXConstraint, leadingConstraint, trailingConstraint, topConstraint]];
            topView = currentView;
        }
        // or removes from its superview
        else {
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
        }
        
        // Assign the detail label's horizontal constraints
        if ([self canShowDetail]) {
            currentView = _detailLabel;
            attribute = NSLayoutAttributeBottom;
            constant = self.descipSpace;
            if (!topView) {
                topView = self.contentView;
                attribute = NSLayoutAttributeTop;
            }

            NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fatherView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
            NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:fatherView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:padding];
            NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:fatherView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:padding];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:attribute multiplier:1.0 constant:constant];
            [self.contentView addConstraints:@[centerXConstraint, leadingConstraint, trailingConstraint, topConstraint]];
            topView = currentView;
        }
        // or removes from its superview
        else {
            [_detailLabel removeFromSuperview];
            _detailLabel = nil;
        }
        
        // Assign the button's horizontal constraints
        if ([self canShowButton]) {
            currentView = _button;
            attribute = NSLayoutAttributeBottom;
            constant = self.buttonSpace;
            if (!topView) {
                topView = self.contentView;
                attribute = NSLayoutAttributeTop;
            }

            NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fatherView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
            NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:fatherView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:padding];
            NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:fatherView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:padding];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:attribute multiplier:1.0 constant:constant];
            [self.contentView addConstraints:@[centerXConstraint, leadingConstraint, trailingConstraint, topConstraint]];
            topView = currentView;
        }
        // or removes from its superview
        else {
            [_button removeFromSuperview];
            _button = nil;
        }
        
        // layout bottom constraint
        if (currentView) {
            NSLayoutConstraint *bomConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fatherView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
            [self.contentView addConstraints:@[bomConstraint]];
        }
    }
    
    [self.contentView setNeedsUpdateConstraints];
    [UIView performWithoutAnimation:^{
        [self.contentView layoutIfNeeded];
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // Return any UIControl instance such as buttons, segmented controls, switches, etc.
    if ([hitView isKindOfClass:[UIControl class]]) {
        return hitView;
    }
    
    // Return either the contentView or customView
    if ([hitView isEqual:_contentView] || [hitView isEqual:_customView]) {
        return hitView;
    }
    
    return nil;
}

@end
