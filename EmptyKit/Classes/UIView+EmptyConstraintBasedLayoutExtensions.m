//
//  UIView+EmptyConstraintBasedLayoutExtensions.m
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import "UIView+EmptyConstraintBasedLayoutExtensions.h"

@implementation UIView (EmptyConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute
{
    return [NSLayoutConstraint constraintWithItem:view
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self
                                        attribute:attribute
                                       multiplier:1.0
                                         constant:0.0];
}

@end
