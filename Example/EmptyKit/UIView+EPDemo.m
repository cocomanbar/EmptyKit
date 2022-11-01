//
//  UIView+EPDemo.m
//  EmptyKit_Example
//
//  Created by tanxl on 2022/10/31.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "UIView+EPDemo.h"
#import "EmptyPacker+EPDemo.h"

@implementation UIView (EPDemo)

- (void)initEmptykit {
    [self registerEmptyStyle:(EmptyRunLoading) forPackerValue:[EmptyPacker loading]];
        
    
}

@end
