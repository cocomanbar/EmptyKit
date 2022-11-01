//
//  UIView+EmptyConstraintBasedLayoutExtensions.h
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (EmptyConstraintBasedLayoutExtensions)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute;

@end

NS_ASSUME_NONNULL_END
