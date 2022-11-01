//
//  EmptyPacker+EPDemo.h
//  EmptyKit_Example
//
//  Created by tanxl on 2022/10/31.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import <EmptyKit/EmptyPacker.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmptyPacker (EPDemo)

+ (EmptyPacker *)loading;

+ (EmptyPacker *)loadingText:(NSString *)text;

+ (EmptyPacker *)empty;

+ (EmptyPacker *)errorBlock:(void(^)(void))emptyViewTapBlock;

@end

NS_ASSUME_NONNULL_END
