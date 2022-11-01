//
//  EPDemoLoadingVIew.m
//  EmptyKit_Example
//
//  Created by tanxl on 2022/10/31.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "EPDemoLoadingVIew.h"

@interface EPDemoLoadingVIew ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation EPDemoLoadingVIew

- (instancetype)initWithFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = CGRectMake(0, 0, 200, 80);
    }
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.tipsLabel];
        [self addSubview:self.imageView];
        [self.imageView startAnimating];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat view_x = self.frame.size.width / 2.0;
    CGFloat image_w = CGRectGetWidth(self.imageView.frame);
    CGFloat image_h = CGRectGetHeight(self.imageView.frame);
    [self.imageView setFrame:CGRectMake(view_x-image_w/2.0, 0, image_w, image_h)];
    
    [self.tipsLabel setText:self.text];
    [self.tipsLabel sizeToFit];
    CGFloat label_w = CGRectGetWidth(self.tipsLabel.frame);
    CGFloat label_h = CGRectGetHeight(self.tipsLabel.frame);
    [self.tipsLabel setFrame:CGRectMake(view_x-label_w/2.0, image_h + 5, label_w, label_h)];
}

- (void)setText:(NSString *)text{
    _text = text;
}

#pragma mark -

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh_idle"]];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:42];
        for (int i = 0; i < 41; i++) {
            NSString *imageName = [NSString stringWithFormat:@"refresh_000%02d",i];
            UIImage *image = [UIImage imageNamed:imageName];
            [array addObject:image];
        }
        _imageView.animationImages = array;
        _imageView.animationDuration = 1.37;
    }
    return _imageView;
}

- (UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLabel;
}

@end
