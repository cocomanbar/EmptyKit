//
//  UIView+EmptyKit.m
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import "UIView+EmptyKit.h"
#import <objc/runtime.h>

static char const * const kEmptyKitMap = "emptyKitMap";
static char const * const kEmptyKitContainView = "emptyKitContainView";
static char const * const kEmptyKitConstraints = "emptyKitConstraints";

@implementation UIView (EmptyKit)

- (void)setEmptyKitMap:(NSMutableDictionary<NSNumber *,EmptyPacker *> *)emptyKitMap {
    objc_setAssociatedObject(self, &kEmptyKitMap, emptyKitMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)emptyKitMap{
    NSMutableDictionary *emptyMap = objc_getAssociatedObject(self, &kEmptyKitMap);
    if (![emptyMap isKindOfClass:NSMutableDictionary.class]) {
        emptyMap = NSMutableDictionary.dictionary;
        [self setEmptyKitMap:emptyMap];
    }
    return emptyMap;
}

- (void)setEmptyKitContainView:(UIScrollView *)emptyKitContainView {
    objc_setAssociatedObject(self, &kEmptyKitContainView, emptyKitContainView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)emptyKitContainView {
    UIScrollView *containView = objc_getAssociatedObject(self, &kEmptyKitContainView);
    if (![containView isKindOfClass:UIScrollView.class]) {
        containView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        containView.showsVerticalScrollIndicator = NO;
        containView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            containView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [containView setAlpha:0];
        containView.frame = self.bounds;
        containView.translatesAutoresizingMaskIntoConstraints = NO;
        [self setEmptyKitContainView:containView];
        [self addSubview:containView];
    }
    return containView;
}

- (void)setEmptyKitConstraints:(NSArray *)emptyKitConstraints {
    objc_setAssociatedObject(self, &kEmptyKitConstraints, emptyKitConstraints, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)emptyKitConstraints {
    return objc_getAssociatedObject(self, &kEmptyKitConstraints);
}


- (EmptyRun)currentEmptyStyle{
    EmptyRun style = (EmptyRun)[objc_getAssociatedObject(self, _cmd) intValue];
    return style;
}

- (void)setCurrentEmptyStyle:(EmptyRun)currentEmptyStyle{
    EmptyRun oldEmptyStyle = [self currentEmptyStyle];
    if (oldEmptyStyle == currentEmptyStyle) {
        return;
    }
    objc_setAssociatedObject(self, @selector(currentEmptyStyle), @(currentEmptyStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableDictionary *emptyMap = [self emptyKitMap];
    EmptyPacker *emptyPacker = [emptyMap objectForKey:@(currentEmptyStyle)];
    [self emptyViewPacker:emptyPacker];
}

- (void)registerEmptyStyle:(EmptyRun)emptyStyle forPackerValue:(EmptyPacker *)packer{
    if (![packer isKindOfClass:EmptyPacker.class]) {
        return;
    }
    NSMutableDictionary *emptyMap = [self emptyKitMap];
    [emptyMap setObject:packer forKey:@(emptyStyle)];
}

- (void)registerEmptyStyle:(EmptyRun)emptyStyle forPackerBlock:(void (^)(EmptyPacker *emptyPacker))emptyPackerBlock{
    if (emptyPackerBlock) {
        EmptyPacker *packer = [EmptyPacker new];
        emptyPackerBlock(packer);
        NSMutableDictionary *emptyMap = [self emptyKitMap];
        if (![packer isKindOfClass:EmptyPacker.class]) {
            return;
        }
        [emptyMap setObject:packer forKey:@(emptyStyle)];
    }
}

- (void)updateEmptyStyle:(EmptyRun)emptyStyle forPackerBlock:(void (^)(EmptyPacker *emptyPacker))emptyPackerBlock {
    if (emptyPackerBlock) {
        NSMutableDictionary *emptyMap = [self emptyKitMap];
        EmptyPacker *emptyPacker = [emptyMap objectForKey:@(emptyStyle)];
        if (emptyPacker) {
            emptyPackerBlock(emptyPacker);
        }
    }
}

- (void)removeEmptyPackerForStyle:(EmptyRun)emptyStyle{
    NSMutableDictionary *emptyMap = [self emptyKitMap];
    if ([emptyMap.allKeys containsObject:@(emptyStyle)]) {
        [emptyMap removeObjectForKey:@(emptyStyle)];
    }
}

- (NSDictionary * _Nullable)emptyInfoFromStyle:(EmptyRun)emptyStyle {
    NSMutableDictionary *emptyMap = [self emptyKitMap];
    EmptyPacker *emptyPacker = [emptyMap objectForKey:@(emptyStyle)];
    if (emptyPacker) {
        return emptyPacker.info;
    }
    return nil;
}

- (void)reloadDataStyle:(EmptyRun)currentEmptyStyle{
    [self setCurrentEmptyStyle:(currentEmptyStyle)];
    if ([self isKindOfClass:UITableView.class]) {
        [((UITableView *)self) reloadData];
    }else if ([self isKindOfClass:UICollectionView.class]){
        [((UICollectionView *)self) reloadData];
    }
}

- (void)reloadEmptyStyle:(EmptyRun)currentEmptyStyle{
    
    [self setCurrentEmptyStyle:(currentEmptyStyle)];
}

#pragma mark - Private

- (void)emptyViewPacker:(EmptyPacker *)emptyPacker{
    
    UIScrollView *containView;
    
    if ([self isKindOfClass:UIScrollView.class]){
        containView = (UIScrollView *)self;
        containView.emptyDataSetSource = emptyPacker;
        containView.emptyDataSetDelegate = emptyPacker;
        return;
    }
    
    containView = [self emptyKitContainView];
    if (!emptyPacker) {
        [containView setAlpha:0];
        return;
    }
    
    EmptyRun currentEmptyStyle = [self currentEmptyStyle];
    if (currentEmptyStyle == EmptyRunDefault) {
        [containView setAlpha:0];
        return;
    }
    
    NSArray *constraints = [self emptyKitConstraints];
    if ([constraints isKindOfClass:NSArray.class] && constraints.count) {
        [self removeConstraints:constraints];
    }
    
    containView.emptyDataSetSource = emptyPacker;
    containView.emptyDataSetDelegate = emptyPacker;
    containView.backgroundColor = emptyPacker.backgroundColor;
    CGFloat c_t = emptyPacker.edgeInsets.top;
    CGFloat c_l = emptyPacker.edgeInsets.left;
    CGFloat c_r = -emptyPacker.edgeInsets.right*2;
    CGFloat c_b = -emptyPacker.edgeInsets.bottom*2;
    NSLayoutConstraint *c_top = [NSLayoutConstraint constraintWithItem:containView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:c_t];
    NSLayoutConstraint *c_left = [NSLayoutConstraint constraintWithItem:containView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:c_l];
    NSLayoutConstraint *c_right = [NSLayoutConstraint constraintWithItem:containView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:c_r];
    NSLayoutConstraint *c_bottom = [NSLayoutConstraint constraintWithItem:containView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:c_b];
    constraints = @[c_top, c_left, c_right, c_bottom];
    [self addConstraints:constraints];
    [containView reloadEmptyDataSet];
    [self setEmptyKitConstraints:constraints];
    [self bringSubviewToFront:containView];
    [containView setAlpha:1];
}

@end
