//
//  UIScrollView+EmptyKit.m
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import "UIScrollView+EmptyKit.h"
#import "EmptyContainer.h"
#import "EmptyWeakObjectContainer.h"
#import <objc/runtime.h>

static char const * const kEmptyDataSetSource =     "emptyDataSetSource";
static char const * const kEmptyDataSetDelegate =   "emptyDataSetDelegate";
static char const * const kEmptyDataSetView =       "emptyDataSetView";

#define kEmptyImageViewAnimationKey @"com.empty.emptyDataSet.imageViewAnimation"

@interface UIScrollView ()
<UIGestureRecognizerDelegate>

@property (nonatomic, readonly) EmptyContainer *emptyContainer;

@end

@implementation UIScrollView (EmptyKit)

#pragma mark - Public

- (void)setEmptyDataSetSource:(id<EmptyDataSetSource>)datasource
{
    if (!datasource || ![self empty_canDisplay]) {
        [self empty_invalidate];
    }
    
    objc_setAssociatedObject(self, kEmptyDataSetSource, [[EmptyWeakObjectContainer alloc] initWithWeakObject:datasource], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // We add method sizzling for injecting -empty_reloadData implementation to the native -reloadData implementation
    [self swizzleIfPossible:@selector(reloadData)];
    
    // Exclusively for UITableView, we also inject -empty_reloadData to -endUpdates
    if ([self isKindOfClass:[UITableView class]]) {
        [self swizzleIfPossible:@selector(endUpdates)];
    }
}

- (id<EmptyDataSetSource>)emptyDataSetSource
{
    EmptyWeakObjectContainer *container = objc_getAssociatedObject(self, kEmptyDataSetSource);
    return container.weakObject;
}

- (void)setEmptyDataSetDelegate:(id<EmptyDataSetDelegate>)delegate
{
    if (!delegate) {
        [self empty_invalidate];
    }
    
    objc_setAssociatedObject(self, kEmptyDataSetDelegate, [[EmptyWeakObjectContainer alloc] initWithWeakObject:delegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<EmptyDataSetDelegate>)emptyDataSetDelegate
{
    EmptyWeakObjectContainer *container = objc_getAssociatedObject(self, kEmptyDataSetDelegate);
    return container.weakObject;
}

- (BOOL)isEmptyDataSetVisible
{
    UIView *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    return view ? !view.hidden : NO;
}

#pragma mark - Properties

- (EmptyContainer *)emptyContainer
{
    EmptyContainer *view = objc_getAssociatedObject(self, kEmptyDataSetView);
    
    if (!view)
    {
        view = [EmptyContainer new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        
        view.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(empty_didTapContentView:)];
        view.tapGesture.delegate = self;
        [view addGestureRecognizer:view.tapGesture];
        
        [self setEmptyDataSetView:view];
    }
    return view;
}

- (void)setEmptyDataSetView:(EmptyContainer *)view
{
    objc_setAssociatedObject(self, kEmptyDataSetView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getters (Private)


- (BOOL)empty_canDisplay
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource conformsToProtocol:@protocol(EmptyDataSetSource)]) {
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]] || [self isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)empty_itemsCount
{
    NSInteger items = 0;
    
    // UIScollView doesn't respond to 'dataSource' so let's exit
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    // UICollectionView support
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;

        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return items;
}

#pragma mark - Reload APIs (Public)

- (void)reloadEmptyDataSet
{
    [self empty_reloadEmptyDataSet];
}


#pragma mark - Reload APIs (Private)

- (void)empty_reloadEmptyDataSet
{
    if (![self empty_canDisplay]) {
        return;
    }
    
    if (([self empty_shouldDisplay] && [self empty_itemsCount] == 0) || [self empty_shouldBeForcedToDisplay])
    {
        // Notifies that the empty dataset view will appear
        [self empty_willAppear];
        
        EmptyContainer *container = self.emptyContainer;
        
        if (!container.superview) {
            // Send the view all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
                [self insertSubview:container atIndex:0];
            }
            else {
                [self addSubview:container];
            }
        }
        
        // Removing view resetting the view and its constraints it very important to guarantee a good state
        [container prepareForReuse];
        
        UIView *customView = [self empty_customView];
        
        // If a non-nil custom view is available, let's configure it instead
        if (customView) {
            container.customView = customView;
        }
        else {
            
            // Get the data from the data source
            UIImage *image = [self empty_image];
            NSAttributedString *titleLabelString = [self empty_titleLabelString];
            NSAttributedString *detailLabelString = [self empty_detailLabelString];
            NSAttributedString *buttonTitle = [self empty_buttonTitleForState:UIControlStateNormal];
            UIImage *buttonImage = [self empty_buttonImageForState:UIControlStateNormal];
            UIColor *buttonBackgroundColor = [self empty_buttonBackgroundColor];
            UIEdgeInsets buttonEdgeInsets = [self empty_buttonEdgeInsets];
            
            container.titileSpace = [self empty_titleSpace];
            container.descipSpace = [self empty_descipSpace];
            container.buttonSpace = [self empty_buttonSpace];
            container.buttonRadiusScale = [self empty_buttonRadius];
            
            if (!UIEdgeInsetsEqualToEdgeInsets(buttonEdgeInsets, UIEdgeInsetsZero)) {
                container.button.contentEdgeInsets = buttonEdgeInsets;
            }
            
            // Configure Image
            if (image) {
                container.imageView.image = image;
            }
            
            // Configure title label
            if (titleLabelString) {
                container.titleLabel.attributedText = titleLabelString;
            }
            
            // Configure detail label
            if (detailLabelString) {
                container.detailLabel.attributedText = detailLabelString;
            }
            
            // Configure button
            if (buttonImage) {
                [container.button setImage:buttonImage forState:UIControlStateNormal];
                [container.button setImage:[self empty_buttonImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }
            else if (buttonTitle) {
                [container.button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
                [container.button setAttributedTitle:[self empty_buttonTitleForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                [container.button setBackgroundImage:[self empty_buttonBackgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
                [container.button setBackgroundImage:[self empty_buttonBackgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }
            if (buttonBackgroundColor) {
                container.button.backgroundColor = buttonBackgroundColor;
            }
        }
        
        // Configure offset
        container.padding = [self empty_padding];
        container.verticalOffset = [self empty_verticalOffset];
        
        // Configure the empty dataset view
        container.backgroundColor = [self empty_dataSetBackgroundColor];
        container.hidden = NO;
        container.clipsToBounds = YES;
        
        // Configure empty dataset userInteraction permission
        container.userInteractionEnabled = [self empty_isTouchAllowed];
        
        // Configure empty dataset fade in display
        container.fadeInOnDisplay = [self empty_shouldFadeIn];
        
        [container setupConstraints];
        
        [UIView performWithoutAnimation:^{
            [container layoutIfNeeded];
        }];
        
        // Configure scroll permission
        self.scrollEnabled = [self empty_isScrollAllowed];
        
        // Configure image view animation
        CAAnimation *animation = [self empty_imageAnimation];
        
        if ([animation isKindOfClass:CAAnimation.class]){
            [container.imageView.layer addAnimation:animation forKey:kEmptyImageViewAnimationKey];
        }
        else if ([container.imageView.layer animationForKey:kEmptyImageViewAnimationKey]) {
            [container.imageView.layer removeAnimationForKey:kEmptyImageViewAnimationKey];
        }
        
        // Notifies that the empty dataset view did appear
        [self empty_didAppear];
    }
    else if (self.isEmptyDataSetVisible) {
        [self empty_invalidate];
    }
}

- (void)empty_invalidate
{
    // Notifies that the empty dataset view will disappear
    [self empty_willDisappear];
    
    if (self.emptyContainer) {
        [self.emptyContainer prepareForReuse];
        [self.emptyContainer removeFromSuperview];
        
        [self setEmptyDataSetView:nil];
    }
    
    self.scrollEnabled = YES;
    
    // Notifies that the empty dataset view did disappear
    [self empty_didDisappear];
}


#pragma mark - Method Swizzling

static NSMutableDictionary *_impLookupTable;
static NSString *const EmptySwizzleInfoPointerKey = @"pointer";
static NSString *const EmptySwizzleInfoOwnerKey = @"owner";
static NSString *const EmptySwizzleInfoSelectorKey = @"selector";

// Based on Bryce Buchanan's swizzling technique http://blog.newrelic.com/2014/04/16/right-way-to-swizzle/
// And Juzzin's ideas https://github.com/juzzin/JUSEmptyViewController

void empty_original_implementation(id self, SEL _cmd)
{
    // Fetch original implementation from lookup table
    Class baseClass = empty_baseClassToSwizzleForTarget(self);
    NSString *key = empty_implementationKey(baseClass, _cmd);
    
    NSDictionary *swizzleInfo = [_impLookupTable objectForKey:key];
    NSValue *impValue = [swizzleInfo valueForKey:EmptySwizzleInfoPointerKey];
    
    IMP impPointer = [impValue pointerValue];
    
    // We then inject the additional implementation for reloading the empty dataset
    // Doing it before calling the original implementation does update the 'isEmptyDataSetVisible' flag on time.
    [self empty_reloadEmptyDataSet];
    
    // If found, call original implementation
    if (impPointer) {
        ((void(*)(id,SEL))impPointer)(self,_cmd);
    }
}

NSString *empty_implementationKey(Class class, SEL selector)
{
    if (!class || !selector) {
        return nil;
    }
    
    NSString *className = NSStringFromClass([class class]);
    
    NSString *selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@",className,selectorName];
}

Class empty_baseClassToSwizzleForTarget(id target)
{
    if ([target isKindOfClass:[UITableView class]]) {
        return [UITableView class];
    }
    else if ([target isKindOfClass:[UICollectionView class]]) {
        return [UICollectionView class];
    }
    else if ([target isKindOfClass:[UIScrollView class]]) {
        return [UIScrollView class];
    }
    
    return nil;
}

- (void)swizzleIfPossible:(SEL)selector
{
    // Check if the target responds to selector
    if (![self respondsToSelector:selector]) {
        return;
    }
    
    // Create the lookup table
    if (!_impLookupTable) {
        _impLookupTable = [[NSMutableDictionary alloc] initWithCapacity:3]; // 3 represent the supported base classes
    }
    
    // We make sure that setImplementation is called once per class kind, UITableView or UICollectionView.
    for (NSDictionary *info in [_impLookupTable allValues]) {
        Class class = [info objectForKey:EmptySwizzleInfoOwnerKey];
        NSString *selectorName = [info objectForKey:EmptySwizzleInfoSelectorKey];
        
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    Class baseClass = empty_baseClassToSwizzleForTarget(self);
    NSString *key = empty_implementationKey(baseClass, selector);
    NSValue *impValue = [[_impLookupTable objectForKey:key] valueForKey:EmptySwizzleInfoPointerKey];
    
    // If the implementation for this class already exist, skip!!
    if (impValue || !key || !baseClass) {
        return;
    }
    
    // Swizzle by injecting additional implementation
    Method method = class_getInstanceMethod(baseClass, selector);
    IMP empty_newImplementation = method_setImplementation(method, (IMP)empty_original_implementation);
    
    // Store the new implementation in the lookup table
    NSDictionary *swizzledInfo = @{EmptySwizzleInfoOwnerKey: baseClass,
                                   EmptySwizzleInfoSelectorKey: NSStringFromSelector(selector),
                                   EmptySwizzleInfoPointerKey: [NSValue valueWithPointer:empty_newImplementation]};
    
    [_impLookupTable setObject:swizzledInfo forKey:key];
}


#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isEqual:self.emptyContainer]) {
        return [self empty_isTouchAllowed];
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIGestureRecognizer *tapGesture = self.emptyContainer.tapGesture;
    
    if ([gestureRecognizer isEqual:tapGesture] || [otherGestureRecognizer isEqual:tapGesture]) {
        return YES;
    }
    
    // defer to emptyDataSetDelegate's implementation if available
    if ( (self.emptyDataSetDelegate != (id)self) && [self.emptyDataSetDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [(id)self.emptyDataSetDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    
    return NO;
}

#pragma mark - Data Source Getters

- (NSAttributedString *)empty_titleLabelString
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(titleForEmptyDataSet:)]) {
        NSAttributedString *string = [self.emptyDataSetSource titleForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -titleForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (NSAttributedString *)empty_detailLabelString
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(descriptionForEmptyDataSet:)]) {
        NSAttributedString *string = [self.emptyDataSetSource descriptionForEmptyDataSet:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -descriptionForEmptyDataSet:");
        return string;
    }
    return nil;
}

- (UIImage *)empty_image
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(imageForEmptyDataSet:)]) {
        UIImage *image = [self.emptyDataSetSource imageForEmptyDataSet:self];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -imageForEmptyDataSet:");
        return image;
    }
    return nil;
}

- (CAAnimation *)empty_imageAnimation
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(imageAnimationForEmptyDataSet:)]) {
        CAAnimation *imageAnimation = [self.emptyDataSetSource imageAnimationForEmptyDataSet:self];
        if (imageAnimation) NSAssert([imageAnimation isKindOfClass:[CAAnimation class]], @"You must return a valid CAAnimation object for -imageAnimationForEmptyDataSet:");
        return imageAnimation;
    }
    return nil;
}

- (NSAttributedString *)empty_buttonTitleForState:(UIControlState)state
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonTitleForEmptyDataSet:forState:)]) {
        NSAttributedString *string = [self.emptyDataSetSource buttonTitleForEmptyDataSet:self forState:state];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -buttonTitleForEmptyDataSet:forState:");
        return string;
    }
    return nil;
}

- (UIImage *)empty_buttonImageForState:(UIControlState)state
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonImageForEmptyDataSet:forState:)]) {
        UIImage *image = [self.emptyDataSetSource buttonImageForEmptyDataSet:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonImageForEmptyDataSet:forState:");
        return image;
    }
    return nil;
}

- (UIImage *)empty_buttonBackgroundImageForState:(UIControlState)state
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonBackgroundImageForEmptyDataSet:forState:)]) {
        UIImage *image = [self.emptyDataSetSource buttonBackgroundImageForEmptyDataSet:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -buttonBackgroundImageForEmptyDataSet:forState:");
        return image;
    }
    return nil;
}

- (UIColor *)empty_dataSetBackgroundColor
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(backgroundColorForEmptyDataSet:)]) {
        UIColor *color = [self.emptyDataSetSource backgroundColorForEmptyDataSet:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -backgroundColorForEmptyDataSet:");
        return color;
    }
    return [UIColor clearColor];
}

- (UIView *)empty_customView
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(customViewForEmptyDataSet:)]) {
        UIView *view = [self.emptyDataSetSource customViewForEmptyDataSet:self];
        if (view) NSAssert([view isKindOfClass:[UIView class]], @"You must return a valid UIView object for -customViewForEmptyDataSet:");
        return view;
    }
    return nil;
}

- (CGFloat)empty_verticalOffset
{
    CGFloat offset = 0.0;
    
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(verticalOffsetForEmptyDataSet:)]) {
        offset = [self.emptyDataSetSource verticalOffsetForEmptyDataSet:self];
    }
    return offset;
}

- (CGFloat)empty_padding
{
    CGFloat offset = -1000;
    
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(paddingForEmptyDataSet:)]) {
        offset = [self.emptyDataSetSource paddingForEmptyDataSet:self];
    }
    return offset;
}

- (CGFloat)empty_titleSpace
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(titleSpaceHeightForEmptyDataSet:)]) {
        return [self.emptyDataSetSource titleSpaceHeightForEmptyDataSet:self];
    }
    return 8.0;
}

- (CGFloat)empty_descipSpace
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(descriptionSpaceHeightForEmptyDataSet:)]) {
        return [self.emptyDataSetSource descriptionSpaceHeightForEmptyDataSet:self];
    }
    return 8.0;
}

- (UIEdgeInsets)empty_buttonEdgeInsets
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonEdgeInsetsForEmptyDataSet:)]) {
        return [self.emptyDataSetSource buttonEdgeInsetsForEmptyDataSet:self];
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)empty_buttonRadius
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonRadiusForEmptyDataSet:)]) {
        return [self.emptyDataSetSource buttonRadiusForEmptyDataSet:self];
    }
    return 0;
}

- (CGFloat)empty_buttonSpace
{
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonTitleSpaceHeightForEmptyDataSet:)]) {
        return [self.emptyDataSetSource buttonTitleSpaceHeightForEmptyDataSet:self];
    }
    return 8.0;
}

- (UIColor *)empty_buttonBackgroundColor {
    if (self.emptyDataSetSource && [self.emptyDataSetSource respondsToSelector:@selector(buttonBackgroundColorForEmptyDataSet:)]) {
        return [self.emptyDataSetSource buttonBackgroundColorForEmptyDataSet:self];
    }
    return nil;
}

#pragma mark - Delegate Getters & Events (Private)

- (BOOL)empty_shouldFadeIn {
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldFadeIn:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldFadeIn:self];
    }
    return YES;
}

- (BOOL)empty_shouldDisplay
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldDisplay:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldDisplay:self];
    }
    return YES;
}

- (BOOL)empty_shouldBeForcedToDisplay
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldBeForcedToDisplay:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldBeForcedToDisplay:self];
    }
    return NO;
}

- (BOOL)empty_isTouchAllowed
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowTouch:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowTouch:self];
    }
    return YES;
}

- (BOOL)empty_isScrollAllowed
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetShouldAllowScroll:)]) {
        return [self.emptyDataSetDelegate emptyDataSetShouldAllowScroll:self];
    }
    return NO;
}

- (void)empty_willAppear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillAppear:)]) {
        [self.emptyDataSetDelegate emptyDataSetWillAppear:self];
    }
}

- (void)empty_didAppear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidAppear:)]) {
        [self.emptyDataSetDelegate emptyDataSetDidAppear:self];
    }
}

- (void)empty_willDisappear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetWillDisappear:)]) {
        [self.emptyDataSetDelegate emptyDataSetWillDisappear:self];
    }
}

- (void)empty_didDisappear
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSetDidDisappear:)]) {
        [self.emptyDataSetDelegate emptyDataSetDidDisappear:self];
    }
}

- (void)empty_didTapContentView:(id)sender
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSet:didTapView:)]) {
        [self.emptyDataSetDelegate emptyDataSet:self didTapView:sender];
    }
}

- (void)empty_didTapDataButton:(id)sender
{
    if (self.emptyDataSetDelegate && [self.emptyDataSetDelegate respondsToSelector:@selector(emptyDataSet:didTapButton:)]) {
        [self.emptyDataSetDelegate emptyDataSet:self didTapButton:sender];
    }
}


@end
