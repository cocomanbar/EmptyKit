//
//  UIView+EmptyKit.h
//  EmptyKit
//
//  Created by tanxl on 2022/10/30.
//

#import <UIKit/UIKit.h>
#import "EmptyPacker.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EmptyRun){
    EmptyRunDefault = 0,
    EmptyRunLoading,
    EmptyRunEmpty,
    EmptyRunError,
    EmptyRunCustom,
};

@interface UIView (EmptyKit)

/**
 *  reload之前根据数据源手动切换代理模式
 */
@property (nonatomic, assign) EmptyRun currentEmptyStyle;

/**
 *  扩展刷新模式，内部自动 reloadData
 */
- (void)reloadDataStyle:(EmptyRun)currentEmptyStyle;

/**
 *  扩展刷新模式，在列表执行这个之前需要执行 reloadData
 */
- (void)reloadEmptyStyle:(EmptyRun)currentEmptyStyle;


/**
 *  自定义状态赋值
 */
- (void)registerEmptyStyle:(EmptyRun)emptyStyle forPackerValue:(EmptyPacker *)packer;

- (void)registerEmptyStyle:(EmptyRun)emptyStyle forPackerBlock:(void (^)(EmptyPacker *emptyPacker))emptyPackerBlock;

- (void)updateEmptyStyle:(EmptyRun)emptyStyle forPackerBlock:(void (^)(EmptyPacker *emptyPacker))emptyPackerBlock;

- (void)removeEmptyPackerForStyle:(EmptyRun)emptyStyle;

/**
 *  获取当前绑定的自定义消息
 */
- (NSDictionary * _Nullable)emptyInfoFromStyle:(EmptyRun)emptyStyle;

@end

NS_ASSUME_NONNULL_END
