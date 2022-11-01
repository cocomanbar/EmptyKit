//
//  EmptyWeakObjectContainer.h
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmptyWeakObjectContainer : NSObject

@property (nonatomic, readonly, weak) id weakObject;

- (instancetype)initWithWeakObject:(id)object;

@end

NS_ASSUME_NONNULL_END
