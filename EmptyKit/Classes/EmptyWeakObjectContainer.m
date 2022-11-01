//
//  EmptyWeakObjectContainer.m
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import "EmptyWeakObjectContainer.h"

@implementation EmptyWeakObjectContainer

- (instancetype)initWithWeakObject:(id)object
{
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    return self;
}

@end
