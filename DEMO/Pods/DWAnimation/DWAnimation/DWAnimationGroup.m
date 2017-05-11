//
//  DWAnimationGroup.m
//  DWAnimation
//
//  Created by Wicky on 16/10/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWAnimationGroup.h"
#import "DWAnimation.h"

@interface DWAnimationGroup ()

///动画操作源
@property (nonatomic ,strong) NSMutableArray * animationArray;

@end

@implementation DWAnimationGroup

-(instancetype)initWithAnimations:(__kindof NSArray<DWAnimation *> *)animations
{
    self = [super init];
    if (self) {
        self.animations = animations;
    }
    return self;
}

-(void)setAnimations:(NSMutableArray<DWAnimation *> *)animations
{
    _animations = animations;
    [self handleAnimationArrayWithAnimations:animations withBeginTime:0];
}

-(void)handleAnimationArrayWithAnimations:(NSMutableArray<DWAnimation *> *)animations withBeginTime:(CGFloat)beginTime
{
    __block CGFloat duration = 0;
    [self.animationArray removeAllObjects];
    NSMutableArray <DWAnimation *>* array = animations.mutableCopy;
    [array enumerateObjectsUsingBlock:^(DWAnimation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DWAnimation * new = [[DWAnimation alloc] initAnimationWithLayer:obj.layer animationKey:[NSString stringWithFormat:@"DWAnimationGroup%lu",(unsigned long)idx] beginTime:beginTime duration:obj.duration animations:@[obj.animation]];
        [self.animationArray addObject:new];
        if (obj.duration > duration) {
            duration = obj.duration;
        }
    }];
    self.duration = duration;
}

-(void)setBeginTime:(CGFloat)beginTime
{
    [super setBeginTime:beginTime];
    [self handleAnimationArrayWithAnimations:self.animations withBeginTime:beginTime];
}

-(void)start
{
    [self.animationArray enumerateObjectsUsingBlock:^(DWAnimation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj start];
    }];
}

-(void)resume
{
    [self.animationArray enumerateObjectsUsingBlock:^(DWAnimation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj resume];
    }];
}

-(void)suspend
{
    [self.animationArray enumerateObjectsUsingBlock:^(DWAnimation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj suspend];
    }];
}

-(void)remove
{
    [self.animationArray enumerateObjectsUsingBlock:^(DWAnimation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj remove];
    }];
}

-(NSMutableArray *)animationArray
{
    if (!_animationArray) {
        _animationArray = [NSMutableArray array];
    }
    return _animationArray;
}

@end
